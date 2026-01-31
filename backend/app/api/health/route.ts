/**
 * Health Check Endpoint
 * Returns service status and configuration information
 */

export const runtime = 'edge';

import { NextRequest, NextResponse } from 'next/server';
import { buildRequestContext, createLogger } from '@/lib/logger';
import { corsMiddleware, applyCorsHeaders } from '@/middleware/cors';

/**
 * GET handler for health check
 */
export async function GET(request: NextRequest): Promise<Response> {
  const context = buildRequestContext(request);
  const logger = createLogger(context.requestId);
  
  // Handle CORS
  const corsResponse = corsMiddleware(request, logger);
  if (corsResponse) {
    return corsResponse;
  }
  
  // Check environment configuration (server-side only, not exposed to client)
  const config = {
    gemini: !!process.env.GEMINI_API_KEY,
    supabase: !!(process.env.SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY),
    posthog: !!process.env.POSTHOG_API_KEY,
    jwt: !!process.env.JWT_SECRET,
    kv: !!(process.env.KV_URL || process.env.KV_REST_API_URL),
  };
  
  const allConfigured = Object.values(config).every(v => v);
  
  logger.debug('Health check requested', {
    allConfigured,
    services: Object.keys(config).filter(k => config[k as keyof typeof config])
  });
  
  // Return aggregate status only - don't expose detailed config to client
  const response = NextResponse.json({
    status: allConfigured ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    version: process.env.VERCEL_GIT_COMMIT_SHA?.substring(0, 7) || 'dev',
    environment: process.env.NODE_ENV || 'unknown',
  }, {
    status: allConfigured ? 200 : 503,
  });
  
  return applyCorsHeaders(response, request.headers.get('origin'), logger);
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