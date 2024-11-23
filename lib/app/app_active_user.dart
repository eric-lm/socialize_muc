import 'package:firebase_auth/firebase_auth.dart';

class AppActiveUser {
  // Private constructor
  AppActiveUser._();

  // Singleton instance
  static final AppActiveUser instance = AppActiveUser._();

  // User storage with null safety
  User? _currentUser;

  // Getter for current user
  User? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Set current user
  void setUser(User user) {
    _currentUser = user;
  }

  // Clear user on logout
  void clearUser() {
    _currentUser = null;
  }

  // Get user ID safely
  String? get userId => _currentUser?.uid;

  // Get display name safely
  String? get displayName => _currentUser?.displayName;

  // Profile image storage
  String? _profileImageUrl;

  // Profile image getter
  String? get profileImageUrl => _profileImageUrl;

  // Set profile image
  void setProfileImage(String? imageUrl) {
    _profileImageUrl = imageUrl;
  }

  // Clear profile image
  void clearProfileImage() {
    _profileImageUrl = null;
  }
}
