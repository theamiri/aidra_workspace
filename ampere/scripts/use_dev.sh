#!/bin/bash

# Script to switch to development environment
# This copies .env.dev to .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 Switching to DEVELOPMENT environment..."

if [ ! -f "$PROJECT_ROOT/.env.dev" ]; then
    echo "❌ Error: .env.dev file not found!"
    exit 1
fi

cp "$PROJECT_ROOT/.env.dev" "$PROJECT_ROOT/.env"

echo "✅ Successfully switched to DEVELOPMENT environment"
echo "📝 Current environment file: .env (copied from .env.dev)"
echo ""
echo "💡 Run 'flutter run' to start the app with dev environment"

