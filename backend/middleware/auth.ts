/**
 * Authentication middleware with JWT validation
 * Validates incoming request authentication tokens
 */

import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';
import { Logger } from '@/lib/logger';
import { AuthTokenPayload, ErrorCodes } from '@/types/api';

// JWT configuration from environment
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_AUDIENCE = process.env.JWT_AUDIENCE || 'bijbelquiz-backend';
const JWT_ISSUER = process.env.JWT_ISSUER || 'bijbelquiz-auth';

/**
 * Extract token from Authorization header
 */
export function extractToken(request: NextRequest): string | null {
  const authHeader = request.headers.get('authorization');
  
  if (!authHeader) {
    return null;
  }
  
  // Support Bearer token format only
  const parts = authHeader.split(' ');
  if (parts.length === 2 && parts[0].toLowerCase() === 'bearer') {
    return parts[1];
  }
  
  // Reject non-Bearer schemes
  return null;
}

/**
 * Verify JWT token
 */
export async function verifyToken(
  token: string,
  logger: Logger
): Promise<AuthTokenPayload | null> {
  if (!JWT_SECRET) {
    logger.error('JWT_SECRET not configured');
    return null;
  }
  
  try {
    const secret = new TextEncoder().encode(JWT_SECRET);
    
    const { payload } = await jwtVerify(token, secret, {
      audience: JWT_AUDIENCE,
      issuer: JWT_ISSUER,
    });
    
    // Validate required claims
    if (!payload.sub) {
      logger.warn('JWT missing subject claim');
      return null;
    }
    
    // Note: jose.jwtVerify already validates the exp claim
    // This additional check is redundant and has been removed
    
    return payload as AuthTokenPayload;
  } catch (error) {
    logger.warn('JWT verification failed', {}, error as Error);
    return null;
  }
}

/**
 * Authentication result
 */
export interface AuthResult {
  authenticated: boolean;
  userId?: string;
  payload?: AuthTokenPayload;
  error?: {
    code: string;
    message: string;
  };
}

/**
 * Authenticate request
 */
export async function authenticate(
  request: NextRequest,
  logger: Logger
): Promise<AuthResult> {
  // Skip authentication for OPTIONS requests (CORS preflight)
  if (request.method === 'OPTIONS') {
    return { authenticated: true };
  }
  
  // Skip authentication for health check endpoint
  const url = new URL(request.url);
  if (url.pathname === '/api/health') {
    return { authenticated: true };
  }
  
  // Extract token
  const token = extractToken(request);
  
  if (!token) {
    logger.warn('No authentication token provided');
    return {
      authenticated: false,
      error: {
        code: ErrorCodes.UNAUTHORIZED,
        message: 'Authentication required',
      },
    };
  }
  
  // Verify token
  const payload = await verifyToken(token, logger);
  
  if (!payload) {
    return {
      authenticated: false,
      error: {
        code: ErrorCodes.UNAUTHORIZED,
        message: 'Invalid or expired token',
      },
    };
  }
  
  logger.debug('Authentication successful', { userId: payload.sub });
  
  return {
    authenticated: true,
    userId: payload.sub,
    payload,
  };
}

/**
 * Require authentication middleware
 * Returns 401 if not authenticated
 */
export async function requireAuth(
  request: NextRequest,
  logger: Logger
): Promise<{ userId: string; payload: AuthTokenPayload } | NextResponse> {
  const result = await authenticate(request, logger);
  
  if (!result.authenticated || !result.userId || !result.payload) {
    return NextResponse.json(
      {
        success: false,
        error: result.error || {
          code: ErrorCodes.UNAUTHORIZED,
          message: 'Authentication required',
        },
      },
      { status: 401 }
    );
  }
  
  return { userId: result.userId, payload: result.payload };
}

/**
 * Optional authentication middleware
 * Sets userId if available but doesn't require it
 */
export async function optionalAuth(
  request: NextRequest,
  logger: Logger
): Promise<{ userId?: string; payload?: AuthTokenPayload }> {
  const result = await authenticate(request, logger);
  
  if (result.authenticated && result.userId && result.payload) {
    return { userId: result.userId, payload: result.payload };
  }
  
  return {};
}

/**
 * Check if request has required scope
 */
export function hasScope(payload: AuthTokenPayload, requiredScope: string): boolean {
  if (!payload.scope) return false;
  return payload.scope.includes(requiredScope) || payload.scope.includes('admin');
}