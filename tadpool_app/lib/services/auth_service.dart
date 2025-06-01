import 'dart:convert';

import 'package:tadpool_app/services/url.dart';
import 'package:tadpool_app/store/user.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/utils/network_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API for handling user authenitcation
class AuthService {
  /// Register a new user with [email] and [password]. Parse auth token from
  /// the response and return it.

  static Future<String?> registerUser(
      {required String? email, required String? password}) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await NetworkUtil.post(URL.registerUrl,
        body: json.encode({
          'username': email,
          'email': email,
          'password': password,
          'fcm_token': fcmToken
        }));
    return response['token'];
  }

  /// Login with [email] and [password]. Returns the auth token parsed from
  /// response
  static Future<String?> loginUser({
    required String? email,
    required String? password,
  }) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final response = await NetworkUtil.post(URL.loginUrl,
          body: json.encode(
              {'email': email, 'password': password, 'fcm_token': fcmToken}));
      print("Login user response: $response");

      if (response['token'] == null) {
        print("Login failed: no token returned");
        return null;
      }

      final String token = response['token'];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('authToken', token);
      return response['token'];
    } catch (e) {
      print("loginUser error: $e");
      return null;
    }
  }

  /// Get a user data. Pass in [token] to authenticate.
  ///
  /// ```json
  /// {
  ///   id: 'id',
  ///   email: 'email'
  /// }
  /// ```
  static Future<User> getUser(String token) async {
    final response = await NetworkUtil.get(URL.userUrl,
        headers: NetworkUtil.buildTokenHeader(token));
    final user = User();
    user.loadFromJson(response);
    return user;
  }

  static Future<User> getUserWithBio(String token) async {
    final response = await NetworkUtil.get(
      URL.userBioUrl,
      headers: NetworkUtil.buildTokenHeader(token),
    );

    final user = User();
    user.loadFromJson(response['user']);

    final bio = response['bio'];
    final profileData = bio?['profile'];

    if (profileData != null) {
      user.profile = UserProfile();

      user.profile!.loadFromJson({
        ...profileData,
        'status': bio?['status'],
        'beliefs': bio?['beliefs'],
        'appearance': bio?['appearance'],
        'interests': bio?['interests'],
        'habits': bio?['habits'],
        'personality': bio?['personality'],
        'hobbies_collecting': bio?['hobbies_collecting'],
        'travel': bio?['travel'],
      });
    }

    return user;
  }

}
