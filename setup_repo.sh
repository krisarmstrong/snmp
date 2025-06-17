#!/bin/bash
set -e

echo "🔧 Starting new Nmap NSE GitHub project setup..."

read -p "📦 Project name (e.g., snmp-interface-status): " REPO_NAME
read -p "📝 Repo description: " REPO_DESC
read -p "🔐 Visibility (public/private): " REPO_VISIBILITY

# Initialize Git repo
git init
git add .
git commit -m "Initial commit"

# Create GitHub repo using GH CLI
gh repo create "$REPO_NAME" --description "$REPO_DESC" --"$REPO_VISIBILITY" --source=. --remote=origin --push

# Create initial version tag
git tag -a v1.0.0 -m "Initial stable release"
git push origin v1.0.0

# Install git-chglog if missing
if ! command -v git-chglog &> /dev/null; then
    echo "📥 Installing git-chglog..."
    curl -LO https://github.com/git-chglog/git-chglog/releases/download/v0.15.1/git-chglog_0.15.1_darwin_amd64.tar.gz
    tar -xzf git-chglog_0.15.1_darwin_amd64.tar.gz
    chmod +x git-chglog
    sudo mv git-chglog /usr/local/bin/
fi

# Init changelog config and generate CHANGELOG.md
git-chglog --init
git-chglog -o CHANGELOG.md
git add CHANGELOG.md
git commit -m "Add changelog"
git push origin main

echo "✅ GitHub repo '$REPO_NAME' initialized and tagged as v1.0.0 with changelog."