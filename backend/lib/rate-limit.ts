/**
 * Rate limiting implementation using Vercel KV
 * Prevents API abuse by limiting requests per IP/user
 */

import { kv } from '@vercel/kv';
import { RateLimitConfig, RateLimitStore, RateLimitInfo } from '@/types/api';
import { Logger } from '@/lib/logger';

// Default rate limit configuration
const DEFAULT_RATE_LIMIT: RateLimitConfig = {
  windowMs: 60 * 1000, // 1 minute
  maxRequests: 60,     // 60 requests per minute
};

// Stricter limits for specific endpoints
const ENDPOINT_RATE_LIMITS: Record<string, RateLimitConfig> = {
  '/api/gemini': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 10,     // 10 AI generation requests per minute
  },
  '/api/supabase/auth': {
    windowMs: 15 * 60 * 1000, // 15 minutes
    maxRequests: 10,          // 10 auth attempts per 15 minutes
  },
  '/api/posthog': {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 100,    // 100 analytics events per minute
  },
};

// Configurable fail-closed behavior
const RATE_LIMIT_FAIL_CLOSED = process.env.RATE_LIMIT_FAIL_CLOSED === 'true';
const SENSITIVE_PATHS = new Set(['/api/supabase/auth']);

/**
 * Find matching endpoint for a path, sorted by length (most specific first)
 */
function findMatchingEndpoint(path: string): { endpoint: string; config: RateLimitConfig } | null {
  // Sort endpoints by descending length to prefer more specific matches
  const sortedEndpoints = Object.entries(ENDPOINT_RATE_LIMITS).sort(
    (a, b) => b[0].length - a[0].length
  );
  
  for (const [endpoint, config] of sortedEndpoints) {
    if (path.startsWith(endpoint)) {
      return { endpoint, config };
    }
  }
  
  return null;
}

/**
 * Get rate limit configuration for a path
 */
export function getRateLimitConfig(path: string): RateLimitConfig {
  // Find most specific matching endpoint config
  const match = findMatchingEndpoint(path);
  if (match) {
    return match.config;
  }
  
  // Return default config with optional environment overrides
  return {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '') || DEFAULT_RATE_LIMIT.windowMs,
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '') || DEFAULT_RATE_LIMIT.maxRequests,
  };
}

/**
 * Generate rate limit key for an identifier
 */
function generateRateLimitKey(identifier: string, path: string): string {
  // Use path-specific key for endpoint-specific limits
  const match = findMatchingEndpoint(path);
  if (match) {
    return `rate_limit:${match.endpoint}:${identifier}`;
  }
  
  return `rate_limit:global:${identifier}`;
}

/**
 * Check if rate limit is exceeded
 */
export async function checkRateLimit(
  identifier: string,
  path: string,
  logger: Logger
): Promise<{ allowed: boolean; info: RateLimitInfo }> {
  const config = getRateLimitConfig(path);
  const key = generateRateLimitKey(identifier, path);
  const now = Date.now();
  const windowStart = now - config.windowMs;
  
  try {
    // Get current rate limit data from KV
    const data = await kv.get<RateLimitStore>(key);
    
    if (!data || now > data.resetTime) {
      // First request or window expired - create new entry
      const newData: RateLimitStore = {
        count: 1,
        resetTime: now + config.windowMs,
      };
      
      await kv.set(key, newData, { ex: Math.ceil(config.windowMs / 1000) });
      
      const info: RateLimitInfo = {
        limit: config.maxRequests,
        remaining: config.maxRequests - 1,
        reset: Math.ceil(newData.resetTime / 1000),
      };
      
      logger.debug('Rate limit window started', { 
        identifier: identifier.substring(0, 8) + '...',
        path,
        remaining: info.remaining,
      });
      
      return { allowed: true, info };
    }
    
    // Check if limit exceeded
    if (data.count >= config.maxRequests) {
      const info: RateLimitInfo = {
        limit: config.maxRequests,
        remaining: 0,
        reset: Math.ceil(data.resetTime / 1000),
      };
      
      logger.warn('Rate limit exceeded', { 
        identifier: identifier.substring(0, 8) + '...',
        path,
        count: data.count,
        resetTime: new Date(data.resetTime).toISOString(),
      });
      
      return { allowed: false, info };
    }
    
    // Increment count
    const updatedData: RateLimitStore = {
      count: data.count + 1,
      resetTime: data.resetTime,
    };
    
    const ttl = Math.ceil((data.resetTime - now) / 1000);
    await kv.set(key, updatedData, { ex: ttl });
    
    const info: RateLimitInfo = {
      limit: config.maxRequests,
      remaining: config.maxRequests - updatedData.count,
      reset: Math.ceil(updatedData.resetTime / 1000),
    };
    
    logger.debug('Rate limit check passed', { 
      identifier: identifier.substring(0, 8) + '...',
      path,
      count: updatedData.count,
      remaining: info.remaining,
    });
    
    return { allowed: true, info };
    
  } catch (error) {
    logger.error('Rate limit check failed', { identifier: identifier.substring(0, 8) + '...', path }, error as Error);
    
    // Fail open - allow request if KV is unavailable
    // In production, you might want to fail closed (deny request)
    const failSafeInfo: RateLimitInfo = {
      limit: config.maxRequests,
      remaining: 1,
      reset: Math.ceil((now + config.windowMs) / 1000),
    };
    
    return { allowed: true, info: failSafeInfo };
  }
}

