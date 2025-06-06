#!/bin/bash
set -e

# Build the web app
cd FProjects/StackFlutter1
flutter build web

# Copy CNAME file
cp ../../CNAME build/web/CNAME

# Deploy to gh-pages
cd ../..
git push origin `git subtree split --prefix FProjects/StackFlutter1/build/web main`:gh-pages --force

# Post-deploy: ensure CNAME is present on gh-pages branch
git fetch origin gh-pages
git checkout gh-pages
cp CNAME .
git add CNAME
git commit -m "chore: add CNAME for custom domain" || true
git push origin gh-pages
git checkout main

echo "Web deploy complete. CNAME ensured." 