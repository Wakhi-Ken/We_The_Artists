# Artist Account - Flutter Application

A fully functional artist profile and social feed application built with Flutter, implementing clean architecture and BLoC state management.

## Features

### Implemented Functionality

1. **Artist Profile Screen**
   - Profile header with avatar, name, role, and location
   - Editable bio section
   - Edit Profile button with navigation
   - Posts/Media tab navigation

2. **Interactive Post Features**
   - Like button with red heart animation and counter
   - Comment button with bottom sheet modal
   - Share functionality using native share dialog
   - Save/Bookmark button with state persistence
   - Three-dot menu for additional options

3. **Edit Profile**
   - Fully functional edit screen
   - Text fields for name, role, location, and bio
   - Save functionality with success feedback
   - Close/Cancel option

4. **State Management**
   - BLoC pattern implementation
   - Event-driven architecture
   - Proper state handling for all interactions

5. **Clean Architecture**
   - Presentation layer (screens, widgets, BLoC)
   - Domain layer (entities)
   - Proper separation of concerns

## Project Structure

```
lib/
├── domain/
│   └── entities/
│       ├── post_entity.dart
│       └── user_entity.dart
├── presentation/
│   ├── bloc/
│   │   ├── post_bloc.dart
│   │   ├── post_event.dart
│   │   └── post_state.dart
│   ├── screens/
│   │   ├── my_account_screen.dart
│   │   └── edit_profile_screen.dart
│   └── widgets/
│       ├── post_card.dart
│       └── profile_header.dart
└── main.dart
```

## Dependencies

- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality for BLoC
- `share_plus: ^10.1.2` - Native sharing functionality
- `intl: ^0.19.0` - Date formatting

## Setup Instructions

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Add images (optional):
   - Place `tulip_painting.jpg` in `assets/images/` folder

4. Run the app:
   ```bash
   flutter run
   ```

## UI Components

### Profile Header
- Gradient avatar with initials
- User name, role, and location
- Bio text
- Edit Profile button

### Post Card
- User information header
- Post content with hashtags
- Image display (if available)
- Interactive action buttons:
  - Like (heart icon, turns red when active)
  - Comment (opens modal sheet)
  - Share (native share dialog)
  - Save (bookmark icon, turns blue when saved)

### Edit Profile Screen
- Profile picture with camera icon
- Editable text fields for name, role, location, and bio
- Save and Cancel actions

## Interactive Features

1. **Like System**
   - Tap heart icon to like/unlike
   - Icon changes from outline to filled
   - Color changes to red when liked
   - Like count updates in real-time

2. **Comment System**
   - Tap comment icon to open comments sheet
   - Draggable bottom sheet modal
   - Placeholder for future comments

3. **Share Functionality**
   - Tap share icon to open native share dialog
   - Shares post content and author

4. **Save/Bookmark**
   - Tap bookmark icon to save/unsave
   - Icon changes from outline to filled
   - Color changes to blue when saved

5. **Options Menu**
   - Three-dot menu in app bar
   - Options: Settings, Share Profile, Block, Report

## State Management

The app uses BLoC pattern for state management:

- **Events**: LoadPosts, ToggleLike, ToggleSave, SharePost, OpenComments
- **States**: PostInitial, PostLoading, PostLoaded, PostError
- **BLoC**: PostBloc manages all post-related state

## Navigation

- Main screen → Edit Profile (via Edit Profile button)
- Smooth transitions with Material page routes
- Back navigation properly implemented

## Code Quality

- Zero lint errors (verified with `dart analyze`)
- Clean architecture principles
- Separation of concerns
- Reusable widgets
- Proper naming conventions

## Author

Created as part of a group project demonstrating Flutter development skills with clean architecture and BLoC pattern.
