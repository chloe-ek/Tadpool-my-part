import 'dart:typed_data';
import 'dart:io' as io show File;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final String? placeholder;
  final double height;
  final double width;
  final Function(dynamic)? onImageSelected; 

  const CustomImagePicker({
    Key? key,
    required this.placeholder,
    this.height = 200.0,
    this.width = 250.0,
    this.onImageSelected,
  }) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  io.File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker picker = ImagePicker();

  Future<void> getImage() async {
    if (kIsWeb) {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); 
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
        widget.onImageSelected?.call(bytes);
      } else {
        print('No image selected.');
      }
    } else {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); 
      if (pickedFile != null) {
        final file = io.File(pickedFile.path);
        setState(() => _imageFile = file);
        widget.onImageSelected?.call(file);
      } else {
        print('No image selected.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = kIsWeb ? _webImage != null : _imageFile != null;

    return InkWell(
      onTap: getImage,
      child: DottedBorder(
        dashPattern: [20, 10],
        strokeWidth: 2.0,
        borderType: BorderType.RRect,
        radius: Radius.circular(16),
        color: !hasImage ? Colors.grey[300]! : Colors.transparent,
        child: Container(
          width: widget.width,
          height: widget.height,
          child: !hasImage
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/add_photo.svg",
                      fit: BoxFit.fitHeight,
                      height: 75.0,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.placeholder!,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: kIsWeb
                      ? Image.memory(
                          _webImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
      ),
    );
  }
}
