import 'dart:io' as io;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadpool_app/app_loc.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:tadpool_app/widgets/common/primary_button.dart';

import 'common/custom_image_picker.dart';
import 'home_screen/home_screen.dart';

import 'package:tadpool_app/services/url.dart';

class PhotoVerificationScreen extends StatefulWidget {
  static const routeName = "photo_verification";

  @override
  _PhotoVerificationScreenState createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  dynamic _faceImage;
  dynamic _bodyImage;

  bool get _isEnabled => _faceImage != null && _bodyImage != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLoc.of(context)!.tr('pv_title')!,
            style: kStyle.appBarText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: CustomImagePicker(
                    onImageSelected: (data) =>
                        setState(() => _faceImage = data),
                    placeholder: AppLoc.of(context)!.tr('pv_face'),
                  ),
                ),
                const SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.topCenter,
                  child: CustomImagePicker(
                    onImageSelected: (data) =>
                        setState(() => _bodyImage = data),
                    placeholder: AppLoc.of(context)!.tr('pv_body'),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  AppLoc.of(context)!.tr('pv_message')!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: PrimaryButton(
              _isEnabled
                  ? AppLoc.of(context)!.tr('pv_btn')!.toUpperCase()
                  : 'ADD IMAGES TO CONTINUE',
              isDisabled: !_isEnabled,
              onPressed: _uploadImage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    String imageUploadUrl = URL.baseUrl + ("/imgUpload/post");
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    MultipartFile faceMultipart;
    MultipartFile bodyMultipart;

    if (kIsWeb) {
      faceMultipart = MultipartFile.fromBytes(
        _faceImage as Uint8List,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      bodyMultipart = MultipartFile.fromBytes(
        _bodyImage as Uint8List,
        filename: 'body_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } else {
      faceMultipart = await MultipartFile.fromFile(
        (_faceImage as io.File).path,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      bodyMultipart = await MultipartFile.fromFile(
        (_bodyImage as io.File).path,
        filename: 'body_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final formData = FormData.fromMap({
      "files": [faceMultipart, bodyMultipart],
    });

    try {
      final response = await dio.post(
        imageUploadUrl,
        data: formData,
        options: Options(headers: {"Authorization": "Token $token"}),
      );
      print("Upload success: ${response.statusCode}");

      Navigator.of(context)
          .pushNamedAndRemoveUntil(HomeScreen.routeName, (_) => false);
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed. Please try again.")),
      );
    }
  }
}
