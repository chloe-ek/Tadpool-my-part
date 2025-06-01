import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tadpool_app/constants/style_constants.dart';
import 'matching_google_map.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:provider/provider.dart';


class MatchingNotification extends StatelessWidget {
  static const routeName = "matchingNotification";

  const MatchingNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userStore = context.read<UserStore>();
    final currentUser = userStore.currentUser;
    final facePictureUrl = currentUser?.profile?.facePictureUrl;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 125,
            right: 0,
            left: 0,
            child: Center(
              child: Text(
                "You've found your frog 🎉",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            top: 175,
            right: 0,
            left: 0,
            child: Center(
              child: Text(
                "You and George have liked each other",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            top: 225,
            right: 32,
            left: 32,
            child: Center(
              child: _matchImages(facePictureUrl),
            ),
          ),
          Positioned(
            top: 425,
            right: 32,
            left: 32,
            child: Center(
              child: _buttonLocation(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchImages(String? facePictureUrl) {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (facePictureUrl != null && facePictureUrl.isNotEmpty)
                        ? NetworkImage(facePictureUrl)
                        : AssetImage("assets/images/match_profilev.png")
                            as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/froggy.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 25,
            left: 25,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/green-love.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonLocation(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 5.0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: MaterialButton(
        minWidth: 10,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        },
        child: Text(
          "See the location!",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
