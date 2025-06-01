import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:tadpool_app/config/env_config.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:tadpool_app/widgets/date_plan_screen/date_map_screen.dart';
import 'package:tadpool_app/widgets/date_plan_screen/date_plan_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final analytics = FirebaseAnalytics.instance;
  final userStore = UserStore();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserStore>.value(value: userStore),
      ],
      child: MaterialApp(
        home: MyApp(analytics: analytics),
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  if (message.data['click_action'] == 'DATE_NOTIFICATION_CLICK') {
    print("Received DATE_NOTIFICATION_CLICK in the background");
  }
}

class MyApp extends StatefulWidget {
  final FirebaseAnalytics analytics;
  const MyApp({Key? key, required this.analytics}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _setupWebFirebaseMessaging();
    } else {
      _firebaseMessaging = FirebaseMessaging.instance;
      _configureFirebaseMessaging();
    }
  }

  void _configureFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  }

  void _setupWebFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    final token = await messaging.getToken(
      vapidKey: EnvConfig.firebaseWebPushCertificateKey,
    );
    print("Web FCM Token from VAPID key: $token");

    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print("Message received: ${message.notification?.title}");
    final action = message.data['click_action'];

    _showNotificationDialog(
        action, message.notification?.title, message.notification?.body);
  }

  void _handleMessageOpened(RemoteMessage message) {
    print("Notification clicked: ${message.notification?.title}");
    final action = message.data['click_action'];

    _showNotificationDialog(
        action, message.notification?.title, message.notification?.body);
  }

  void _showNotificationDialog(String? action, String? title, String? body) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        String header = "Someone sent you a date request!";
        Widget actionButton = TextButton(
          child: Text("Right", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.of(context).pop(),
        );

        if (action == 'FLUTTER_NOTIFICATION_CLICK') {
          header = "Match!";
          actionButton = TextButton(
            child: Text("Let's meet!", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => DatePlanScreen()));
            },
          );
        } else if (action == 'DATE_NOTIFICATION_CLICK') {
          header = "The date is set!";
          actionButton = TextButton(
            child: Text("Continue", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => MapScreen()));
            },
          );
        }

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Color(0xFF54DC4C), Color(0xFF216C01)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    header,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(body ?? "", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text("Left button",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actionButton,
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TadPoolApp(),
    );
  }
}
