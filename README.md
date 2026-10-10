# HomeServe — Home Service Booking App

HomeServe is a Flutter-based home service booking application powered by Firebase. It connects customers with service providers for everyday home maintenance and repair needs, including plumbing, electrical work, cleaning, and handyman services.

The application provides dedicated experiences for **Customers, Service Providers, and Administrators**, with role-based access, booking management, provider verification, and real-time notifications.

## ✨ Features

### 👤 Customer

- **Service Discovery:** Browse services by category and search for suitable providers.
- **Booking Management:** Schedule services for specific dates and times, including urgent service requests.
- **Booking Tracking:** Monitor booking progress from pending and confirmed to in progress and completed.
- **Payment Options:** Complete the booking payment flow using the payment methods supported by the application.
- **Reviews & Ratings:** Submit feedback and rate providers after completed services.
- **Complaints Management:** Submit complaints about completed services and track their resolution.
- **Profile Management:** Manage personal information and account settings.
- **Notifications:** Receive updates about bookings and other relevant activities.

### 🛠️ Service Provider

- **Provider Verification:** Submit an application and wait for administrator approval before accessing provider features.
- **Dashboard:** View relevant booking information, completed jobs, and available performance statistics.
- **Booking Management:** Review incoming requests and accept, reject, or manage bookings.
- **Service Profile:** Manage service details, experience, pricing, service areas, and profile information.
- **Availability Management:** Configure availability and service coverage where supported.
- **Notifications:** Receive updates about booking requests and related activities.

### 👑 Administrator

- **User Management:** View and manage customer and provider accounts.
- **Provider Verification:** Review applications and approve or reject providers.
- **Booking Oversight:** Monitor booking activity and related status updates.
- **Complaint Management:** Review and manage customer complaints.
- **Notifications:** View system-related notifications and important events.
- **Account Management:** Manage access and account status using the available administrative features.

## 🧰 Technology Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform application development |
| [Dart](https://dart.dev/) | Application programming language |
| [Firebase Authentication](https://firebase.google.com/docs/auth) | User authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | NoSQL database and real-time data |
| [Firebase CLI](https://firebase.google.com/docs/cli) | Firebase project management and configuration |

**State management:** `StreamBuilder` and `ChangeNotifier`, as used in the application.

**UI framework:** Flutter Material components with a custom theme and reusable widgets.

## 🏗️ Application Architecture

HomeServe follows a role-based application structure with separate interfaces for customers, service providers, and administrators.

- **Presentation layer:** Screens, forms, dashboards, and reusable widgets.
- **Business logic layer:** Services responsible for authentication, bookings, notifications, and other application operations.
- **Data layer:** Firebase Authentication and Cloud Firestore.
- **Navigation layer:** Centralized route configuration and role-based navigation.

## 📂 Project Structure

```text
homeserve_app/
├── android/
├── ios/
├── lib/
│   ├── models/          # Application data models
│   ├── routes/          # Navigation and route configuration
│   ├── screens/
│   │   ├── admin/       # Administrator screens
│   │   ├── auth/        # Login and registration
│   │   ├── booking/     # Booking and tracking screens
│   │   ├── home/        # Customer home and search
│   │   ├── provider/    # Provider dashboard and requests
│   │   └── notifications/
│   │                     # Notification screens
│   ├── services/        # Application and Firebase services
│   ├── theme/           # Colors, typography, and app theme
│   └── widgets/         # Reusable UI components
├── assets/              # Images, icons, and other assets
├── pubspec.yaml         # Dependencies and project configuration
└── README.md
```

*The structure above represents the main application organization. Actual files and directories may vary by project version.*

## 🚀 Getting Started

### Prerequisites

Before running HomeServe, install and configure:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) — normally included with Flutter
- [Android Studio](https://developer.android.com/studio) or another supported IDE
- An Android emulator or a physical Android device
- A [Firebase project](https://console.firebase.google.com/) with the required services enabled

For iOS development, a Mac with Xcode is required.

### 1. Clone the Repository

```bash
git clone https://github.com/Janith854/homeserve_app.git
cd homeserve_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Connect the application to the appropriate Firebase project.

- **Android:** Place the Firebase Android configuration file at `android/app/google-services.json`.
- **FlutterFire:** Ensure `lib/firebase_options.dart` contains the correct configuration for the target platforms.
- **Firebase Authentication:** Enable the authentication providers required by the application.
- **Cloud Firestore:** Create the database and deploy appropriate security rules.

For iOS, configure `GoogleService-Info.plist` and the required platform-specific Firebase settings if iOS support is enabled.

> **Security:** Never commit service-account private keys, passwords, or other secrets. Keep Firestore security rules restrictive and validate authorization on the backend. Firebase client configuration files are not substitutes for security rules.

### 4. Check the Development Environment

```bash
flutter doctor
flutter devices
```

Resolve any required setup issues and ensure that your target device is available.

### 5. Run the Application

```bash
flutter run
```

To target a specific connected device:

```bash
flutter run -d <device_id>
```

### 6. Build an Android APK

To generate a release APK:

```bash
flutter build apk --release
```

The APK is normally generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🔔 Notification System

HomeServe includes a notification interface designed to keep users informed about relevant application activity.

Depending on the configured notification events, supported functionality includes:

- Booking and application updates.
- Role-specific notifications.
- Real-time notification updates.
- Unread notification indicators.
- Opening relevant screens from actionable notifications.
- Selecting and deleting multiple notifications.
- Clearing notifications in bulk.

Notification visibility and actions should follow the application's authentication and authorization rules.

## 🔄 Typical Booking Workflow

1. A customer browses available services.
2. The customer selects a provider and submits a booking request.
3. The booking is created with its initial status.
4. The provider reviews the request and accepts or rejects it.
5. The customer tracks booking progress.
6. The booking moves through the applicable service statuses.
7. After completion, the customer can submit a review or file a complaint when appropriate.

Actual status transitions depend on the application's implemented business rules.

## 🔐 Security and Data Management

- Authenticate users through Firebase Authentication.
- Apply role-based access controls for customers, providers, and administrators.
- Configure Firestore security rules to restrict unauthorized access.
- Validate important operations and permissions.
- Protect account-related actions and sensitive user information.
- Preserve relevant booking and transaction history when managing accounts.

## 🧪 Testing and Troubleshooting

Run static analysis:

```bash
flutter analyze
```

Run automated tests:

```bash
flutter test
```

If dependencies or build artifacts cause issues, try:

```bash
flutter clean
flutter pub get
flutter run
```

For Firebase-related errors, verify the Firebase project configuration, enabled authentication providers, Firestore rules, and Android Google Services plugin configuration.

## 🗺️ Future Improvements

Potential improvements include:

- Online payment gateway integration.
- Enhanced provider availability and scheduling.
- Advanced search and filtering.
- Improved booking analytics and reporting.
- Automated testing and continuous integration.
- Additional accessibility and usability improvements.

These items are potential enhancements and should not be interpreted as already implemented.

## 📄 License

This project is distributed under the MIT License if the repository's `LICENSE` file specifies that license. See the `LICENSE` file for the applicable terms.

## 👨‍💻 Repository

**GitHub:** [Janith854/homeserve_app](https://github.com/Janith854/homeserve_app)

---

*HomeServe — Making home services easier to discover, book, and manage.*
