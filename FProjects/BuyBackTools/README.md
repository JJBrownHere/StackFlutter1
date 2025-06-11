# BuyBackTools Flutter Application

A Flutter application for iPhone price checking and buyback tools.

## Features

- iPhone model selection with accurate ordering
- Storage capacity options
- Condition grading system
- Comprehensive price checking across:
  - Graded Pricing (A, B, C, D grades)
  - Trade-in Pricing (Apple, ATT, TMobile, Verizon)
  - Seller Pricing (Gazelle, It's Worth More, Plug.Tech)
- Responsive design for both mobile and desktop
- Real-time price updates

## Tech Stack

- Flutter
- Material Design 3
- Responsive UI components
- Price checking service integration

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Price checking service credentials

### Installation

1. Navigate to the project directory:
```bash
cd FProjects/BuyBackTools
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
   - Set up your price checking service credentials
   - Configure any necessary API keys

4. Run the app:
```bash
flutter run
```

## Development

The application supports both web and mobile platforms with responsive design.

## Project Structure

```
lib/
├── screens/          # Screen widgets
│   └── price_checks_screen.dart
├── services/         # Business logic
│   └── price_service.dart
├── widgets/          # Reusable widgets
└── helpers/          # Utility functions
```

## License

This project is proprietary and confidential.

## Local Development

Before running or building, generate your secrets file:

GOOGLE_SHEETS_API_KEY=your_key API_KEY=your_other_key ./generate_secrets.sh

