import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../auth/login_screen/login_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AppImage media;

  const VideoPlayerScreen({super.key, required this.media});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Use file if available, else network URL
    if (widget.media.file != null) {
      _controller = VideoPlayerController.file(widget.media.file!);
    } else if (widget.media.url != null && widget.media.url!.isNotEmpty) {
      String url = widget.media.url!;
      if (url.startsWith("http://")) {
        // Convert HTTP to HTTPS if possible to avoid Android 9+ issues
        url = url.replaceFirst("http://", "https://");
      }
      _controller = VideoPlayerController.network(url);
    } else {
      // No video source
      return;
    }

    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    }).catchError((error) {
      print("Video init error: $error");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        //title: const Text("Video Player"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isInitialized
            ? Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding:  EdgeInsets.all(12),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: size*0.08,
                ),
              ),
            ),
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}