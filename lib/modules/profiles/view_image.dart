// import 'package:flutter/material.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:get/get.dart';
//
// class ViewImage extends StatefulWidget {
//   const ViewImage({super.key});
//
//   @override
//   State<ViewImage> createState() => _ViewImageState();
// }
//
// class _ViewImageState extends State<ViewImage> {
//   String? url;
//   @override
//   void initState() {
//     super.initState();
//     final args = Get.arguments;
//     if (args != null && args['url'] != null) {
//       url = args['url'];
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     double s = MediaQuery.of(context).size.width;
//     double h = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       appBar: AppBar(
//         backgroundColor: AppColors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//       //  title: const Text("View Image", style: TextStyle(color: Colors.white)),
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           panEnabled: true,
//           minScale: 1,
//           maxScale: 5,
//           child: Center(
//             child: Container(
//               width: s,
//               height: h * 0.45,
//               color: Colors.black,
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 child: url == null || url!.isEmpty
//                     ? Icon(Icons.camera_alt,size: s*0.08,color: Colors.grey,)
//                     : Image.network(
//                   url!,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(Icons.camera_alt,size: s*0.08,color: Colors.grey,);
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({super.key});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  String? url;
  File? file;
  bool isVideo = false;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null) {
      url = args['url'];
      file = args['file'];
      isVideo = args['isVideo'] ?? false;
    }

    if (isVideo) {
      _videoController = file != null
          ? VideoPlayerController.file(file!)
          : VideoPlayerController.network(url ?? '');
      _videoController!.initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isVideo
            ? _videoController != null && _videoController!.value.isInitialized
            ? Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.black54,
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
            ),
          ],
        )
            : const CircularProgressIndicator()
            : InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 5,
          child: url == null || url!.isEmpty
              ? Icon(
            Icons.camera_alt,
            size: width * 0.1,
            color: Colors.grey,
          )
              : Image.network(
            url!,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.camera_alt,
                size: width * 0.1,
                color: Colors.grey,
              );
            },
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}