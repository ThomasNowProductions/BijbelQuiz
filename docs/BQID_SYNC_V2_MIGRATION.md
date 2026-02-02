# BQID Sync System V2 - Migration Guide

This guide explains how to migrate from the old BQID sync system (v1) to the new refactored system (v2).

## Overview

The new BQID Sync System V2 addresses critical issues with the old system:
- **Race conditions**: Fixed with atomic database operations and optimistic locking
- **Lost updates**: Fixed with versioning and server-side conflict resolution
- **Unreliable sync**: Fixed with exponential backoff and proper retry logic
- **Complex state management**: Simplified with clear state tracking

## Changes Made

### 1. Database Schema Changes

**New Tables:**
- `user_sync_data_v2`: Stores sync data with versioning per data key
- `user_sync_metadata`: Tracks device sync status
- `user_sync_queue`: Optional server-side queue (not currently used)

**Key Improvements:**
- Individual versioning per data key (game_stats, settings, lesson_progress)
- Atomic upsert operations via `atomic_sync_upsert()` function
- Server-side conflict resolution
- Better RLS policies

### 2. New Dart Files

**Created:**
- `lib/services/sync/sync_types_v2.dart` - Type definitions with versioning
- `lib/services/sync/sync_queue_v2.dart` - Reliable queue with exponential backoff
- `lib/services/sync_service_v2.dart` - New atomic sync service
- `database/user_sync_data_v2.sql` - New database schema

**Modified:**
- `lib/providers/game_stats_provider.dart` - Updated to use v2
- `lib/providers/settings_provider.dart` - Updated to use v2
- `lib/providers/lesson_progress_provider.dart` - Updated to use v2

## Migration Steps

### Step 1: Deploy Database Changes

1. Open the Supabase SQL Editor
2. Run the entire contents of `database/user_sync_data_v2.sql`
3. This will:
   - Create new tables with proper versioning
   - Set up RLS policies
   - Create atomic sync functions
   - Enable realtime
   - Create migration function

### Step 2: Migrate Existing Data

After deploying the schema, run the migration function to move data from v1 to v2:

```sql
SELECT migrate_sync_data_v1_to_v2();
```

This will:
- Read all data from `user_sync_data` (v1 table)
- Migrate it to `user_sync_data_v2` with version 1
- Preserve all existing user data

### Step 3: Deploy App Update

The app code changes are backward compatible - once deployed, all users will automatically use the new sync system.

**Key points:**
- The old sync service (`SyncService`) is still present for compatibility
- Providers now use `SyncServiceV2.instance`
- No user action required

### Step 4: Verify Migration

Check that the migration was successful:

```sql
-- Count records in v1 table
SELECT COUNT(*) FROM user_sync_data;

-- Count records in v2 table (should be more, as v1 stores all data in one row per user)
SELECT COUNT(*) FROM user_sync_data_v2;

-- Check some sample data
SELECT * FROM user_sync_data_v2 LIMIT 5;
```

### Step 5: Cleanup (Optional - After 30 Days)

Once you're confident the migration is successful:

```sql
-- Drop old table (ONLY AFTER VERIFYING MIGRATION!)
-- DROP TABLE IF EXISTS user_sync_data;

-- Drop old functions
-- DROP FUNCTION IF EXISTS atomic_sync_data;
```

## Technical Details

### How Atomic Sync Works

1. **Version Tracking**: Each data key has a version number
2. **Optimistic Locking**: Client sends expected version with data
3. **Server Resolution**: If versions don't match, server merges data intelligently
4. **Conflict Resolution**:
   - `game_stats`: Max scores, sum incorrect
   - `lesson_progress`: Max unlocked, merge best stars
   - `settings`: Merge AI themes, prefer incoming for others
   - Default: Last-write-wins

### Queue System

The new queue system:
- Stores pending syncs in memory and SharedPreferences
- Uses exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s... up to 5 min
- Max 5 retries per item
- Separates transient errors (network) from permanent errors (validation)
- Processes automatically when connection restored

### Realtime Updates

Real-time sync now:
- Only notifies if server version is newer than local
- Prevents unnecessary UI updates
- Properly handles conflicts

## Rollback Plan

If you need to rollback:

1. Revert app code to use old providers
2. The old `user_sync_data` table still exists (until you drop it)
3. Users may lose some sync data between migration and rollback

## Testing Checklist

Before deploying to production:

- [ ] Test sync on single device
- [ ] Test sync across multiple devices
- [ ] Test offline mode and queue processing
- [ ] Test conflict resolution (edit on two devices simultaneously)
- [ ] Test app resume/pause behavior
- [ ] Verify data integrity after sync
- [ ] Check error handling and retry logic
- [ ] Monitor sync performance

## Monitoring

After deployment, monitor:

```sql
-- Check sync queue status
SELECT 
  data_key,
  COUNT(*) as count,
  AVG(version) as avg_version
FROM user_sync_data_v2
GROUP BY data_key;

-- Check for high version numbers (indicates conflicts)
SELECT * FROM user_sync_data_v2 
WHERE version > 10
ORDER BY version DESC;

-- Monitor failed queue items
SELECT * FROM user_sync_queue 
WHERE status = 'failed';
```

## Troubleshooting

### Issue: Data not syncing

**Check:**
1. Is the user authenticated?
2. Is `SyncServiceV2` initialized?
3. Check queue status: `SyncServiceV2.instance.queue.getStats()`
4. Check network connectivity
5. Look for errors in logs

### Issue: Conflicts not resolving

**Check:**
1. Verify `atomic_sync_upsert` function exists
2. Check version numbers in database
3. Review server logs for errors

### Issue: Duplicate data

**Cause:** Old v1 data not migrated properly

**Fix:**
```sql
-- Re-run migration
SELECT migrate_sync_data_v1_to_v2();

-- Or manually check for duplicates
SELECT user_id, data_key, COUNT(*) 
FROM user_sync_data_v2 
GROUP BY user_id, data_key 
HAVING COUNT(*) > 1;
```

## Support

If you encounter issues:

1. Check the app logs for sync-related errors
2. Review Supabase logs for database errors
3. Check this migration guide for common issues
4. Review the new code in `lib/services/sync_service_v2.dart`

## Summary

The BQID Sync System V2 provides:
- ✅ Atomic operations with optimistic locking
- ✅ Server-side conflict resolution
- ✅ Reliable queue with exponential backoff
- ✅ Better error handling and retry logic
- ✅ Simplified state management
- ✅ Backward compatible migration path

The old system had race conditions that could cause data loss. The new system guarantees data consistency across devices.
