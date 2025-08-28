# 📱 To-Do List Frontend (Flutter)

Đây là **ứng dụng Flutter** cho To-Do List.  
Ứng dụng kết nối với **RESTful backend (Node.js)** để quản lý công việc cá nhân.

---

## 🧰 Công nghệ sử dụng

- Flutter v3.29.2
- Dart
- Gói `http` để giao tiếp với REST API

---

## 🔧 Yêu cầu

- Cài đặt **Flutter SDK**
- Dart >= 3.x
- Thiết bị Android/iOS hoặc emulator

---

## 🚀 Hướng dẫn cài đặt

### 1. Tải dự án

```bash
git clone https://github.com/LaHuy136/to-do-list-app.git
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình địa chỉ API

```dart
const String baseUrl = "http://<BACKEND_IP>:3000";
```
