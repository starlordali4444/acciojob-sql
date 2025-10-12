#!/bin/bash
# ---------------------------------------------------------------
# PostgreSQL 16 Installer Script for macOS (Apple Silicon)
# Author: Sayyed Siraj Ali
# ---------------------------------------------------------------

echo "🧩 Starting PostgreSQL installation for macOS..."

# Step 1: Check for Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew is already installed."
fi

# Step 2: Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Step 3: Install PostgreSQL 16
if ! brew list postgresql@16 &>/dev/null; then
  echo "📦 Installing PostgreSQL 16..."
  brew install postgresql@16
else
  echo "✅ PostgreSQL 16 is already installed."
fi

# Step 4: Start PostgreSQL service
echo "🚀 Starting PostgreSQL service..."
brew services start postgresql@16

# Step 5: Add PostgreSQL to PATH if not already present
if ! grep -q "postgresql@16/bin" ~/.zshrc; then
  echo "📁 Adding PostgreSQL to PATH..."
  echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
fi

# Step 6: Verify installation
echo "🔍 Verifying PostgreSQL installation..."
psql_version=$(psql --version 2>/dev/null)

if [ $? -eq 0 ]; then
  echo "✅ PostgreSQL installed successfully!"
  echo "   Version: $psql_version"
  echo "   To access psql, open a new terminal and run:  psql postgres"
else
  echo "⚠️  PostgreSQL installation complete but psql not detected in PATH."
  echo "   Please restart your terminal and run:  psql --version"
fi

echo "🎯 Installation complete!"

