#!/bin/bash

# Exit on any error
set -e

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js to run the local backend."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm to run the local backend."
    exit 1
fi

# Install Vercel CLI if not already installed
if ! command -v vercel &> /dev/null; then
    echo "Installing Vercel CLI..."
    npm install -g vercel
fi

echo "Starting local backend server on http://localhost:3001"
echo "API endpoints will be available at http://localhost:3001/api/"
echo "Press Ctrl+C to stop the server"

# Change to the backend directory and start the Vercel development server
cd backendbijbelquiz.vercel.app
npx vercel dev --listen 3001