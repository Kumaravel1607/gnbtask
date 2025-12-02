# 🏠 Real Estate Flutter App (GNBTASK)

A comprehensive, responsive Real Estate application built with Flutter. This project demonstrates advanced mobile app features including infinite scrolling, complex filtering, deep linking via Push Notifications, image uploading, and analytics tracking.

The app is designed to run seamlessly on Android, iOS, and Web with responsive layouts for mobile and desktop views.

---

## ✨ Key Features

*   **📈 Infinite Scrolling**: Smooth pagination handling large datasets via `ListView.builder` and `GridView`.
*   **🔍 Advanced Filtering**: Filter properties by Price Range, Location, Status, and Tags with minimized API payloads.
*   **🌓 Dark/Light Mode**: Full theme support with persistent state using Provider.
*   **📱 Responsive Design**: Adaptive layouts that switch between List view (Mobile) and Grid view (Tablet/Desktop).
*   **🔔 Push Notifications**: Integrated Firebase Cloud Messaging (FCM) with Deep Linking to specific property details.
*   **📸 Image Upload**: Native Camera and Gallery integration using `image_picker` with backend upload support.
*   **📊 Analytics**: Custom analytics service tracking page views, time spent, and interaction events.
*   **🚀 Optimized Performance**: Image caching using `cached_network_image` and memory optimization.

---

## 📸 Demo Screenshots

*(Place your actual screenshots in an `assets/screenshots` folder or update these links)*

| Light Mode | Dark Mode | Filters |
|:---:|:---:|:---:|
| <img src="assets/screenshots/home_light.png" width="200"> | <img src="assets/screenshots/home_dark.png" width="200"> | <img src="assets/screenshots/filters.png" width="200"> |

| Property Detail | Upload Screen | Notification |
|:---:|:---:|:---:|
| <img src="assets/screenshots/detail.png" width="200"> | <img src="assets/screenshots/upload.png" width="200"> | <img src="assets/screenshots/notification.png" width="200"> |

---

## 🛠️ Setup Instructions

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x.x or higher)
*   [Android Studio](https://developer.android.com/studio) or VS Code
*   A Firebase Project (for Notifications)

