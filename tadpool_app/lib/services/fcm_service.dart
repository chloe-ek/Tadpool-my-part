import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tadpool_app/services/url.dart';

Future<void> sendNotification(
    String fcmToken, String title, String body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  if (token == null) {
    throw Exception("Authentication token not found");
  }

  final headers = {
    'Content-Type': 'application/json',
    "Authorization": "Token $token"
  };

  final payload = {
    'notification': {'title': title, 'body': body},
    'data': {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done'
    },
    'receiver_token': fcmToken,
  };

  final response = await http.post(
    Uri.parse(URL.baseUrl + ("/send-notification")),
    headers: headers,
    body: json.encode(payload),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

Future<String> fetchFcmToken(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot userDoc =
      await firestore.collection('users').doc(userId).get();

  final data = userDoc.data();
  print("User Document for $userId: $data");

  if (data == null) {
    return '';
  }

  final fcmToken = (data as Map<String, dynamic>)['fcmToken'] ?? '';
  return fcmToken;
}
