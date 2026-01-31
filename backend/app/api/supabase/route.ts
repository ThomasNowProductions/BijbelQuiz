/**
 * Supabase API Proxy Route
 * Routes database requests through backend to protect service role key
 * Uses Node.js runtime for Supabase client compatibility
 * Implements Row Level Security bypass via service role key for admin operations
 */

export const runtime = 'nodejs';

import { NextRequest, NextResponse } from 'next/server';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { z } from 'zod';
import {
  SupabaseQueryRequest,
  SupabaseQueryResponse,
  SupabaseAuthRequest,
  SupabaseAuthResponse,
  ErrorCodes,
  ApiResponse,
} from '@/types/api';
import { Logger, buildRequestContext, createLogger } from '@/lib/logger';
import { corsMiddleware, applyCorsHeaders } from '@/middleware/cors';
import { requireAuth } from '@/middleware/auth';
import { checkRateLimit, getRateLimitIdentifier, getRateLimitHeaders } from '@/lib/rate-limit';

// Supabase configuration
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

// Table allowlist and allowed actions mapping
const ALLOWED_TABLES = new Set([
  'users',
  'profiles',
  'questions',
  'categories',
  'themes',
  'purchases',
  'game_sessions',
  'analytics_events',
]);

const ALLOWED_ACTIONS: Record<string, string[]> = {
  'users': ['select', 'insert', 'update'],
  'profiles': ['select', 'insert', 'update', 'delete'],
  'questions': ['select'],
  'categories': ['select'],
  'themes': ['select'],
  'purchases': ['select', 'insert', 'update'],
  'game_sessions': ['select', 'insert', 'update'],
  'analytics_events': ['insert'],
};

// Request validation schemas
const QueryRequestSchema = z.object({
  table: z.string().min(1),
  action: z.enum(['select', 'insert', 'update', 'delete', 'upsert']),
  data: z.record(z.unknown()).or(z.array(z.record(z.unknown()))).optional(),
  query: z.object({
    select: z.string().optional(),
    eq: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    neq: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    gt: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    gte: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    lt: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    lte: z.array(z.object({ column: z.string(), value: z.unknown() })).optional(),
    in: z.array(z.object({ column: z.string(), values: z.array(z.unknown()) })).optional(),
    is: z.array(z.object({ column: z.string(), value: z.boolean().nullable() })).optional(),
    order: z.object({ column: z.string(), ascending: z.boolean().optional() }).optional(),
    limit: z.number().optional(),
    single: z.boolean().optional(),
  }).optional(),
});

/**
 * Create Supabase admin client with service role key
 * This bypasses RLS - use with caution!
 */
function createAdminClient(): SupabaseClient {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    throw new Error('Supabase configuration missing');
  }
  
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Validate table and action against allowlist
 */
function validateTableAndAction(table: string, action: string): { valid: boolean; error?: string } {
  if (!ALLOWED_TABLES.has(table)) {
    return { valid: false, error: `Table '${table}' is not in the allowed list` };
  }
  
  const allowedActions = ALLOWED_ACTIONS[table] || [];
  if (!allowedActions.includes(action)) {
    return { valid: false, error: `Action '${action}' is not allowed for table '${table}'` };
  }
  
  return { valid: true };
}

/**
 * Check if query has any filters
 */
function hasAnyFilter(query: SupabaseQueryRequest['query']): boolean {
  if (!query) return false;
  return !!(
    query.eq?.length ||
    query.neq?.length ||
    query.gt?.length ||
    query.gte?.length ||
    query.lt?.length ||
    query.lte?.length ||
    query.in?.length ||
    query.is?.length
  );
}

/**
 * Build Supabase query from request
 */
