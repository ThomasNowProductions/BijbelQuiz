# BijbelQuiz Backend API

A secure API proxy architecture using Next.js 14+ App Router with TypeScript, deployed on Vercel. Routes all third-party API traffic from the frontend application through backend.bijbelquiz.app, completely removing API keys from client-side code.

## Features

- **Secure API Proxy**: All third-party API calls (Gemini, Supabase, PostHog) routed through backend
- **Server-Side API Keys**: All API keys stored exclusively in Vercel environment variables
- **Rate Limiting**: Built-in rate limiting using Vercel KV to prevent API abuse
- **JWT Authentication**: Secure authentication with JWT tokens
- **CORS Protection**: Strict CORS policies allowing only approved origins
- **Structured Logging**: Comprehensive request logging with correlation IDs
- **TypeScript**: Full type safety across all API routes
- **Edge Runtime**: Gemini API uses Edge runtime for optimal performance and streaming support

## API Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/health` | GET | Health check endpoint | No |
| `/api/gemini` | POST | Generate AI quiz questions and content | Optional |
| `/api/supabase` | POST | Database operations (RLS bypass) | Yes |
| `/api/posthog` | POST | Capture analytics events | Optional |

## Environment Variables

All environment variables are **server-side only** and never exposed to clients:

### Required Variables

```bash
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_AUDIENCE=bijbelquiz-backend
JWT_ISSUER=bijbelquiz-auth

# Google Gemini API
GEMINI_API_KEY=your-gemini-api-key

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_ANON_KEY=your-anon-key

# PostHog
POSTHOG_API_KEY=phc_your-key
POSTHOG_HOST=https://us.i.posthog.com

# Vercel KV (Rate Limiting)
KV_URL=redis://...
KV_REST_API_URL=https://...
KV_REST_API_TOKEN=...

# CORS
ALLOWED_ORIGINS=https://bijbelquiz.app,https://www.bijbelquiz.app
```

See `.env.example` for the complete list.

## Deployment to Vercel

### 1. Create Vercel Project

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from backend directory
cd backend
vercel
```

### 2. Configure Environment Variables

In the Vercel dashboard:

1. Go to Project Settings → Environment Variables
2. Add all variables from `.env.example`
3. Ensure **"Production"**, **"Preview"**, and **"Development"** environments are configured

### 3. Create KV Store for Rate Limiting

```bash
# Using Vercel CLI
vercel kv create

# Link KV to your project
vercel link
vercel env add KV_URL
```

### 4. Configure Custom Domain

To use `backend.bijbelquiz.app`:

1. In Vercel Dashboard → Domains
2. Add `backend.bijbelquiz.app`
3. Configure DNS with your domain provider:
   - CNAME record: `backend` → `cname.vercel-dns.com`

### 5. Generate JWT Secret

```bash
# Generate a secure random JWT secret
openssl rand -base64 32
```

Add this to your Vercel environment variables as `JWT_SECRET`.

## Local Development

### Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment variables
cp .env.local.example .env.local

# Edit .env.local with your actual API keys

# Run development server
npm run dev
```

The API will be available at `http://localhost:3000`.

### Testing

```bash
# Health check
curl http://localhost:3000/api/health

# Test Gemini (requires JWT token)
curl -X POST http://localhost:3000/api/gemini \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"description": "ocean sunset theme"}'
```

### API Authentication Notes

The `/api/gemini` endpoint accepts optional JWT authentication. When provided, the JWT token is used for rate limiting and logging purposes. Without a token, requests are rate-limited by IP address.

## Security Considerations

### Supabase RLS Bypass

The backend uses the Supabase service_role key which bypasses Row-Level Security (RLS). This is appropriate for:
- Admin operations that need to access multiple users' data
- Complex aggregations that RLS would prevent
- Operations requiring elevated privileges

**Security Implications of RLS Bypass:**
- All database access controls must be enforced at the backend API level
- Any vulnerability in the backend could expose database data
- The service_role key has full database access

**Mitigations:**
- All requests to `/api/supabase` require valid JWT authentication
- User permissions are validated in the handler before any service_role queries
- Table-level and action-level allowlists restrict what operations are permitted
- All privileged actions are logged and auditable
- Consider limiting service_role usage to specific endpoints
- Scope queries to only necessary data
- Rotate the service_role key periodically

### API Key Protection

### API Key Protection
- All third-party API keys are stored in Vercel environment variables
- Keys are only accessible server-side in API routes
- Client applications never have direct access to API keys

### Rate Limiting
- Configurable per-endpoint rate limits
- Uses Vercel KV for distributed rate limiting
- Identifiers based on user ID (if authenticated) or IP address

### CORS
- Strict CORS policies only allow approved origins
- Configurable via `ALLOWED_ORIGINS` environment variable
- Development origins included in development mode

### Authentication
- JWT-based authentication using `jose` library
- Tokens signed with HS256 algorithm
- Configurable audience and issuer claims
- Optional authentication for non-sensitive endpoints

### Request Validation
- All request bodies validated using Zod schemas
- Sanitization of sensitive data in logs
- Proper error responses without exposing internal details

## Architecture

```
Frontend (Flutter)
       │
       │ HTTPS Request with JWT
       ▼
backend.bijbelquiz.app (Vercel)
       │
       ├── /api/gemini → Google Gemini API (Edge Runtime)
       ├── /api/supabase → Supabase (Node.js Runtime, RLS bypass)
       └── /api/posthog → PostHog (Node.js Runtime)
```

## Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| `/api/gemini` | 10 requests | 1 minute |
| `/api/supabase` | 60 requests | 1 minute |
| `/api/posthog` | 100 events | 1 minute |

## Monitoring

### Logs
Structured JSON logs with request correlation IDs. View in Vercel Dashboard → Logs.

### Health Check
Monitor the `/api/health` endpoint for service status.

### Response Headers
All responses include:
- `X-Request-ID`: Unique request identifier
- `X-RateLimit-Limit`: Rate limit max
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Reset timestamp

## Troubleshooting

### "JWT_SECRET not configured"
Add `JWT_SECRET` to Vercel environment variables.

### "Rate limit exceeded"
Check your rate limit configuration or wait for the window to reset.

### "Origin not allowed"
Add your origin to `ALLOWED_ORIGINS` environment variable.

### KV connection errors
Ensure Vercel KV is properly linked and environment variables are set.

## License

Private - BijbelQuiz Project