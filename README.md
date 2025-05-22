# Flutter Traffic Dashcam

## Screenshots

Below are some screenshots demonstrating key features and recent changes. Please ensure new screenshots are added to the `screenshots/` folder and referenced here with descriptive captions.

| Home Screen                        | Video Playback                     | Extracted Text View                |
|-------------------------------------|------------------------------------|------------------------------------|
| **Home screen with video list**     | **Playing a recorded dashcam video** | **Viewing extracted text from video** |
| ![Home Screen](screenshots/home-screen.png) | ![Video Playback](screenshots/video-playback.png) | ![Extracted Text](screenshots/extracted-text.png) |

---

## Project Description

Flutter Traffic Dashcam is a mobile application that allows users to record dashcam videos, manage their recordings, and extract text from video frames using OCR. The app is built with Flutter and leverages Hive for local data storage.

## Features

- Record and save dashcam videos locally
- Mark favorite videos for quick access
- Extract and view text from video frames (OCR)
- Responsive and intuitive user interface
- Persistent storage using Hive database
- Riverpod for state management

## Project Overview for New Contributors

This section provides a high-level overview of the codebase to help new contributors quickly understand the architecture and structure.

### Major Folders & Files

- **lib/**: Main source code for the Flutter app.
  - **main.dart**: Entry point of the application. Initializes Hive, registers adapters, and sets up the app's root widget.
  - **Model/**: Contains data models (e.g., `video_model.dart`, `extracted_text_model.dart`) used throughout the app.
  - **Adapter/**: Custom Hive adapters for serializing/deserializing complex types (e.g., `duration_adapter.dart`).
  - **routes/**: App routing configuration.
- **screenshots/**: Contains screenshots referenced in the README for documentation and PRs.
- **pubspec.yaml**: Lists dependencies and project metadata.

### Architecture

- **Frontend**: Built with Flutter, using Material Design widgets for UI.
- **State Management**: Uses Riverpod for managing app state.
- **Database**: Uses Hive for local, persistent storage of videos and extracted text.
- **Routing**: Managed via a centralized router in `routes/route.dart`.

### Component Interaction

- The app starts in `main.dart`, initializing Hive and registering data adapters.
- Models define the structure of stored data.
- UI screens interact with the database via Riverpod providers.
- Extracted text is generated from videos and stored for later viewing.

---

## Getting Started

Follow these steps to set up your development environment and run the project locally:

1. **Clone the repository**
   ```sh
   git clone https://github.com/yourusername/flutter_traffic_dashcam.git
   cd flutter_traffic_dashcam
   ```

2. **Install Flutter**
   - Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

3. **Install dependencies**
   ```sh
   flutter pub get
   ```

4. **Run the app**
   - Connect a device or start an emulator.
   ```sh
   flutter run
   ```

5. **(Optional) Generate Hive Type Adapters**
   - If you add new models, run:
   ```sh
   flutter packages pub run build_runner build
   ```

---

## Roadmap

- [ ] Cloud backup and sync
- [ ] Advanced search and filtering
- [ ] Improved OCR accuracy
- [ ] User authentication
- [ ] Export/share videos and extracted text

---

## Contributing

We welcome contributions! Please read the guidelines below before submitting a pull request.

### Contributing Guidelines

- Every pull request (PR) **must include relevant app screenshots** showing the changes made.
- Add these screenshots to the `screenshots/` folder in the repository.
- Update the **Screenshots** section in the README to include the new screenshots with appropriate captions or context.
- Ensure screenshots are clearly labeled (e.g., `feature-login.png`, `fix-navbar-bug.png`) and correspond to the PR functionality.
- Screenshots should be displayed side by side responsively in a table format.

---

Thank you for your interest in contributing to Flutter Traffic Dashcam!
