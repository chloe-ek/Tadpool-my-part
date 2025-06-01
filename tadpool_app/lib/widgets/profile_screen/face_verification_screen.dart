import 'dart:html' as html; // web only (test)
import 'dart:ui_web' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadpool_app/services/url.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:provider/provider.dart';
import 'package:tadpool_app/store/user_store.dart';
import 'package:tadpool_app/widgets/common/circle_image.dart';

class FaceVerificationScreen extends StatefulWidget {
  static const routeName = '/face-verification';

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  html.MediaStream? _mediaStream;
  bool _cameraInitialized = false;
  String? _verificationResult; // result message from AWS rekognition via backend

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _videoElement = html.VideoElement();
    _videoElement!.autoplay = true;
    _videoElement!.style.width = '100%';
    _videoElement!.style.height = 'auto';

    ui.platformViewRegistry.registerViewFactory('camera', (int viewId) => _videoElement!);

    html.window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
      _mediaStream = stream;
      _videoElement!.srcObject = stream;
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  Future<void> _captureAndVerify() async {
  if (_videoElement == null) return;

  _canvasElement = html.CanvasElement(
    width: _videoElement!.videoWidth,
    height: _videoElement!.videoHeight,
  );
  final ctx = _canvasElement!.context2D;
  ctx.drawImage(_videoElement!, 0, 0);

  final blob = await _canvasElement!.toBlob('image/jpeg');
  final reader = html.FileReader();
  reader.readAsArrayBuffer(blob!);

  reader.onLoadEnd.listen((event) async {
    final Uint8List imageData = reader.result as Uint8List;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageData, filename: 'selfie.jpg'),
    });

    final dio = Dio();
    try {
      final response = await dio.post(
        URL.baseUrl + '/face-verification/',
        data: formData,
        options: Options(headers: {"Authorization": "Token $token"}),
      );

      final bool matched = response.data['matched'];
      final double similarity = response.data['similarity'];
      final String message = response.data['message'];

      setState(() {
        _verificationResult = "$message\n(Similarity: ${similarity.toStringAsFixed(1)}%)";
      });

      if (matched) {
        _videoElement?.srcObject = null;
        _mediaStream?.getTracks().forEach((track) => track.stop());
        
        final userStore = context.read<UserStore>();
        await userStore.fetchUser();
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _verificationResult = 'Verification failed: $e';
      });
    }
  });
}



  
  @override
  void dispose() {
    _videoElement?.srcObject = null;
    _mediaStream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final user = userStore.currentUser;
    final faceUrl = user?.profile?.facePictureUrl;

    final imageProvider = NetworkImage(
      (faceUrl != null && faceUrl.isNotEmpty)
          ? faceUrl
          : 'https://nwsid.net/wp-content/uploads/2015/05/dummy-profile-pic-300x300.png',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kStyle.primaryGreen,
        elevation: 0,
        titleSpacing: 12.0,
        centerTitle: true,
        title: Text(
            "VERIFY MY FACE",
            style: kStyle.appBarText.copyWith(color: Colors.white),
        ),
    ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleImage(
                side: 100,
                imageProvider: imageProvider,
                withBorder: true,
              ),
              SizedBox(height: 16),
              if (_cameraInitialized)
                Container(
                  height: 300,
                  child: HtmlElementView(viewType: 'camera'),
                )
              else
                CircularProgressIndicator(),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt, size: 18),
                onPressed: _captureAndVerify,
                label: Text("Take Selfie & Verify"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kStyle.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                ),
              ),
              if (_verificationResult != null) ...[
                SizedBox(height: 16),
                Text(
                  _verificationResult!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
