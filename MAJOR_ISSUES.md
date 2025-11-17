# Major Issues in BijbelQuiz App

## Critical Security Issues
- [ ] **Remove API keys from assets/.env and implement secure key management** - Critical security vulnerability with exposed credentials
- [ ] **Fix API server security (HTTPS, proper CORS, binding restrictions)** - Server exposes sensitive data without protection

## Testing Issues
- [ ] **Set up proper test mocking for Supabase and external services** - Tests fail due to missing service initialization

## App Architecture Issues
- [ ] **Fix app initialization security (remove .env loading from assets)** - Loading sensitive config from bundled assets


## Performance Issues
- [ ] **Optimize question loading and caching performance** - Potential slow loading with large question sets

## Priority Order
1. **CRITICAL**: Items 1-2 (Security) - Address immediately
2. **HIGH**: Items 3-5 (Configuration) - Fix to enable proper builds
3. **MEDIUM**: Items 6-8 (Architecture/Testing) - Improve development workflow
4. **LOW**: Items 9-12 (Performance/Quality) - Ongoing improvements