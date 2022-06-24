import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  const Video({Key? key}) : super(key: key);

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late VideoPlayerController _videoController;
  late Future<void> _initializePlayer;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset("assets/tut.mp4");
    _videoController.setLooping(true);
    _initializePlayer = _videoController.initialize();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializePlayer,
        builder: (context, snapshot) {
          _videoController.play();
          return AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController));
        });
  }
}
