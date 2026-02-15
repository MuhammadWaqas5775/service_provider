# Service Provider Mobile App

## Overview
A Flutter-based mobile application that allows users to discover local services (electrical, plumbing, carpentry, cleaning), book them with a preferred date and time, and enables admins to manage services and bookings — all powered by Firebase.

## Features
- **User Authentication** — Email/password login & signup via Firebase Auth
- **Service Listing** — Browse available services with icons, descriptions, and pricing
- **Service Booking** — Book any service with a date/time picker; bookings saved to Firestore
- **My Bookings** — View booking history with real-time status updates (pending, approved, cancelled)
- **Admin Panel** — Add, edit, and delete services; approve or cancel customer bookings
- **Role-Based Access** — Customers see the services & bookings screens; admins see the admin panel
- **Firestore Integration** — Real-time data with StreamBuilder for instant UI updates

## Tech Stack
| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| State Management | StreamBuilder (real-time) |
| Date Formatting | intl package |

## Project Structure
```
lib/
├── main.dart                   # App entry point & route definitions
├── login_page.dart             # Login screen with email/password
├── signup_page.dart            # Registration screen
├── home_page.dart              # Basic home screen
├── models/
│   ├── booking_model.dart      # Booking data model
│   ├── service_model.dart      # Service data model
│   └── user_model.dart         # User data model
└── screens/
    ├── services_screen.dart    # Service listing + booking + My Bookings tab
    ├── my_bookings_page.dart   # Standalone bookings view
    ├── admin_panel_screen.dart # Admin panel with tab navigation
    ├── admin_services_tab.dart # Admin CRUD for services
    └── admin_bookings_tab.dart # Admin booking management
```

## Screenshots
<!-- Add 2–3 screenshots of the app here -->
<!-- Example: ![Login Screen](screenshots/login.png) -->

## Setup
1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/service_provider.git
   cd service_provider
   ```
2. **Add Firebase config**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Email/Password** authentication
   - Create a **Cloud Firestore** database
   - Download and add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Run the app**
   ```bash
   flutter run
   ```

## Admin Access
To access the admin panel, set a user's `role` field to `"admin"` in the Firestore `users` collection.
