# Campus Second-Hand Market

A campus second-hand marketplace mobile app built with Flutter and Firebase, designed for university students to buy and sell used items within their own campus community.

| Feature | Description |
|---|---|
| Register / Login | Email & password auth via Firebase Auth. University is selected once at registration and stored in the user profile. |
| Homepage | Browse all listings. Filter by category (e.g. Books) or by university (e.g. UM) to find items from the same campus. Keyword search also available. |
| Product Detail | Full listing view — image, price, description, university, category. Tap Buy Now to proceed to payment. |
| Payment | Simulated payment flow: Buy Now → Confirm Payment → Success page. After payment, buyer contacts seller directly to arrange collection. |
| Upload Product | Post a listing with name, price, description, image, and category. University is auto-filled from the user profile.|
| User Profile | View account info, manage own listings. |
| Data Visualization | Dashboard showing total listings posted, a bar chart of product distribution by category... |
 
### Optional 
- **Search** — Search products by keyword on homepage
- **Favourites** — Tap ❤️ on any product to save it; tap again to unsave. Saved items appear in Profile.
- **Edit / Delete Product** — Manage own listings from Profile screen

## App Flow
```
    Register 
       ↓
     Login
       ↓
   Homepage  ←─────────────────────┐                                  
       ↓                           │
Product Detail               Upload Product                 
       ↓                           
    Buy Now
       ↓
    Payment 
       ↓
Payment Successful


  Profile Page
  ├── My Listings (Edit / Delete) 
  ├── Favourites List
  └── Data Visualization Dashboard
```
# Setup Guide

## Prerequisites
- Flutter SDK installed 
- VS Code Flutter & Dart extensions installed
- Android Studio installed with Android emulator 

### Create the Flutter project
Open PowerShell in the folder where you want the project:
```
flutter create campuswap
cd campuswap
```

### Install dependencies
```
flutter pub get
```

### Connect Flutter to Firebase
```
dart pub global activate flutterfire_cli
flutterfire configure
```

### Run the app
Start your Android emulator, then:
```
flutter run
```


## M2 & M3 
Put them in campuswap/.gitignore file:
  - lib/firebase_options.dart
  - android/app/google-services.json
