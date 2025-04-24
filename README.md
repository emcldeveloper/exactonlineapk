# Exact Online Frontend

This is the frontend for the Exact Online application, built with [Flutter](https://flutter.dev/). It provides a responsive and user-friendly interface to interact with the [Exact Online Backend](https://github.com/johnchuma/exact-online-backend). The app supports features like user authentication, data visualization, and seamless integration with the backend API.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [API Integration](#api-integration)
- [Contributing](#contributing)
- [License](#license)

## Features
- User authentication (login, signup, logout)
- Display of data fetched from the Exact Online Backend API
- Responsive UI for mobile (iOS, Android) and web
- State management using [Provider](https://pub.dev/packages/provider) (or specify your preferred package)
- Error handling and loading states
- (Add specific features of your app here, e.g., "Dashboard for financial data")

## Prerequisites
Before setting up the project, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart](https://dart.dev/) (included with Flutter)
- A code editor like [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
- An emulator (e.g., Android Emulator, iOS Simulator) or a physical device for testing
- [Git](https://git-scm.com/) for cloning the repository
- (Optional) Backend setup: Ensure the [Exact Online Backend](https://github.com/johnchuma/exact-online-backend) is running if the frontend requires API connectivity

## Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/johnchuma/exact-online-frontend.git
   cd exact-online-frontend
   ```

2. **Install Dependencies**:
   Run the following command to install all required Flutter packages:
   ```bash
   flutter pub get
   ```

3. **Set Up Environment Variables**:
   - Create a `.env` file in the root directory (if required) to store API endpoints or other configurations.
   - Example `.env`:
     ```
     API_BASE_URL=http://localhost:3000/api
     ```
   - Use a package like [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) to load these variables.

4. **Verify Setup**:
   Ensure Flutter is correctly installed:
   ```bash
   flutter doctor
   ```
   Resolve any issues reported by `flutter doctor`.

## Running the App
1. **Start an Emulator or Connect a Device**:
   - For Android: Launch an emulator via Android Studio or connect an Android device.
   - For iOS: Open the iOS Simulator or connect an iOS device (macOS required).
   - For Web: Ensure Chrome is installed.

2. **Run the App**:
   - To run on a specific platform:
     ```bash
     flutter run
     ```
   - To run on a specific device (e.g., Chrome for web):
     ```bash
     flutter run -d chrome
     ```
   - To build a release version:
     ```bash
     flutter build apk  # For Android
     flutter build ios  # For iOS (macOS required)
     flutter build web  # For Web
     ```

3. **Hot Reload**:
   - While running, press `r` in the terminal to hot reload changes.
   - Press `R` to hot restart the app.

## Project Structure
```
exact-online-frontend/
├── lib/
│   ├── main.dart              # Entry point of the app
│   ├── models/                # Data models (e.g., User, Transaction)
│   ├── screens/               # UI screens (e.g., LoginScreen, DashboardScreen)
│   ├── services/              # API services and business logic
│   ├── widgets/               # Reusable UI components
│   ├── providers/             # State management (e.g., AuthProvider)
│   └── utils/                 # Helper functions and constants
├── assets/                    # Images, fonts, and other static assets
├── pubspec.yaml               # Dependencies and project configuration
├── .env                       # Environment variables (not tracked in Git)
└── README.md                  # This file
```

## API Integration
The frontend communicates with the [Exact Online Backend](https://github.com/johnchuma/exact-online-backend) via HTTP requests. Key details:
- **API Base URL**: Configured in `.env` (e.g., `http://localhost:3000/api`).
- **HTTP Client**: Uses [http](https://pub.dev/packages/http) or [dio](https://pub.dev/packages/dio) for API calls.
- **Endpoints**:
  - `POST /auth/login`: Authenticate a user
  - `GET /data`: Fetch data for the dashboard
  - (Add specific endpoints used by your app)
- **Authentication**: Stores tokens in secure storage using [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage).

To test API integration:
1. Ensure the backend is running (e.g., `npm start` in the backend repo).
2. Update `.env` with the correct API base URL.
3. Run the app and test features like login or data fetching.

## Contributing
We welcome contributions! To contribute:
1. Fork the repository: `https://github.com/johnchuma/exact-online-frontend`
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature"
   ```
4. Push to your fork:
   ```bash
   git push origin feature/your-feature
   ```
5. Open a Pull Request on GitHub.

### Note on Remotes
This repository is mirrored to two remotes:
- `origin`: `https://github.com/johnchuma/exact-online-frontend`
- `second`: `https://github.com/emcldeveloper/exactonlinefrontend`
To push to both:
```bash
git push origin main
git push second main
```
Or configure a single push to both (see backend documentation).

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