function buildQuery(client: SupabaseClient, request: SupabaseQueryRequest) {
  let query = client.from(request.table);
  
  // Select columns
  const columns = request.query?.select || '*';
  
  switch (request.action) {
    case 'select':
      query = query.select(columns);
      break;
    case 'insert':
      if (!request.data || Object.keys(request.data).length === 0) {
        throw new Error('Insert operations require data');
      }
      query = query.insert(request.data);
      break;
    case 'update':
      if (!request.data || Object.keys(request.data).length === 0) {
        throw new Error('Update operations require data');
      }
      query = query.update(request.data);
      break;
    case 'delete':
      query = query.delete();
      break;
    case 'upsert':
      if (!request.data || Object.keys(request.data).length === 0) {
        throw new Error('Upsert operations require data');
      }
      query = query.upsert(request.data);
      break;
  }
  
  // Apply filters
  if (request.query?.eq) {
    for (const filter of request.query.eq) {
      query = query.eq(filter.column, filter.value);
    }
  }
  
  if (request.query?.neq) {
    for (const filter of request.query.neq) {
      query = query.neq(filter.column, filter.value);
    }
  }
  
  if (request.query?.gt) {
    for (const filter of request.query.gt) {
      query = query.gt(filter.column, filter.value);
    }
  }
  
  if (request.query?.gte) {
    for (const filter of request.query.gte) {
      query = query.gte(filter.column, filter.value);
    }
  }
  
  if (request.query?.lt) {
    for (const filter of request.query.lt) {
      query = query.lt(filter.column, filter.value);
    }
  }
  
  if (request.query?.lte) {
    for (const filter of request.query.lte) {
      query = query.lte(filter.column, filter.value);
    }
  }
  
  if (request.query?.in) {
    for (const filter of request.query.in) {
      query = query.in(filter.column, filter.values);
    }
  }
  
  if (request.query?.is) {
    for (const filter of request.query.is) {
      query = query.is(filter.column, filter.value);
    }
  }
  
  // Apply order
  if (request.query?.order) {
    query = query.order(request.query.order.column, {
      ascending: request.query.order.ascending ?? true,
    });
  }
  
  // Apply limit
  if (request.query?.limit) {
    query = query.limit(request.query.limit);
  }
  
  // Return single result
  if (request.query?.single && request.action === 'select') {
    query = query.single();
  }
  
  return query;
}

/**
 * POST handler for Supabase queries
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
    // Check authentication
    const authResult = await requireAuth(request, logger);
    if (authResult instanceof NextResponse) {
      return authResult;
    }
    
    const { userId } = authResult;
    
    // Check rate limit
    const identifier = getRateLimitIdentifier(request, userId);
    const rateLimit = await checkRateLimit(identifier, '/api/supabase', logger);
    
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
    
    // Validate request body first
    const queryRequest = body as SupabaseQueryRequest;
    const validation = QueryRequestSchema.safeParse(queryRequest);
    
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
    
    // Validate table and action against allowlist
    const tableValidation = validateTableAndAction(queryRequest.table, queryRequest.action);
    if (!tableValidation.valid) {
      logger.warn('Unauthorized table/action access attempt', {
        table: queryRequest.table,
        action: queryRequest.action,
        userId,
      });
      
      const errorResponse: ApiResponse = {
        success: false,
        error: {
          code: ErrorCodes.FORBIDDEN,
          message: tableValidation.error || 'Unauthorized access',
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(errorResponse, { status: 403 });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
    // Validate delete operations have filters
    if (queryRequest.action === 'delete' && !hasAnyFilter(queryRequest.query)) {
      logger.warn('Delete operation attempted without filters', {
        table: queryRequest.table,
        userId,
      });
      
      const errorResponse: ApiResponse = {
        success: false,
        error: {
          code: ErrorCodes.VALIDATION_ERROR,
          message: 'Delete operations require at least one filter',
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(errorResponse, { status: 400 });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
    // Create admin client only after validation passes
    const adminClient = createAdminClient();
    
    logger.info('Executing Supabase query', {
      table: queryRequest.table,
      action: queryRequest.action,
      userId,
    });
    
    const query = buildQuery(adminClient, queryRequest);
    const { data, error, status, statusText } = await query;
    
    if (error) {
      logger.error('Supabase query error', { error: error.message, code: error.code });
      
      const errorResponse: ApiResponse = {
        success: false,
        error: {
          code: ErrorCodes.SUPABASE_API_ERROR,
          message: error.message,
          details: { code: error.code, details: error.details, hint: error.hint },
        },
        meta: {
          timestamp: new Date().toISOString(),
          requestId: context.requestId,
        },
      };
      
      const response = NextResponse.json(errorResponse, { 
        status: status || 500,
        headers: getRateLimitHeaders(rateLimit.info),
      });
      return applyCorsHeaders(response, request.headers.get('origin'), logger);
    }
    
    logger.info('Supabase query successful');
    
    const successResponse: ApiResponse<SupabaseQueryResponse<typeof data>> = {
      success: true,
      data: { data, status, statusText },
      meta: {
        timestamp: new Date().toISOString(),
        requestId: context.requestId,
      },
    };
    
    const response = NextResponse.json(successResponse, {
      headers: getRateLimitHeaders(rateLimit.info),
    });
    return applyCorsHeaders(response, request.headers.get('origin'), logger);
    
  } catch (error) {
    logger.error('Unexpected error in Supabase route', {}, error as Error);
    
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