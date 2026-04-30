import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';

class CropScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const CropScreen({super.key, required this.imageBytes});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Image",
            style: AppTextStyles.body(context, color: AppColors.white)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isCropping = true);
              //_controller.crop();
            },
            child: const Text("DONE",
                style: TextStyle(color: Colors.white)),
          )
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),

      body: Center(
        child: Crop(
          image: widget.imageBytes,
          //controller: _controller,
          aspectRatio: 1,
          onCropped: (result) {
            setState(() => _isCropping = false);

            if (result is CropSuccess) {
              Navigator.pop(context, result.croppedImage);
            } else {
              Navigator.pop(context, null);
            }
          },
        ),
      ),
    );
  }
}