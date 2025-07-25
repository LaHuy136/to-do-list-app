# 📱 To-Do List Frontend (Flutter)

This is the Flutter frontend of the To-Do List application. It connects to a RESTful backend (Node.js) to manage personal tasks.

## 🧰 Technologies

- Flutter v3.29.2
- Dart
- `http` package for REST API communication

## 🔧 Requirements

- Flutter SDK installed
- Dart => 3x
- Android/iOS device or emulator

## 🚀 Setup Instructions

### 1. Clone the repository

```bash
https://github.com/LaHuy136/to-do-list-app.git
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API URL

```dart
const String apiUrl = "http://<BACKEND_IP>:3000";
```

#### ⚠️ Note:

##### Do NOT use localhost when running on a physical device.

##### Use your local network IP address (e.g. 192.168.1.10) to access the backend from Flutter.

### 4. Run the application

```bash
flutter run  
```
