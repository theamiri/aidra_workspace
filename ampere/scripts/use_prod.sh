#!/bin/bash

# Script to switch to production environment
# This copies .env.prod to .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 Switching to PRODUCTION environment..."

if [ ! -f "$PROJECT_ROOT/.env.prod" ]; then
    echo "❌ Error: .env.prod file not found!"
    exit 1
fi

cp "$PROJECT_ROOT/.env.prod" "$PROJECT_ROOT/.env"

echo "✅ Successfully switched to PRODUCTION environment"
echo "📝 Current environment file: .env (copied from .env.prod)"
echo ""
echo "💡 Run 'flutter run' to start the app with prod environment"

