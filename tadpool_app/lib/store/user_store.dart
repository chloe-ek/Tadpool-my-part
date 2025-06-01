import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadpool_app/services/auth_service.dart';
import 'package:tadpool_app/store/user.dart';

part 'user_store.g.dart';

class UserStore extends _UserStore with _$UserStore {}

enum UserStoreStatus {
  pending,
  logged_in_with_profile,
  logged_in_without_profile,
  not_logged_in
}

abstract class _UserStore with Store {
  static const TOKEN_KEY = 'token';

  @observable
  User? currentUser;
  @observable
  UserStoreStatus? userStoreStatus;

  /// Login user with [email] and [password]. Then, store the auth token in the
  /// shared preference and call the `fetchUser` method to update the
  /// `currentUser` and `userStoreStatus` class.
  @action
  Future<void> loginUser({
    required String? email,
    required String? password,
  }) async {
    print("[user_store] loginUser() called");
    final token = await AuthService.loginUser(email: email, password: password);
    print("[user_store] token from AuthService: $token");

    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(TOKEN_KEY, token);
      print("[user_store] token saved to SharedPreferences");

      try {
        print("[user_store] calling fetchUser()");
        await fetchUser();
      } catch (e) {
        print("[user_store] fetchUser failed: $e");
        userStoreStatus = UserStoreStatus.not_logged_in;
        throw Exception("Failed to fetch user profile.");
      }
    } else {
      print("[user_store] token is null");
      userStoreStatus = UserStoreStatus.not_logged_in;
      throw Exception("Login failed: token is null.");
    }
  }

  /// Register a new user with  with [email] and [password].
  /// Then, store the auth token in the shared preference.
  /// Then, call the `fetchUser` method to update the
  /// `currentUser` and `userStoreStatus` class.
  @action
  Future<void> signUpUser(
      {required String? email, required String? password}) async {
    final token =
        await AuthService.registerUser(email: email, password: password);

    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(TOKEN_KEY, token);
      await fetchUser();
    }
  }

  /// Fetch the existing user using a token stored in shared preference.
  ///
  /// If the token doesn't exist in the shared preference, the user is not
  /// logged in. If the token exists, pass in token to `getUser` API service
  /// to fetch the user object.
  @action
  Future<User?> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN_KEY);

    print("[fetchUser] token from SharedPreferences: $token");

    if (token == null) {
      print("[fetchUser] Token is null. Not logged in.");
      userStoreStatus = UserStoreStatus.not_logged_in;
      throw Exception("Token not found.");
    }

    try {
      userStoreStatus = UserStoreStatus.pending;
      currentUser = await AuthService.getUserWithBio(token);

      final hasProfile = currentUser?.hasProfile ?? false;
      userStoreStatus = hasProfile
          ? UserStoreStatus.logged_in_with_profile
          : UserStoreStatus.logged_in_without_profile;

      print("[fetchUser] hasProfile: $hasProfile");
      print("[fetchUser] Status: $userStoreStatus");

      return currentUser;
    } catch (e) {
      print("[fetchUser] error: $e");
      throw Exception("Failed to fetch user from token.");
    }
  }
}
