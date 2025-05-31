# STACKS Flutter Web App

A modern Flutter web application with authentication and dashboard interface.

## Features

- Google and Apple Sign-In authentication using Supabase
- Modern Material Design 3 UI
- Responsive dashboard layout
- Four main sections:
  - IMEI Checks
  - Price STACKS
  - Inventory
  - Purchase

## Tech Stack

- Flutter Web
- Supabase for authentication and backend
- Google OAuth integration
- Apple Sign-In integration

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- A Supabase account and project
- Google Cloud Console project with OAuth credentials
- Apple Developer account (for Apple Sign-In)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/StackFlutter1.git
```

2. Navigate to the project directory:
```bash
cd StackFlutter1
```

3. Install dependencies:
```bash
flutter pub get
```

4. Configure environment variables:
   - Set up your Supabase URL and anon key
   - Configure OAuth redirect URLs
   - Set up Apple Sign-In credentials

5. Run the app:
```bash
flutter run -d chrome
```

## Development

The project includes a developer bypass button in debug mode for easier testing and development.

## License

This project is proprietary and confidential.
