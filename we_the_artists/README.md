# We The Artists

**We The Artists** is a social platform for artists to grow creatively and professionally.  

### Key Uses

- **Showcase Art:** Share images, videos, and audio of your work with tags.  
- **Get Feedback:** Receive constructive comments to improve your skills.  
- **Connect & Collaborate:** Find peers and collaborate on projects.  
- **Learn & Grow:** Access tutorials, workshops, and tips to monetize art.  
- **Wellness Support:** Read motivational content and manage creative stress.  
- **Profile Management:** Build a portfolio, manage posts, and showcase achievements.  
- **Engagement:** Receive notifications and bookmark inspiring works.  
- **Discover Events:** Find local and online workshops for skill development.  

**✅ One platform to share, learn, collaborate, and thrive as an artist.**

---

## Features

* User authentication (Sign up / Log in)
* Create posts with images and videos
* Add tags to posts
* View and manage your own posts and profile
* Browse other artists and discover content
* Notifications for interactions
* Dark and light theme support

---

## Project Structure

The `lib/` folder contains the main application code:

* `domain/` – Entity models (e.g., post_entity, user_entity, comment_entity)
* `presentation/` – UI and presentation layer

  * `bloc/` – Bloc state management for posts, users, themes, notifications
  * `screens/` – All screen widgets (home feed, profile, create post, messages, etc.)
  * `widgets/` – Reusable UI components (e.g., PostCard, ProfileHeader)
  * `utils/` – Utility helpers
* `providers/` – Service providers (authentication, posts, users)
* `services/` – Service classes for Firebase interactions
* `screens/auth/` – Login and signup screens
* `firebase_options.dart` – Firebase configuration

---

## Getting Started

These instructions will help you run the project locally.

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* An editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
* Firebase project setup (Firestore and Storage)

### Installation

1. Clone this repository:

```bash
git clone https://github.com/Wakhi-Ken/We_The_Artists/tree/main
cd we_the_artists
```

2. Install dependencies:

```bash
flutter pub get
```

3. Make sure Firebase is configured correctly:

* Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
* Update `firebase_options.dart` using the FlutterFire CLI if needed.

---

### Running the App

Run the application on your connected device or emulator:

```bash
flutter run
```

For specific platforms:

* **Android**: `flutter run -d android`
* **iOS**: `flutter run -d ios`
* **Web**: `flutter run -d chrome`

---

### Notes

* Posts support **images and videos only**.
* Tags can be added to posts with a maximum of 20 characters.
* The app uses **Bloc pattern** for state management.
* Theme can be toggled between light and dark modes.

---

## Resources

* [Flutter Documentation](https://docs.flutter.dev/)
* [Firebase Documentation](https://firebase.google.com/docs)
* [Bloc Package](https://pub.dev/packages/flutter_bloc)

---

## Contributing

Feel free to submit issues or pull requests if you find bugs or want to improve the app.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
