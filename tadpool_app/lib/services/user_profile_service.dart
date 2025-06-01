import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadpool_app/services/url.dart';
import 'package:tadpool_app/store/user.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/utils/network_util.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'; // for BuildContext
import 'package:tadpool_app/store/user_store.dart';

/// API for handling user profile creation
class UserProfileService {
  /// Create a user profile with [userProfile]. Pass in [token] to authenticate
  static Future<void> createUserProfile({
    required BuildContext context,
    required UserProfile? userProfile,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Token $token",
    };

    final response = await NetworkUtil.post(
      URL.createProfileUrl,
      body: json.encode(userProfile?.toJson()),
      headers: headers,
    );

    if (!response['error']) {
      final userStore = Provider.of<UserStore>(context, listen: false);
      await userStore.fetchUser();
    }
  }
}
