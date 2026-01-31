/**
 * Shared TypeScript interfaces for BijbelQuiz API
 * These types are used across all API routes and can be shared with the frontend
 */

// ============================================================================
// Common API Types
// ============================================================================

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta?: ResponseMeta;
}

export interface ApiError {
  code: ErrorCode;
  message: string;
  details?: Record<string, unknown>;
}

export interface ResponseMeta {
  timestamp: string;
  requestId: string;
  rateLimit?: RateLimitInfo;
}

export interface RateLimitInfo {
  limit: number;
  remaining: number;
  reset: number;
}

// ============================================================================
// Gemini API Types
// ============================================================================

export interface GeminiGenerateRequest {
  description: string;
  temperature?: number;
  maxOutputTokens?: number;
}

export interface GeminiGenerateResponse {
  palette: ColorPalette;
}

export interface ColorPalette {
  primary: string;
  secondary: string;
  tertiary: string;
  background: string;
  surface: string;
  onPrimary: string;
  onSecondary: string;
  onBackground: string;
  onSurface: string;
}

export interface GeminiStreamChunk {
  candidates?: Array<{
    content?: {
      parts?: Array<{ text?: string }>;
    };
    finishReason?: string;
  }>;
}

// ============================================================================
// Supabase API Types
// ============================================================================

export interface SupabaseQueryRequest {
  table: string;
  action: 'select' | 'insert' | 'update' | 'delete' | 'upsert';
  data?: Record<string, unknown> | Record<string, unknown>[];
  query?: {
    select?: string;
    eq?: Array<{ column: string; value: unknown }>;
    neq?: Array<{ column: string; value: unknown }>;
    gt?: Array<{ column: string; value: unknown }>;
    gte?: Array<{ column: string; value: unknown }>;
    lt?: Array<{ column: string; value: unknown }>;
    lte?: Array<{ column: string; value: unknown }>;
    in?: Array<{ column: string; values: unknown[] }>;
    is?: Array<{ column: string; value: unknown }>;
    order?: { column: string; ascending?: boolean };
    limit?: number;
    single?: boolean;
  };
}

export interface SupabaseQueryResponse<T = unknown> {
  data: T | null;
  count?: number | null;
  status: number;
  statusText: string;
}

// Discriminated union for Supabase auth requests
export type SupabaseAuthRequest =
  | { action: 'signUp'; email: string; password: string; redirectTo?: string }
  | { action: 'signIn'; email: string; password: string }
  | { action: 'signOut' }
  | { action: 'refresh'; refreshToken: string }
  | { action: 'resetPassword'; email: string; redirectTo?: string };

export interface SupabaseAuthResponse {
  user: {
    id: string;
    email?: string;
    user_metadata?: Record<string, unknown>;
  } | null;
  session: {
    access_token: string;
    refresh_token: string;
    expires_in: number;
    expires_at?: number;
  } | null;
}

export interface SupabaseRpcRequest {
  function: string;
  params?: Record<string, unknown>;
}

// ============================================================================
// PostHog API Types
// ============================================================================

export interface PostHogCaptureRequest {
  event: string;
  distinctId: string;
  properties?: Record<string, unknown>;
  timestamp?: string;
}

export interface PostHogBatchCaptureRequest {
  events: Array<{
    event: string;
    distinctId: string;
    properties?: Record<string, unknown>;
    timestamp?: string;
  }>;
}

export interface PostHogIdentifyRequest {
  distinctId: string;
  properties?: Record<string, unknown>;
}

export interface PostHogFeatureFlagRequest {
  distinctId: string;
  flagKey: string;
}

export interface PostHogFeatureFlagResponse {
  enabled: boolean;
  value?: string | boolean | number;
}

// ============================================================================
// Authentication Types
// ============================================================================

export interface AuthTokenPayload {
  sub: string;  // user ID
  iat: number;
  exp: number;
  aud: string;
  iss: string;
  scope?: string[];
}

export interface AuthRequest {
  token: string;
}

// ============================================================================
// Error Types
// ============================================================================

export const ErrorCodes = {
  // General errors
  UNKNOWN_ERROR: 'UNKNOWN_ERROR',
  INVALID_REQUEST: 'INVALID_REQUEST',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  METHOD_NOT_ALLOWED: 'METHOD_NOT_ALLOWED',
  
  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  
  // Service specific
  GEMINI_API_ERROR: 'GEMINI_API_ERROR',
  SUPABASE_API_ERROR: 'SUPABASE_API_ERROR',
  POSTHOG_API_ERROR: 'POSTHOG_API_ERROR',
  
  // Validation
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  INVALID_JSON: 'INVALID_JSON',
  
  // Server errors
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
} as const;

export type ErrorCode = typeof ErrorCodes[keyof typeof ErrorCodes];

// ============================================================================
// Rate Limiting Types
// ============================================================================

export interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

export interface RateLimitStore {
  count: number;
  resetTime: number;
}

// ============================================================================
// Logging Types
// ============================================================================

// Serializable error shape for logging
export interface SerializedError {
  name?: string;
  message: string;
  stack?: string;
  code?: string | number;
  [key: string]: unknown;
}

export interface LogEntry {
  timestamp: string;
  level: 'debug' | 'info' | 'warn' | 'error';
  message: string;
  requestId: string;
  context?: Record<string, unknown>;
  error?: SerializedError;
}

export interface RequestContext {
  requestId: string;
  userId?: string;
  ip: string;
  userAgent: string;
  path: string;
  method: string;
}