import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tadpool_app/widgets/date_plan_screen/date_map_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadpool_app/config/env_config.dart';
import 'package:tadpool_app/services/url.dart';

class DatePlanScreen extends StatefulWidget {
  static const String routeName = '/date_plan';
  @override
  _DatePlanScreenState createState() => _DatePlanScreenState();
}

class _DatePlanScreenState extends State<DatePlanScreen> {
  List<String> _locations = [
    'Cafe',
    'Restaurant',
    'Bar',
    'Park',
    'Museum',
  ];
  List<String> _nearbyPlaces = [];
  String? _selectedLocation;
  String? _selectedNearbyPlace;

  @override
  void initState() {
    super.initState();
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _getNearbyPlaces(String locationType) async {
    Position position = await _getCurrentLocation();

    String apiKey = EnvConfig.googleMapsAPIKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=1500&type=$locationType&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    List<dynamic> results = data['results'];

    setState(() {
      _nearbyPlaces = results.map<String>((result) => result['name']).toList();
    });
  }

  Future<void> _saveSelectedLocationToDatabase() async {
    if (_selectedNearbyPlace == null) return;

    // Retrieve latitude and longitude for selected location
    String apiKey = EnvConfig.googleMapsAPIKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$_selectedNearbyPlace&inputtype=textquery&fields=geometry&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    final location = data['candidates'][0]['geometry']['location'];
    double latitude = location['lat'];
    double longitude = location['lng'];

    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
    ).ref().child('selected_location');

    await ref.set({
      'name': _selectedNearbyPlace,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff008000),
        title: Text('Choose a location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset(
                'assets/images/froggy.jpg',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            DropdownButton<String>(
              hint: Text("Select a location"),
              value: _selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue;
                });
              },
              items: _locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC2D565),
              ),
              onPressed: () {
                if (_selectedLocation != null) {
                  _getNearbyPlaces(_selectedLocation!.toLowerCase());
                }
              },
              child: Text("See what's nearby!"),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text("Select a nearby place"),
              value: _selectedNearbyPlace,
              items:
                  _nearbyPlaces.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedNearbyPlace = newValue;
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC2D565),
              ),
              onPressed: () async {
                await _saveSelectedLocationToDatabase();
                String fcmToken2 = await fetchFcmToken("tom@live.ca");
                print("FCM Token: " + fcmToken2);
                sendNotification2(
                    fcmToken2, "Get ready!", "The date with Bennifer is set!");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapScreen(),
                  ),
                );
              },
              child: Text("Let's go!"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> fetchFcmToken(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot userDoc =
      await firestore.collection('users').doc(userId).get();
  String fcmToken = (userDoc.data() as Map<String, dynamic>)['fcmToken'] ?? '';
  return fcmToken;
}

Future<void> sendNotification2(
    String fcmToken2, String title, String body) async {
  final headers = {
    'Content-Type': 'application/json',
  };

  final payload = {
    'notification': {
      'title': title,
      'body': body,
    },
    'data': {
      'click_action': 'DATE_NOTIFICATION_CLICK',
      'id': '2',
      'status': 'done',
    },
    'receiver_token': fcmToken2,
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
