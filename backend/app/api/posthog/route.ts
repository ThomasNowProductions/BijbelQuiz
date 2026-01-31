/**
 * PostHog API Proxy Route
 * Routes analytics events through backend to protect project API keys
 * Uses Node.js runtime for better compatibility with PostHog API
 */

export const runtime = 'nodejs';

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import {
  ErrorCodes,
  ApiResponse,
} from '@/types/api';
import { Logger, buildRequestContext, createLogger } from '@/lib/logger';
import { corsMiddleware, applyCorsHeaders } from '@/middleware/cors';
import { optionalAuth } from '@/middleware/auth';
import { checkRateLimit, getRateLimitIdentifier, getRateLimitHeaders } from '@/lib/rate-limit';

// PostHog configuration
const POSTHOG_API_KEY = process.env.POSTHOG_API_KEY;
const POSTHOG_HOST = process.env.POSTHOG_HOST || 'https://us.i.posthog.com';

// Shared event schema to eliminate duplication
const EventSchema = z.object({
  event: z.string().min(1).max(100),
  distinctId: z.string().min(1).max(200),
  properties: z.record(z.unknown()).optional(),
  timestamp: z.string().datetime().optional(),
});

// Request validation schemas
const CaptureRequestSchema = EventSchema;

const BatchCaptureRequestSchema = z.object({
  events: z.array(EventSchema).min(1).max(100),
});

/**
 * Sanitize event properties to remove PII
 */
function sanitizeProperties(properties: Record<string, unknown> | undefined): Record<string, unknown> {
  if (!properties) return {};
  
  const sensitiveKeys = [
    'password', 'token', 'secret', 'key', 'api_key',
    'email', 'phone', 'address', 'name', 'credit_card',
    'ssn', 'social_security', 'dob', 'birthdate',
  ];
  
  const sanitized: Record<string, unknown> = {};
  
  for (const [key, value] of Object.entries(properties)) {
    const lowerKey = key.toLowerCase();
    // Use exact/key-equality matching instead of substring
    if (sensitiveKeys.some(sk => lowerKey === sk)) {
      sanitized[key] = '[REDACTED]';
    } else if (Array.isArray(value)) {
      // Handle arrays recursively
      sanitized[key] = value.map(item =>
        typeof item === 'object' && item !== null
          ? sanitizeProperties(item as Record<string, unknown>)
          : item
      );
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeProperties(value as Record<string, unknown>);
    } else {
      sanitized[key] = value;
    }
  }
  
  return sanitized;
}

/**
 * Send event to PostHog
 */