/**
 * Get rate limit headers for response
 */
export function getRateLimitHeaders(info: RateLimitInfo): Record<string, string> {
  return {
    'X-RateLimit-Limit': info.limit.toString(),
    'X-RateLimit-Remaining': Math.max(0, info.remaining).toString(),
    'X-RateLimit-Reset': info.reset.toString(),
  };
}

/**
 * Get identifier for rate limiting (IP or user ID)
 */
export function getRateLimitIdentifier(
  request: Request,
  userId?: string
): string {
  // Use user ID if available (for authenticated requests)
  if (userId) {
    return `user:${userId}`;
  }
  
  // Fall back to IP address or generate a fingerprint-based identifier
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  
  if (forwarded) {
    return `ip:${forwarded.split(',')[0].trim()}`;
  }
  
  if (realIp) {
    return `ip:${realIp}`;
  }
  
  // Generate a weak but unique fallback identifier from request fingerprints
  const userAgent = request.headers.get('user-agent') || '';
  const acceptLanguage = request.headers.get('accept-language') || '';
  const fingerprint = `${userAgent}:${acceptLanguage}:${Date.now()}`;
  
  // Create a simple hash (not cryptographically secure but sufficient for rate limiting)
  let hash = 0;
  for (let i = 0; i < fingerprint.length; i++) {
    const char = fingerprint.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  
  return `fp:${Math.abs(hash).toString(16)}`;
}

/**
 * Reset rate limit for an identifier (useful for testing or admin operations)
 */
export async function resetRateLimit(
  identifier: string,
  path: string,
  logger: Logger
): Promise<void> {
  const key = generateRateLimitKey(identifier, path);
  
  try {
    await kv.del(key);
    logger.info('Rate limit reset', { identifier: identifier.substring(0, 8) + '...', path });
  } catch (error) {
    logger.error('Failed to reset rate limit', { identifier: identifier.substring(0, 8) + '...', path }, error as Error);
    throw error;
  }
}

/**
 * Get current rate limit status for an identifier
 */
export async function getRateLimitStatus(
  identifier: string,
  path: string
): Promise<RateLimitInfo | null> {
  const config = getRateLimitConfig(path);
  const key = generateRateLimitKey(identifier, path);
  
  try {
    const data = await kv.get<RateLimitStore>(key);
    
    if (!data) {
      return {
        limit: config.maxRequests,
        remaining: config.maxRequests,
        reset: Math.ceil((Date.now() + config.windowMs) / 1000),
      };
    }
    
    return {
      limit: config.maxRequests,
      remaining: Math.max(0, config.maxRequests - data.count),
      reset: Math.ceil(data.resetTime / 1000),
    };
  } catch (err) {
    // Log the error for observability
    console.error('Failed to get rate limit status:', err);
    return null;
  }
}