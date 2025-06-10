#!/bin/bash
set -e

# Ensure you are on main and up to date
git checkout main
git add .
git commit -m "Update main branch with latest project changes" || echo "Nothing to commit"
git pull origin main --rebase
git push origin main

# Build the web app
cd FProjects/BuyBackTools
flutter build web

# Copy CNAME file into the build output
CNAME_PATH="../../CNAME"
if [ -f "$CNAME_PATH" ]; then
  cp "$CNAME_PATH" build/web/CNAME
  echo "CNAME file copied successfully."
  git add -f build/web/CNAME
  git commit -m "chore: force add CNAME to web build output" || echo "No changes to commit for CNAME"
else
  echo "Error: CNAME file not found at $CNAME_PATH"
  exit 1
fi

# Deploy to gh-pages using subtree split
cd ../..
git push origin `git subtree split --prefix FProjects/BuyBackTools/build/web main`:gh-pages --force

echo "Web deploy complete. CNAME ensured." 