# BijbelQuiz API

This is the backend API for the BijbelQuiz app, providing user account sync and social features. The API is built with Node.js, Express, and Supabase, and is deployed on Vercel.

## Features

- **User Authentication**: Sign up, sign in, and user management
- **Stats Synchronization**: Real-time game statistics sync
- **Social Features**: Follow system, user profiles, and activity feeds
- **Purchase System**: In-app purchases and store management
- **Real-time Updates**: WebSocket support for live updates

## Setup Instructions

### 1. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Go to Settings > API to get your project URL and anon key
3. Go to Settings > Database to get your service role key
4. Run the SQL schema from `database/schema.sql` in your Supabase SQL editor

### 2. Environment Variables

Create a `.env.local` file in the root directory with:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 3. Vercel Deployment

1. Install Vercel CLI: `npm i -g vercel`
2. Login to Vercel: `vercel login`
3. Deploy: `vercel`
4. Set environment variables in Vercel dashboard

### 4. Flutter App Configuration

Update the `AuthService` in your Flutter app with your Supabase credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create new user account
- `POST /api/auth/login` - Sign in with email/password
- `POST /api/auth/login-username` - Sign in with username/password
- `POST /api/auth/logout` - Sign out user
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/check-username/:username` - Check username availability

### Users
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update user profile
- `GET /api/users/profile/:username` - Get user profile by username
- `GET /api/users/search` - Search users
- `POST /api/users/me/activity` - Update last seen timestamp
- `DELETE /api/users/me` - Delete user account

### Stats
- `GET /api/stats/me` - Get current user stats
- `PUT /api/stats/me` - Update user stats
- `GET /api/stats/user/:username` - Get user stats by username
- `GET /api/stats/leaderboard` - Get leaderboard
- `POST /api/stats/sync` - Sync stats from local to server
- `POST /api/stats/me/reset` - Reset user stats

### Social
- `POST /api/social/follow` - Follow a user
- `DELETE /api/social/follow/:username` - Unfollow a user
- `GET /api/social/following` - Get following list
- `GET /api/social/followers` - Get followers list
- `GET /api/social/following/:username` - Check if following user
- `GET /api/social/feed` - Get activity feed
- `GET /api/social/stats/:username` - Get user social stats

### Purchases
- `GET /api/purchases/me` - Get user purchases
- `POST /api/purchases` - Create new purchase
- `GET /api/purchases/:purchaseId` - Get purchase by ID
- `GET /api/purchases/check/:itemType/:itemId` - Check item ownership
- `GET /api/purchases/store/items` - Get available store items
- `POST /api/purchases/:purchaseId/refund` - Refund purchase

## Database Schema

The database includes the following tables:
- `users` - User profiles and account information
- `user_stats` - Game statistics and progress
- `purchases` - In-app purchases and store items
- `follows` - Social follow relationships
- `user_sessions` - User session management

## Development

1. Install dependencies: `npm install`
2. Start development server: `npm run dev`
3. The API will be available at `http://localhost:3000`

## Security

- All endpoints require authentication except public user profiles
- Row Level Security (RLS) is enabled on all tables
- Input validation using Joi schemas
- CORS configured for specific origins
- Helmet for security headers

## License

MIT License - see LICENSE file for details