# 🔥 Firebase Setup Guide for Bookstore App

## 📋 Prerequisites
- Firebase project created: `bookstore-app-28217`
- Flutter app configured with Firebase
- Firebase CLI installed (optional but recommended)

## 🚀 Step-by-Step Setup

### 1. **Firebase Console Configuration**

#### A. Enable Authentication
1. Go to **Firebase Console** → **Authentication** → **Sign-in method**
2. Enable **Email/Password** authentication
3. Enable **Google** authentication:
   - Click "Enable"
   - Add your app's domain to authorized domains
   - Configure OAuth consent screen in Google Cloud Console

#### B. Create Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Start in test mode** (we'll secure it with rules)
3. Select a location close to your users
4. Click **Done**

#### C. Create Storage Bucket
1. Go to **Storage** → **Get started**
2. Choose **Start in test mode** (we'll secure it with rules)
3. Select the same location as Firestore
4. Click **Done**

### 2. **Implement Security Rules**

#### A. Firestore Security Rules
1. Go to **Firestore Database** → **Rules**
2. Replace the existing rules with the content from `firestore.rules`
3. Click **Publish**

#### B. Storage Security Rules
1. Go to **Storage** → **Rules**
2. Replace the existing rules with the content from `storage.rules`
3. Click **Publish**

### 3. **Create Initial Data Structure**

#### A. Create Categories Collection
```javascript
// In Firestore Console, create a document in 'categories' collection:
{
  "name": "Fiction",
  "createdAt": Timestamp.now()
}

{
  "name": "Non-Fiction", 
  "createdAt": Timestamp.now()
}

{
  "name": "Science Fiction",
  "createdAt": Timestamp.now()
}

{
  "name": "Mystery",
  "createdAt": Timestamp.now()
}

{
  "name": "Romance",
  "createdAt": Timestamp.now()
}
```

#### B. Create Sample Books
```javascript
// In Firestore Console, create documents in 'books' collection:
{
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "description": "A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.",
  "coverImage": "https://example.com/gatsby.jpg",
  "price": 12.99,
  "genres": ["Fiction", "Classic"],
  "stock": 50,
  "rating": 4.5,
  "reviewCount": 120,
  "releaseDate": Timestamp.fromDate(new Date("1925-04-10")),
  "isBestseller": true,
  "isNewArrival": false,
  "isbn": "978-0743273565",
  "pageCount": 180,
  "publisher": "Scribner",
  "language": "English",
  "format": "Paperback",
  "isActive": true,
  "createdAt": Timestamp.now(),
  "updatedAt": Timestamp.now()
}
```

### 4. **Create Admin User**

#### A. Create Admin User Document
```javascript
// In Firestore Console, create a document in 'users' collection:
// Use your Firebase Auth UID as the document ID
{
  "id": "YOUR_FIREBASE_AUTH_UID",
  "name": "Admin User",
  "email": "admin@bookstore.com",
  "photoUrl": null,
  "phoneNumber": null,
  "addresses": [],
  "paymentMethods": [],
  "isAdmin": true,
  "createdAt": Timestamp.now(),
  "updatedAt": Timestamp.now()
}
```

### 5. **Test Security Rules**

#### A. Test User Access
1. Sign in with a regular user account
2. Try to:
   - Read books (should work)
   - Create a book (should fail)
   - Update your profile (should work)
   - Read other users' data (should fail)

#### B. Test Admin Access
1. Sign in with an admin account
2. Try to:
   - Create/edit/delete books (should work)
   - Read all users (should work)
   - Manage categories (should work)

### 6. **Configure Google Sign-In (Optional)**

#### A. Get SHA-1 Fingerprint
```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

#### B. Add to Firebase Console
1. Go to **Project Settings** → **Your Apps** → **Android**
2. Add the SHA-1 fingerprint
3. Download updated `google-services.json`

#### C. Configure OAuth Consent Screen
1. Go to **Google Cloud Console** → **APIs & Services** → **OAuth consent screen**
2. Add your app domain
3. Add test users if needed

### 7. **Set Up Indexes (If Needed)**

Firestore will automatically suggest indexes when you run queries. Common indexes for your app:

```javascript
// Books collection indexes
Collection: books
Fields to index:
- genres (Array)
- isBestseller (Ascending)
- rating (Descending)
- releaseDate (Descending)
- title (Ascending)

// Orders collection indexes  
Collection: orders
Fields to index:
- userId (Ascending)
- createdAt (Descending)
- status (Ascending)
```

### 8. **Environment Variables (Optional)**

Create a `.env` file for sensitive data:
```env
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
```

## 🔒 Security Best Practices

### 1. **Data Validation**
- All user inputs are validated in security rules
- File uploads are restricted by size and type
- Admin functions require proper authentication

### 2. **Access Control**
- Users can only access their own data
- Admins have elevated privileges
- Public data (books, categories) is readable by all

### 3. **Rate Limiting**
- Consider implementing rate limiting for API calls
- Monitor usage in Firebase Console

### 4. **Backup Strategy**
- Enable Firestore backups
- Export data regularly
- Test restore procedures

## 🧪 Testing Your Setup

### 1. **Test Authentication**
```dart
// Test user registration
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'test@example.com',
  password: 'password123'
);

// Test Google Sign-In
await GoogleSignIn().signIn();
```

### 2. **Test Firestore Operations**
```dart
// Test reading books
final books = await FirebaseFirestore.instance
    .collection('books')
    .get();

// Test creating user profile
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(userData);
```

### 3. **Test Storage Operations**
```dart
// Test uploading image
final ref = FirebaseStorage.instance
    .ref()
    .child('book-covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
await ref.putFile(imageFile);
```

## 🚨 Troubleshooting

### Common Issues:

1. **Permission Denied Errors**
   - Check if user is authenticated
   - Verify security rules are published
   - Ensure user has proper permissions

2. **Google Sign-In Not Working**
   - Verify SHA-1 fingerprint is correct
   - Check OAuth consent screen configuration
   - Ensure Google Sign-In is enabled

3. **Storage Upload Failures**
   - Check file size (max 5MB)
   - Verify file type is image
   - Ensure user has upload permissions

4. **Admin Functions Not Working**
   - Verify user has `isAdmin: true` in their profile
   - Check if admin check function is working
   - Ensure proper authentication

## 📞 Support

If you encounter issues:
1. Check Firebase Console logs
2. Review security rules syntax
3. Test with Firebase Emulator
4. Check Flutter Firebase documentation

## 🔄 Next Steps

1. **Set up Stripe integration** with proper backend
2. **Configure push notifications**
3. **Set up analytics and monitoring**
4. **Implement backup strategies**
5. **Add more security features** (2FA, etc.)

---

**Last Updated**: June 18, 2025 