async function sendToPostHog(
  event: string,
  distinctId: string,
  properties: Record<string, unknown>,
  timestamp: string | undefined,
  logger: Logger
): Promise<{ success: boolean; error?: string }> {
  if (!POSTHOG_API_KEY) {
    logger.error('POSTHOG_API_KEY not configured');
    return { success: false, error: 'PostHog not configured' };
  }
  
  const payload = {
    api_key: POSTHOG_API_KEY,
    event,
    distinct_id: distinctId,
    properties: {
      ...properties,
      $lib: 'bijbelquiz-backend',
      $lib_version: '1.0.0',
    },
    timestamp: timestamp || new Date().toISOString(),
  };
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout
    
    const response = await fetch(`${POSTHOG_HOST}/capture/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      const errorText = await response.text();
      logger.error('PostHog API error', { status: response.status, error: errorText });
      return { success: false, error: `PostHog API error: ${response.status}` };
    }
    
    return { success: true };
  } catch (error) {
    logger.error('Failed to send event to PostHog', {}, error as Error);
    return { success: false, error: 'Network error' };
  }
}

/**
 * POST handler for capturing events
 */
export async function POST(request: NextRequest): Promise<Response> {
  const context = buildRequestContext(request);
  const logger = createLogger(context.requestId);
  
  // Handle CORS
  const corsResponse = corsMiddleware(request, logger);
  if (corsResponse) {
    return corsResponse;
  }
  
  try {
    // Check authentication (optional for analytics)
    const auth = await optionalAuth(request, logger);
    
    // Check rate limit
    const identifier = getRateLimitIdentifier(request, auth.userId);
    const rateLimit = await checkRateLimit(identifier, '/api/posthog', logger);
    
    if (!rateLimit.allowed) {
      const errorResponse: ApiResponse = {
        success: false,
        error: {
          code: ErrorCodes.RATE_LIMIT_EXCEEDED,
          message: 'Rate limit exceeded. Please try again later.',
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
          rateLimit: rateLimit.info,
        },
      };
      
      const response = NextResponse.json(errorResponse, { 
        status: 429,
        headers: getRateLimitHeaders(rateLimit.info),
      });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
    // Validate request body
    let body: unknown;
    try {
      body = await request.json();
    } catch {
      const errorResponse: ApiResponse = {
        success: false,
        error: {
          code: ErrorCodes.INVALID_JSON,
          message: 'Invalid JSON in request body',
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(errorResponse, { status: 400 });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
    // Check if batch request
    const isBatch = body && typeof body === 'object' && 'events' in body;
    
    if (isBatch) {
      // Handle batch capture
      const validation = BatchCaptureRequestSchema.safeParse(body);
      if (!validation.success) {
        const errorResponse: ApiResponse = {
          success: false,
          error: {
            code: ErrorCodes.VALIDATION_ERROR,
            message: 'Validation failed',
            details: validation.error.flatten(),
          },
          meta: {
            timestamp: new Date().toISOString(),
            requestId: context.requestId,
          },
        };
        
        const response = NextResponse.json(errorResponse, { status: 400 });
        return applyCorsHeaders(response, request.headers.get('origin'), logger);
      }
      
      const { events } = validation.data;
      logger.info('Processing batch analytics events', { count: events.length });
      
      // Send events to PostHog with limited concurrency (chunk size 5)
      const results: { success: boolean; error?: string }[] = [];
      const chunkSize = 5;
      
      for (let i = 0; i < events.length; i += chunkSize) {
        const chunk = events.slice(i, i + chunkSize);
        const chunkResults = await Promise.all(
          chunk.map(event =>
            sendToPostHog(
              event.event,
              event.distinctId,
              sanitizeProperties(event.properties),
              event.timestamp,
              logger
            )
          )
        );
        results.push(...chunkResults);
      }
      
      const failedCount = results.filter(r => !r.success).length;
      
      if (failedCount > 0) {
        logger.warn('Some analytics events failed', { failed: failedCount, total: events.length });
      }
      
      const successResponse: ApiResponse<{ processed: number; failed: number }> = {
        success: true,
        data: {
          processed: events.length - failedCount,
          failed: failedCount,
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(successResponse, {
        headers: getRateLimitHeaders(rateLimit.info),
      });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
      
    } else {
      // Handle single capture
      const validation = CaptureRequestSchema.safeParse(body);
      if (!validation.success) {
        const errorResponse: ApiResponse = {
          success: false,
          error: {
            code: ErrorCodes.VALIDATION_ERROR,
            message: 'Validation failed',
            details: validation.error.flatten(),
          },
          meta: {
            timestamp: new Date().toISOString(),
            requestId: context.requestId,
          },
        };
        
        const response = NextResponse.json(errorResponse, { status: 400 });
        return applyCorsHeaders(response, request.headers.get('origin'), logger);
      }
      
      const { event, distinctId, properties, timestamp } = validation.data;
      
      logger.info('Processing analytics event', { event, distinctId: distinctId.substring(0, 10) + '...' });
      
      const result = await sendToPostHog(
        event,
        distinctId,
        sanitizeProperties(properties),
        timestamp,
        logger
      );
      
      if (!result.success) {
        const errorResponse: ApiResponse = {
          success: false,
          error: {
            code: ErrorCodes.POSTHOG_API_ERROR,
            message: result.error || 'Failed to capture event',
          },
          meta: {
            timestamp: new Date().toISOString(),
            requestId: context.requestId,
          },
        };
        
        const response = NextResponse.json(errorResponse, { 
          status: 502,
          headers: getRateLimitHeaders(rateLimit.info),
        });
        return applyCorsHeaders(response, request.headers.get('origin'), logger);
      }
      
      const successResponse: ApiResponse = {
        success: true,
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(successResponse, {
        headers: getRateLimitHeaders(rateLimit.info),
      });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
  } catch (error) {
    logger.error('Unexpected error in PostHog route', {}, error as Error);
    
    const errorResponse: ApiResponse = {
      success: false,
      error: {
        code: ErrorCodes.INTERNAL_ERROR,
        message: 'Internal server error',
      },
      meta: {
        timestamp: new Date().toISOString(),
        requestId: context.requestId,
      },
    };
    
    const response = NextResponse.json(errorResponse, { status: 500 });
    return applyCorsHeaders(response, request.headers.get('origin'), logger);
  }
}

/**
 * OPTIONS handler for CORS preflight
 */
export async function OPTIONS(request: NextRequest): Promise<Response> {
  const context = buildRequestContext(request);
  const logger = createLogger(context.requestId);
  
  const response = corsMiddleware(request, logger);
  if (response) {
    return response;
  }
  
  // Apply CORS headers to fallback 204 response
  const origin = request.headers.get('origin');
  const fallbackResponse = new NextResponse(null, { status: 204 });
  return applyCorsHeaders(fallbackResponse, origin, logger);
}