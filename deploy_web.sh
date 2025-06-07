#!/bin/bash
set -e

# Ensure you are on main and up to date
git checkout main
git add .
git commit -m "Update main branch with latest project changes" || echo "Nothing to commit"
git pull origin main --rebase
git push origin main

# Build the web app
cd FProjects/StackFlutter1
flutter build web

# Copy CNAME file into the build output
cp ../../CNAME build/web/CNAME

# Deploy to gh-pages using subtree split
cd ../..
git push origin `git subtree split --prefix FProjects/StackFlutter1/build/web main`:gh-pages --force

echo "Web deploy complete. CNAME ensured." 