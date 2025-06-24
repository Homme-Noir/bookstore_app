# API Documentation

## Overview
All data operations are handled **locally in Dart** using Provider and SharedPreferences.  
There are **no real network or backend API calls**.  
All data is lost if the app is uninstalled or local storage is cleared.

---

## Authentication
- **Login:**  
  - Any email/password combination is accepted for demo purposes.
  - Logging in as `admin@bookstore.com` enables admin features.
- **Register:**  
  - Registration is simulated; no real user database.

---

## Books
- **Get all books:**  
  - Books are fetched from Open Library API at runtime and cached locally.
- **Get book by ID:**  
  - Books are identified by their Open Library ID.
- **Add to library:**  
  - User must "purchase" (simulated payment) before adding a book to their library.
- **Wishlist/Favorites:**  
  - Add/remove books to/from wishlist and favorites, stored locally.

---

## Cart & Checkout
- **Add to cart:**  
  - Books can be added to a cart for simulated checkout.
- **Checkout:**  
  - Simulates a $5 payment per book, then adds books to the user's library and order history.

---

## Orders
- **Order history:**  
  - Each checkout creates an order, stored locally in the user's order history.
- **Order details:**  
  - Each order contains a list of books, total amount, and timestamp.

---

## Admin Dashboard
- **Access:**  
  - Only visible for `admin@bookstore.com`.
- **Features:**  
  - User overview (current user only in local mode)
  - Analytics: total orders, total sales, most popular books

---

## Error Handling
- Most errors are shown as SnackBars in the UI.
- No persistent error logs.

---

## Notes
- **No real API endpoints exist.**  
- **No data is persisted to a backend.**  
- **All logic is handled in Dart code and local storage.**

---

_Last updated: June 2025_ 