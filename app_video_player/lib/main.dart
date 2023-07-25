import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp>  with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;

  late AnimationController _animationController;
  late Animation _myAnimation;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),

    );
    _myAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(VideoApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : Container(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(_controller, allowScrubbing: true),
            )
          ],
        ),
        floatingActionButton: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() async {
                    var position = await _controller.position;
                    if (position == null) return;
                    await _controller.seekTo(Duration(seconds: position.inSeconds>10?position.inSeconds-10:0));
                  });
                },
                backgroundColor: Colors.transparent,
                child: const Icon(
                  Icons.replay_10,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                backgroundColor: Colors.transparent,
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() async {
                    var position = await _controller.position;
                    if (position == null) return;
                    await _controller.seekTo(Duration(seconds: position.inSeconds+10));
                  });
                },
                backgroundColor: Colors.transparent,
                child: const Icon(
                  Icons.forward_10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}