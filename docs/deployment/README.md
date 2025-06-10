# Deployment Documentation

This directory contains documentation for the deployment process of the BuyBackTools application.

## Deployment Scripts

### Web Deployment (`deploy_web.sh`)
- Deploys the web version to GitHub Pages
- Ensures CNAME file is properly copied
- Builds the Flutter web app
- Pushes to gh-pages branch

### iOS Deployment (`deploy_ios_prexcode.sh`)
- Handles iOS app deployment
- Includes pre-Xcode build steps
- Manages iOS-specific configurations

### Android Deployment (`deploy_android.sh`)
- Handles Android app deployment
- Manages Android-specific configurations
- Includes build and signing steps

## Deployment Process

1. **Web Deployment**
   ```bash
   ./deploy_web.sh
   ```
   - Builds the web app
   - Copies CNAME file
   - Deploys to GitHub Pages

2. **iOS Deployment**
   ```bash
   ./deploy_ios_prexcode.sh
   ```
   - Prepares iOS build
   - Handles pre-Xcode steps
   - Deploys to App Store

3. **Android Deployment**
   ```bash
   ./deploy_android.sh
   ```
   - Prepares Android build
   - Handles signing
   - Deploys to Play Store

## Requirements

- Flutter SDK
- Git
- Platform-specific tools (Xcode for iOS, Android Studio for Android)
- Proper credentials and certificates for each platform 