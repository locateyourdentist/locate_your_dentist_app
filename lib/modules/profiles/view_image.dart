import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({super.key});
  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  String? url;
  File? file;
  Uint8List? bytes;
  bool isVideo = false;

  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    url = args['url'];
    file = args['file'];
    bytes = args['bytes'];
    isVideo = args['isVideo'] ?? false;

    if (isVideo) {
      controller = file != null
          ? VideoPlayerController.file(file!)
          : VideoPlayerController.network(url ?? '');

      controller!.initialize().then((_) {
        setState(() {});
        controller!.play();
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: isVideo
            ? controller != null && controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller!),
                    )
                  : const CircularProgressIndicator()
            : (kIsWeb && bytes != null)
            ? Image.memory(bytes!)
            : (file != null)
            ? Image.file(file!)
            : (url != null)
            ? Image.network(url!)
            : const Icon(Icons.image_not_supported, color: Colors.white),
      ),
    );
  }
}
