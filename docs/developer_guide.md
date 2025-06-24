# Book Store App - Developer Guide

## Project Overview
A Flutter app for browsing, purchasing, and managing books, with a simulated payment and admin dashboard.  
All data is local (Provider + SharedPreferences).  
Open Library is used for book data.

---

## Tech Stack
- **Flutter** (Dart)
- **Provider** (state management)
- **SharedPreferences** (local storage)
- **Open Library API** (book data)
- **Material Design**

---

## Directory Structure
```
lib/
├── models/           # Data models (Book, Order, etc.)
├── providers/        # State management (AppProvider, CartProvider, ProfileProvider)
├── screens/          # UI screens (home, store, cart, profile, admin_dashboard)
├── services/         # Business logic (auth_service, open_library_service)
├── theme/            # App theming
├── widgets/          # Reusable UI components
```

---

## Key Components
- **AppProvider:**  
  - Manages books, user library, wishlist, favorites, and authentication state.
- **CartProvider:**  
  - Manages cart items and checkout.
- **ProfileProvider:**  
  - Manages user profile and order history.
- **AdminDashboardScreen:**  
  - Analytics and user overview for admin.

---

## State Management
- Uses **Provider** for all app state.
- All user data (library, wishlist, favorites, orders) is stored in SharedPreferences.

---

## Setup & Running
1. **Install Flutter SDK** (3.2+ recommended)
2. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd bookstore_app
   ```
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Run the app**
   ```bash
   flutter run
   ```

---

## Adding Features
- **To add a new screen:**  
  - Create a new file in `lib/screens/`
  - Add a route in `main.dart`
- **To add a new provider:**  
  - Create in `lib/providers/`
  - Register in `main.dart` with `MultiProvider`

---

## Testing
- Use `flutter test` for unit tests (add tests in `test/` directory).
- UI can be tested with `flutter run` and hot reload.

---

## Admin Features
- Log in as `admin@bookstore.com` to access the admin dashboard.
- Analytics and user overview are based on local order history.

---

## Troubleshooting
- **Data not saving:**  
  - Ensure SharedPreferences is working and not cleared.
- **Admin dashboard not visible:**  
  - Make sure you are logged in as `admin@bookstore.com` and have set your profile email accordingly.

---

## Notes
- No real backend, payment, or user management is implemented.
- All data is local and for demo/development only.

---

_Last updated: June 2025_