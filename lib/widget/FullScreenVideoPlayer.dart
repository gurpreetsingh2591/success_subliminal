import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  FullScreenVideoPlayer({
    super.key,
    required this.videoPlayerController,
  });

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late final ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoPlay: false,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }
}
