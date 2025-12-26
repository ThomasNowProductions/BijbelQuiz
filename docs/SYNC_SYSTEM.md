# BijbelQuiz Data Synchronization

## When the App Syncs

### Automatic Triggers
- **On app startup**: Loads synced data from server and merges with local data
- **On app resume**: Checks for new data and processes offline queue
- **On app pause**: Ensures sync queue is saved to local storage
- **On settings change**: Any setting modification triggers immediate sync
- **On game play**: Score and streak updates sync immediately
- **On lesson completion**: Lesson progress and star ratings sync immediately
- **Real-time updates**: Instantly receives changes from other devices via Supabase channels

### Manual Triggers
- Account screen sync button: Forces immediate full sync

## How Sync Works

### 1. Initial Load (App Startup)
```
App starts → User authenticated → Fetch all data from server → Merge with local data
```
- Game stats: Merge (max scores/streaks, sum incorrect answers)
- Settings: Merge (add missing themes, keep latest settings)
- Lesson progress: Merge (max unlocked count, max stars per lesson)

### 2. Real-Time Updates
```
Device A updates → Supabase → Real-time channel → Device B receives update
```
- Uses Supabase Realtime for instant cross-device sync
- All connected devices receive updates within seconds

### 3. Offline Queue
```
No connection → Queue changes → Reconnect → Process queued items
```
- Changes are queued when offline
- Queue processes automatically when online
- Queue is saved to disk on app pause
- Queue is loaded and processed on app resume

### 4. Conflict Resolution
Always merges data intelligently:

**Game Statistics:**
- Score: Highest value
- Current streak: Highest value
- Longest streak: Highest value
- Incorrect answers: Sum of all values (total mistakes)

**Settings:**
- Theme, speed, mute, etc.: Latest value
- AI themes: Merge all themes from all devices
- Unlocked themes: Union of all unlocked themes

**Lesson Progress:**
- Unlocked count: Highest value
- Stars per lesson: Highest value for each lesson

## What Data Syncs

### Game Stats
- Score
- Current streak
- Longest streak
- Incorrect answers

### Settings
- Theme mode (light/dark/system)
- Game speed (slow/medium/fast)
- Mute status
- Layout type (grid/list/compact)
- Colorful mode
- AI themes (custom color schemes)
- Unlocked themes
- Navigation labels setting
- Hide promo card setting
- Bug reporting setting

### Lesson Progress
- Unlocked lesson count
- Star ratings per lesson (0-3 stars)

## Session Cleanup

When a user logs out:
- Stop all sync operations
- Clear all real-time listeners
- Clear pending sync queue
- Clear current user data

When a user logs in:
- Load synced data from server
- Set up real-time listeners
- Process any queued items
