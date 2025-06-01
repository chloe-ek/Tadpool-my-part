import 'dart:typed_data';
import 'dart:io' as io show File;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cupertino_tabbar/cupertino_tabbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:tadpool_app/store/user.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:provider/provider.dart';
import 'package:tadpool_app/widgets/common/circle_image.dart';
import 'package:tadpool_app/widgets/profile_screen/bio_tab.dart';
import 'package:tadpool_app/widgets/profile_screen/preference_tab.dart';
import 'package:tadpool_app/services/url.dart';
import 'package:tadpool_app/widgets/profile_screen/face_verification_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tabIndex = 0;
  int _getTabIndex() => _tabIndex;
  final List<Widget> _tabs = [BioTab(), PreferenceTab()];
  User? user;

  void _updateUser(User? user) {
    setState(() {
      this.user = user;
    });
  }
  
  void _navigateToFaceVerification() async {
  final result = await Navigator.pushNamed(context, FaceVerificationScreen.routeName);
  
  // if user successfully verified, refetch user data
  if (result == true) {
    final _userStore = context.read<UserStore>();
    final updatedUser = await _userStore.fetchUser();
    setState(() {
      user = updatedUser;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final _userStore = context.watch<UserStore>();

    if (user == null) {
      _userStore.fetchUser().then((value) => _updateUser(value));
      return const Center(child: CircularProgressIndicator());
    }

    String? faceUrl = user!.profile?.facePictureUrl;

    if (faceUrl != null && faceUrl.isNotEmpty && !faceUrl.startsWith('http')) {
      faceUrl = 'https://$faceUrl';
    }

    final imageProvider = NetworkImage(
      faceUrl?.isNotEmpty == true
          ? faceUrl!
          : 'https://nwsid.net/wp-content/uploads/2015/05/dummy-profile-pic-300x300.png',
    );

    return ListView(
      children: [
        Container(
          height: 180.0,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: kStyle.primaryGreen,
                  height: 150.0,
                  width: double.infinity,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (user?.isVerified ?? false) ? Colors.blueAccent : Colors.transparent,
                      width: 4.0,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => _pickAndUploadImage(context),
                    child: CircleImage(
                      side: 128.0,
                      withBorder: true,
                      imageProvider: imageProvider,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user!.profile?.name ?? "No Name",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.1,
              ),
            ),
            if (user?.isVerified ?? false)
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Icon(
                  Icons.verified,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
              ),
          ],
        ),
        if (!(user?.isVerified ?? false)) ...[
          SizedBox(height: 8.0),
          Center(
            child: OutlinedButton.icon(
              onPressed: _navigateToFaceVerification,
              icon: Icon(Icons.verified_user, size: 18, color: kStyle.primaryGreen),
              label: Text(
                "Verify My Face",
                style: TextStyle(color: kStyle.primaryGreen),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kStyle.primaryGreen),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
        SizedBox(height: 12.0),
        Center(
          child: CupertinoTabBar(
            Colors.grey[100]!,
            Colors.white,
            [
              Text(
                "Bio",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _tabIndex == 0 ? kStyle.primaryGreen : Colors.grey[400],
                ),
              ),
              Text(
                "Preference",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _tabIndex == 1 ? kStyle.primaryGreen : Colors.grey[400],
                ),
              ),
            ],
            _getTabIndex,
            (index) => setState(() => _tabIndex = index),
            allowExpand: false,
            innerHorizontalPadding: 20.0,
            useShadow: false,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
        ),
        SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _tabs[_tabIndex],
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final dio = Dio();
    FormData formData;

    MultipartFile faceMultipart;
    MultipartFile bodyMultipart;

    if (kIsWeb) {
      final result1 = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result1 == null || result1.files.isEmpty) return;
      final faceBytes = result1.files.first.bytes;
      final faceName = result1.files.first.name;

      final result2 = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result2 == null || result2.files.isEmpty) return;
      final bodyBytes = result2.files.first.bytes;
      final bodyName = result2.files.first.name;

      faceMultipart = MultipartFile.fromBytes(faceBytes!, filename: "face_$faceName");
      bodyMultipart = MultipartFile.fromBytes(bodyBytes!, filename: "body_$bodyName");
    } else {
      final picker = ImagePicker();
      final pickedFace = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFace == null) return;

      final pickedBody = await picker.pickImage(source: ImageSource.gallery);
      if (pickedBody == null) return;

      faceMultipart = await MultipartFile.fromFile(
        pickedFace.path,
        filename: 'face_\${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      bodyMultipart = await MultipartFile.fromFile(
        pickedBody.path,
        filename: 'body_\${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    formData = FormData.fromMap({
      'files': [faceMultipart, bodyMultipart],
    });

    await dio.post(
      URL.baseUrl + ("/imgUpload/post"),
      data: formData,
      options: Options(headers: {"Authorization": "Token $token"}),
    );

    final _userStore = context.read<UserStore>();
    await _userStore.fetchUser().then((value) {
      setState(() => user = value);
    });

    print("Updated face URL: \${_userStore.currentUser?.profile?.facePictureUrl}");
    print("Updated body URL: \${_userStore.currentUser?.profile?.bodyPictureUrl}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Image uploaded successfully!")),
    );
  }
}
