# Local Development Setup

This document explains how to set up and use the local development environment for testing the update system.

## Prerequisites

- Node.js and npm installed
- Flutter SDK installed

## Running the Local Backend

1. Make sure the backend script is executable:
   ```bash
   chmod +x run_local_backend.sh
   ```

2. Run the local backend server:
   ```bash
   ./run_local_backend.sh
   ```

   This will:
   - Install the Vercel CLI if needed
   - Set up a temporary environment
   - Start the backend server on `http://localhost:3001`

3. The API will be available at:
   - Version API: `http://localhost:3001/api/version`
   - Activation codes API: `http://localhost:3001/api/activation-codes`

## Testing in the App

When you run the app in debug mode (`flutter run`), it will automatically use the local backend (`http://localhost:3001`) instead of the production backend (`https://backendbijbelquiz.vercel.app`).

To test with a newer version, you can modify the version in the local API to return a higher version number than what's in your `pubspec.yaml`.

## Testing the Update Flow

1. Start the local backend server
2. Modify the version in the local API to return a version higher than your app version
3. Run the app in debug mode
4. The app should detect the update and show the update dialog

## Stopping the Local Backend

Press `Ctrl+C` in the terminal where the backend server is running.