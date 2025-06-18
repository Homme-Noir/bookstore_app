# Bookstore App

A modern Flutter-based e-commerce application for buying and managing books. Built with Firebase backend services and following clean architecture principles.

## 🚀 Features

- **User Authentication**: Secure login/register with Firebase Auth
- **Book Browsing**: Browse books by categories, search, and filters
- **Shopping Cart**: Add, remove, and manage cart items
- **Order Management**: Place orders and track order status
- **Wishlist**: Save books for later purchase
- **User Profile**: Manage personal information and addresses
- **Payment Integration**: Stripe payment processing
- **Admin Panel**: Manage books, orders, and users (admin only)
- **Reviews & Ratings**: User reviews and ratings for books
- **Responsive Design**: Works on mobile, tablet, and web

## 🛠 Tech Stack

- **Frontend**: Flutter 3.2.3+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Payment**: Stripe
- **Authentication**: Firebase Auth + Google Sign-In
- **UI**: Material Design with Google Fonts

## 📱 Screenshots

*Screenshots will be added here*

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.2.3 or higher)
- Dart SDK
- Firebase account
- Stripe account (for payments)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Homme-Noir/bookstore_app.git
   cd bookstore_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and add configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Enable Firebase services: Auth, Firestore, Storage

4. **Configure Stripe** (for payments)
   - Add your Stripe publishable key to the app configuration

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── models/          # Data models (Book, User, Order, etc.)
├── screens/         # UI screens organized by feature
│   ├── auth/        # Authentication screens
│   ├── admin/       # Admin panel screens
│   ├── home/        # Home and navigation
│   ├── store/       # Book store and shopping
│   ├── profile/     # User profile management
│   ├── payment/     # Payment processing
│   ├── orders/      # Order management
│   └── wishlist/    # Wishlist functionality
├── services/        # Business logic and API calls
├── providers/       # State management
├── widgets/         # Reusable UI components
├── theme/           # App theming and styling
├── dialogs/         # Custom dialogs
└── firebase_options/ # Firebase configuration
```

## 📚 Documentation

- **[User Guide](docs/user_guide.md)** - Complete user manual
- **[Developer Guide](docs/developer_guide.md)** - Technical documentation for developers
- **[API Documentation](docs/api_documentation.md)** - Firebase Firestore collections and API endpoints

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## 📦 Building for Production

### Android
```bash
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **User Support**: Check the [User Guide](docs/user_guide.md)
- **Developer Support**: Check the [Developer Guide](docs/developer_guide.md)
- **Issues**: Report bugs and feature requests on GitHub Issues

## 🔗 Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Stripe Documentation](https://stripe.com/docs)

---

**Last Updated**: June 18, 2025