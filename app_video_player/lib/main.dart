import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key });

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState extends State<VideoApp>{
  late VideoPlayerController _controller;

  final StreamController _streamController = StreamController<Duration>();
  StreamSubscription? streamSubscription;
  Duration _position = Duration.zero;

  Future<void> _getPosition() async {
    Duration? position = await _controller.position;
    if(position!=null)_streamController.add(position);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        _controller.addListener(
              () {
                if(_position.inSeconds !=  _controller.value.position.inSeconds){
                  log(_controller.value.position.inSeconds.toString());
                  setState(() {
                    _position = _controller.value.position;
                  });
                }
          },
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
              setState(() {});
            },
            child: Stack(
              children: [
                Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                      : const CircularProgressIndicator(),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.blue,
                    height: 100,
                    child: Column(
                      children: [
                        Slider(
                          value: _position.inSeconds.toDouble(),
                          max: 5,
                          divisions: 5,
                          label:  _position.inSeconds.toString(),
                          onChanged: (double value) {
                            setState(() {
                              //_currentSliderValue = value;
                            });
                          },
                        ),
                        Text('${_position?.inSeconds}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: (_controller.value.isPlaying)
              ? const SizedBox.shrink()
              : Center(
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}