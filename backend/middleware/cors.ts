/**
 * CORS (Cross-Origin Resource Sharing) middleware
 * Configures strict CORS policies to allow only approved frontend origins
 */

import { NextRequest, NextResponse } from 'next/server';
import { Logger } from '@/lib/logger';

// Build allowed origins immutably
const BASE_ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
  : [
      'https://bijbelquiz.app',
      'https://www.bijbelquiz.app',
      'https://play.bijbelquiz.app',
    ];

// Development origins to add in development mode
const DEV_ORIGINS = process.env.NODE_ENV === 'development'
  ? ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:5000', 'http://localhost:5173']
  : [];

// Final immutable allowed origins array
const ALLOWED_ORIGINS = [...BASE_ALLOWED_ORIGINS, ...DEV_ORIGINS];

// CORS headers configuration
const CORS_HEADERS = {
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
  'Access-Control-Allow-Headers': 
    'Content-Type, Authorization, X-Requested-With, X-Request-ID, Accept, Origin',
  'Access-Control-Max-Age': '86400', // 24 hours
  'Access-Control-Expose-Headers': 'X-Request-ID, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset',
} as const;

/**
 * Check if origin is allowed
 */
/**
 * Escape regex special characters in a string
 */
function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function isOriginAllowed(origin: string | null): boolean {
  if (!origin) return false;
  
  // Exact match
  if (ALLOWED_ORIGINS.includes(origin)) {
    return true;
  }
  
  // Wildcard subdomain match (if configured)
  for (const allowed of ALLOWED_ORIGINS) {
    if (allowed.includes('*')) {
      // Escape regex special chars then replace escaped \* with wildcard pattern
      const escaped = escapeRegex(allowed);
      const pattern = escaped.replace(/\\\*/g, '[^.]+');
      const regex = new RegExp(`^${pattern}$`);
      if (regex.test(origin)) {
        return true;
      }
    }
  }
  
  return false;
}

/**
 * Get the appropriate CORS headers for a request
 */
export function getCorsHeaders(requestOrigin: string | null): Record<string, string> {
  const headers: Record<string, string> = { ...CORS_HEADERS };
  
  // Only set Access-Control-Allow-Origin if origin is allowed
  if (isOriginAllowed(requestOrigin)) {
    headers['Access-Control-Allow-Origin'] = requestOrigin || '';
  }
  
  return headers;
}

/**
 * Handle CORS preflight (OPTIONS) requests
 */
export function handleCorsPreflight(request: NextRequest, logger: Logger): NextResponse {
  const origin = request.headers.get('origin');
  
  logger.debug('Handling CORS preflight request', { origin });
  
  const headers = getCorsHeaders(origin);
  
  // If origin is not allowed, return 403
  if (!isOriginAllowed(origin)) {
    logger.warn('CORS preflight rejected - origin not allowed', { origin });
    return new NextResponse(
      JSON.stringify({ error: 'Forbidden', message: 'Origin not allowed' }),
      {
        status: 403,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
      }
    );
  }
  
  logger.debug('CORS preflight accepted', { origin });
  
  return new NextResponse(null, {
    status: 204,
    headers,
  });
}

/**
 * Apply CORS headers to a response
 *
 * Note: This function sets CORS-related headers even when isOriginAllowed returns false
 * (it may omit Access-Control-Allow-Origin but still adds other headers).
 * Callers who need to block disallowed origins entirely should perform pre-validation
 * (e.g., via corsMiddleware or an isOriginAllowed check) before calling applyCorsHeaders.
 *
 * @param response - The NextResponse to apply headers to
 * @param requestOrigin - The origin from the request headers
 * @param logger - Logger instance for logging warnings
 * @returns The modified response with CORS headers
 */
export function applyCorsHeaders(
  response: NextResponse,
  requestOrigin: string | null,
  logger: Logger
): NextResponse {
  const headers = getCorsHeaders(requestOrigin);
  
  Object.entries(headers).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  
  if (!isOriginAllowed(requestOrigin)) {
    logger.warn('Request from disallowed origin', { origin: requestOrigin });
  }
  
  return response;
}

/**
 * CORS middleware for Next.js
 * This should be used in middleware.ts or at the start of route handlers
 */
export function corsMiddleware(
  request: NextRequest, 
  logger: Logger
): NextResponse | null {
  const origin = request.headers.get('origin');
  
  // Handle preflight requests
  if (request.method === 'OPTIONS') {
    return handleCorsPreflight(request, logger);
  }
  
  // Check origin for non-preflight requests
  if (origin && !isOriginAllowed(origin)) {
    logger.warn('CORS check failed - disallowed origin', { 
      origin, 
      allowedOrigins: ALLOWED_ORIGINS 
    });
    
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Origin not allowed',
        },
      },
      { status: 403 }
    );
  }
  
  return null;
}

/**
 * Create a CORS-wrapped response
 */
export function createCorsResponse(
  body: unknown,
  status: number,
  request: NextRequest,
  logger: Logger,
  additionalHeaders?: Record<string, string>
): NextResponse {
  const origin = request.headers.get('origin');
  
  const response = NextResponse.json(body, { 
    status,
    headers: additionalHeaders,
  });
  
  return applyCorsHeaders(response, origin, logger);
}