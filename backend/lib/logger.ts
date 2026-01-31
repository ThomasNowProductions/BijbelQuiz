/**
 * Structured logging utility for BijbelQuiz backend
 * Provides consistent log formatting and request correlation
 */

import { LogEntry, RequestContext } from '@/types/api';

// Log levels in order of severity
const LOG_LEVELS = ['debug', 'info', 'warn', 'error'] as const;
type LogLevel = typeof LOG_LEVELS[number];

// Get minimum log level from environment with validation
function getMinLogLevel(): LogLevel {
  const envLevel = process.env.LOG_LEVEL;
  if (envLevel && LOG_LEVELS.includes(envLevel as LogLevel)) {
    return envLevel as LogLevel;
  }
  if (envLevel) {
    console.warn(`Invalid LOG_LEVEL: ${envLevel}, falling back to 'info'`);
  }
  return 'info';
}

const MIN_LOG_LEVEL = getMinLogLevel();

/**
 * Get numeric value for log level for comparison
 */
function getLogLevelValue(level: LogLevel): number {
  return LOG_LEVELS.indexOf(level);
}

/**
 * Check if a log level should be logged
 */
function shouldLog(level: LogLevel): boolean {
  return getLogLevelValue(level) >= getLogLevelValue(MIN_LOG_LEVEL);
}

/**
 * Generate a unique request ID
 */
export function generateRequestId(): string {
  return `${Date.now().toString(36)}-${Math.random().toString(36).substring(2, 11)}`;
}

/**
 * Validate and sanitize IP address
 */
function sanitizeIpAddress(ip: string): string {
  // Remove control characters, newlines, and trim
  const sanitized = ip.replace(/[\x00-\x1F\x7F]/g, '').trim();
  
  // Basic IPv4 validation regex
  const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
  // Basic IPv6 validation regex (simplified)
  const ipv6Regex = /^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^([0-9a-fA-F]{1,4}:){1,7}:$|^([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}$/;
  
  if (ipv4Regex.test(sanitized) || ipv6Regex.test(sanitized)) {
    return sanitized;
  }
  
  return 'unknown';
}

/**
 * Get client IP address from request headers
 */
export function getClientIp(request: Request): string {
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  
  if (forwarded) {
    return sanitizeIpAddress(forwarded.split(',')[0].trim());
  }
  
  if (realIp) {
    return sanitizeIpAddress(realIp);
  }
  
  return 'unknown';
}

/**
 * Build request context from incoming request
 */
export function buildRequestContext(request: Request): RequestContext {
  let pathname: string;
  
  try {
    const url = new URL(request.url);
    pathname = url.pathname;
  } catch {
    // Fallback for malformed URLs
    pathname = '/';
  }
  
  return {
    requestId: request.headers.get('x-request-id') || generateRequestId(),
    ip: getClientIp(request),
    userAgent: request.headers.get('user-agent') || 'unknown',
    path: pathname,
    method: request.method,
  };
}

/**
 * Format log entry as JSON
 */
function formatLogEntry(entry: LogEntry): string {
  const logData = {
    timestamp: entry.timestamp,
    level: entry.level.toUpperCase(),
    message: entry.message,
    request_id: entry.requestId,
    ...(entry.context && Object.keys(entry.context).length > 0 && { context: entry.context }),
    ...(entry.error && {
      error: {
        message: entry.error.message,
        stack: entry.error.stack,
        name: entry.error.name,
      },
    }),
  };
  
  try {
    return JSON.stringify(logData);
  } catch (error) {
    // Handle circular references or other serialization errors
    const fallbackLogData = {
      timestamp: entry.timestamp,
      level: entry.level.toUpperCase(),
      message: entry.message,
      request_id: entry.requestId,
      serializationError: (error as Error).message,
      context: '[Could not serialize context]',
    };
    return JSON.stringify(fallbackLogData);
  }
}

/**
 * Core logging function
 */
function log(level: LogLevel, message: string, requestId: string, context?: Record<string, unknown>, error?: Error): void {
  if (!shouldLog(level)) {
    return;
  }
  
  const entry: LogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    requestId,
    context,
    error,
  };
  
  const formattedLog = formatLogEntry(entry);
  
  // Use console methods appropriate for each level
  switch (level) {
    case 'debug':
      console.debug(formattedLog);
      break;
    case 'info':
      console.info(formattedLog);
      break;
    case 'warn':
      console.warn(formattedLog);
      break;
    case 'error':
      console.error(formattedLog);
      break;
  }
}

/**
 * Logger class for request-scoped logging
 */
export class Logger {
  constructor(private requestId: string) {}
  
  debug(message: string, context?: Record<string, unknown>): void {
    log('debug', message, this.requestId, context);
  }
  
  info(message: string, context?: Record<string, unknown>): void {
    log('info', message, this.requestId, context);
  }
  
  warn(message: string, context?: Record<string, unknown>, error?: Error): void {
    log('warn', message, this.requestId, context, error);
  }
  
  error(message: string, context?: Record<string, unknown>, error?: Error): void {
    log('error', message, this.requestId, context, error);
  }
}

/**
 * Create a logger instance for a request
 */
export function createLogger(requestId: string): Logger {
  return new Logger(requestId);
}

/**
 * Sanitize sensitive data from logs
 */
export function sanitizeForLogging(obj: Record<string, unknown>): Record<string, unknown> {
  const sensitiveFields = [
    'password', 'token', 'secret', 'key', 'authorization', 'api_key',
    'cookie', 'session', 'bearer', 'credential', 'private', 'credit',
    'cvv', 'ssn', 'api-token', 'auth_token', 'refresh_token'
  ];
  const sanitized: Record<string, unknown> = {};
  
  for (const [key, value] of Object.entries(obj)) {
    const lowerKey = key.toLowerCase();
    if (sensitiveFields.some(field => lowerKey.includes(field))) {
      sanitized[key] = '[REDACTED]';
    } else if (Array.isArray(value)) {
      // Handle arrays by mapping each element
      sanitized[key] = value.map(item =>
        typeof item === 'object' && item !== null
          ? sanitizeForLogging(item as Record<string, unknown>)
          : item
      );
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeForLogging(value as Record<string, unknown>);
    } else {
      sanitized[key] = value;
    }
  }
  
  return sanitized;
}