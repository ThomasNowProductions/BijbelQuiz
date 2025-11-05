# Security Policy for BijbelQuiz Admin Dashboard

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | ✅ Yes             |

## Reporting a Vulnerability

If you discover a security vulnerability in this admin dashboard, please report it responsibly by contacting the maintainers directly. Do not create a public issue.

To report a vulnerability:
1. Email your findings to [security contact email] 
2. Include detailed information about the vulnerability and steps to reproduce it
3. Allow for a reasonable time for a response before disclosing publicly

We will acknowledge your report within 48 hours and provide an estimated timeline for addressing the issue.

## Security Measures

This admin dashboard implements the following security measures:

- Server-side authentication with password stored in environment variables
- JWT token-based authorization for all API endpoints
- Input validation and sanitization
- Rate limiting to prevent abuse
- Security HTTP headers via Helmet.js
- Protection against common vulnerabilities (XSS, SQL injection, etc.)

## Data Handling

The application only handles data that is already stored in Supabase, with no direct data storage on the dashboard server itself. All sensitive operations are performed through authenticated API calls to Supabase.

## Authentication

The dashboard uses a single admin password for authentication, which should be set in environment variables and never stored in code. JWT tokens expire after 8 hours to limit the window of exposure if compromised.

## Updates and Maintenance

We are committed to promptly addressing security vulnerabilities. All dependencies are regularly updated, and security audits are performed periodically.

## Responsible Disclosure

We appreciate security researchers who follow responsible disclosure practices. Once a vulnerability is addressed, we will:
- Acknowledge the reporter (with permission)
- Release a patch as soon as possible
- Provide details about the issue and fix in the release notes