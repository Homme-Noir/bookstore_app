# API Documentation (Mock/In-Memory)

## Overview
All API calls are now handled in-memory using mock data. There are **no network or backend calls**. All data is lost on app restart.

## Authentication
- **Login:**
  - Use `john.doe@example.com` (test user) or `admin@bookstore.com` (admin user) with any password.
  - Logging in as admin redirects to the admin dashboard; test user goes to the home screen.
  - To add more users, edit `MockData.users` in `lib/mock_data.dart`.
- **Register:**
  - Only works for emails present in `MockData.users`.

## Books
- **Get all books:** Returns the list from `MockData.books`.
- **Get book by ID:** Looks up a book in `MockData.books`.
- **Add/update/delete book:** Only available to admin user; modifies the in-memory list.

## Categories
- **Get all categories:** Returns a static list from the provider or `BookService`.
- **Add/update/delete category:** Only available to admin user; modifies the in-memory list.

## Cart
- **Add to cart, remove from cart, update quantity, clear cart:** All operations are in-memory and per session.

## Orders
- **Place order:** Creates an in-memory order for the current user.
- **Get user orders:** Returns orders for the current user from the in-memory list.
- **Get all orders:** Only available to admin user.

## Wishlist
- **Add/remove/check wishlist:** All operations are in-memory and per session.

## Reviews
- **Add/retrieve reviews:** All operations are in-memory and per session.

## Error Handling
- If you try to log in with an email not in `MockData.users`, you get an error.
- All other errors are handled in-memory and do not affect persistent state.

## Notes
- **No data is persisted.** All data is lost when the app restarts.
- **No real API endpoints exist.** All logic is handled in Dart code.

---

# (Legacy) Firebase/Stripe API (No Longer Used)
<!--
## Firebase/Firestore/Stripe API
... (remove or comment out all Firebase/Firestore/Stripe API documentation) ...
-->

---

**Last Updated**: June 18, 2025 