import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tadpool_app/store/user_profile.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:tadpool_app/widgets/account_created_screen.dart';
import 'package:tadpool_app/widgets/create_profile_screen/create_profile_screen.dart';
import 'package:tadpool_app/widgets/home_screen/home_screen.dart';
import 'package:tadpool_app/widgets/loading_screen.dart';
import 'package:tadpool_app/widgets/matches/matching_notification.dart';
import 'package:tadpool_app/widgets/photo_verification_screen.dart';
import 'package:tadpool_app/widgets/review_profile_screen/review_profile_screen.dart';
import 'package:tadpool_app/widgets/signup_screen.dart';
import 'package:tadpool_app/widgets/date_plan_screen/date_plan_screen.dart';
import 'package:tadpool_app/widgets/date_plan_screen/date_map_screen.dart';
import 'package:tadpool_app/widgets/profile_screen/face_verification_screen.dart';
import 'app_loc.dart';
import 'widgets/intro_screen/intro_screen.dart';
import 'widgets/login_screen.dart';

class TadPoolApp extends StatelessWidget {
  const TadPoolApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => UserStore(),
      child: MaterialApp(
        title: 'TadPool',
        initialRoute: IntroScreen.routeName,
        theme: ThemeData(
            fontFamily: 'Montserrat', scaffoldBackgroundColor: Colors.white),
        localizationsDelegates: const [
          AppLoc.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        routes: {
          LoadingScreen.routeName: (_) => LoadingScreen(),
          IntroScreen.routeName: (_) => IntroScreen(),
          LoginScreen.routeName: (_) => LoginScreen(),
          HomeScreen.routeName: (_) => HomeScreen(),
          SignupScreen.routeName: (_) => SignupScreen(),
          AccountCreatedScreen.routeName: (_) => AccountCreatedScreen(),
          CreateProfileScreen.routeName: (_) => Provider(
              create: (_) => UserProfile(), child: CreateProfileScreen()),
          // use navigator.push instead of routes
          // ReviewProfileScreen.routeName: (_) => const ReviewProfileScreen(),
          PhotoVerificationScreen.routeName: (_) => PhotoVerificationScreen(),
          DatePlanScreen.routeName: (_) => DatePlanScreen(),
          MapScreen.routeName: (_) => MapScreen(),
          MatchingNotification.routeName: (_) =>
              MatchingNotification(), // For testing purposes,
          FaceVerificationScreen.routeName: (_) => FaceVerificationScreen()
          
        },
      ),
    );
  }
}
