import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isGuestKey = 'is_guest';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _tutorialCompleteKey = 'tutorial_complete';
  static const String _wallpaperColorsKey = 'wallpaper_colors';
  static const String _offlineModeKey = 'offline_mode';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // Guest mode
  static Future<void> setGuestMode(bool isGuest) async {
    await _prefs.setBool(_isGuestKey, isGuest);
  }

  static bool isGuestMode() {
    return _prefs.getBool(_isGuestKey) ?? false;
  }

  // Onboarding
  static Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingCompleteKey, complete);
  }

  static bool isOnboardingComplete() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  // Tutorial
  static Future<void> setTutorialComplete(bool complete) async {
    await _prefs.setBool(_tutorialCompleteKey, complete);
  }

  static bool isTutorialComplete() {
    return _prefs.getBool(_tutorialCompleteKey) ?? false;
  }

  // Wallpaper colors (adaptive theme)
  static Future<void> saveWallpaperColors(Map<String, dynamic> colors) async {
    await _prefs.setString(_wallpaperColorsKey, jsonEncode(colors));
  }

  static Future<Map<String, dynamic>?> getWallpaperColors() async {
    final colorsStr = _prefs.getString(_wallpaperColorsKey);
    if (colorsStr != null) {
      return jsonDecode(colorsStr) as Map<String, dynamic>;
    }
    return null;
  }

  // Offline mode
  static Future<void> setOfflineMode(bool offline) async {
    await _prefs.setBool(_offlineModeKey, offline);
  }

  static bool isOfflineMode() {
    return _prefs.getBool(_offlineModeKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}