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
  bool isVis = true;
  Duration _position = Duration.zero;
  Duration _size = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(

      'https://www.shutterstock.com/shutterstock/videos/1074580868/preview/stock-footage-slow-motion-of-group-of-colorful-butterfly-on-the-ground-and-flying-in-nature-forest.webm'
      //'https://v3.cdnpk.net/videvo_files/video/premium/partners0174/large_watermarked/BB_885be2a0-add8-48f6-950e-fe52d00ba133_FPpreview.mp4'
      //    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
    ),
    )
      ..initialize().then((_) {
        setState(() {
          _size = _controller.value.duration;
        });
        _controller.addListener(
              () {
                if(_position.inSeconds !=  _controller.value.position.inSeconds){
                  log(_controller.value.position.inSeconds.toString());
                  setState(() {
                    _position = _controller.value.position;
                  });
                }
                if(_controller.value.position.inSeconds >= _controller.value.duration.inSeconds){
                  setState(() {
                    isVis = true;
                  });
                }
          },
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    int sec = _size.inSeconds%60;
    int min = _size.inSeconds~/60;
    log('size: ${min<10?'0$min':'$min'}:${sec<10?'0$sec':'$sec'}');
    int secPos = _position.inSeconds%60;
    int minPos = _position.inSeconds~/60;
    log('size: ${minPos<10?'0$minPos':'$minPos'}:${secPos<10?'0$secPos':'$secPos'}');
    var urlString = _controller.dataSource.split('/');
    String nameFile =
    urlString[urlString.length-1].split('-').join(' ').split('.')[0];//вычленить имя из URL

    double width = MediaQuery.of(context).size.width;

    void timer(String text) {
      log(text);
      if(isVis == true) return;
      if(_controller.value.isPlaying){
        setState(() {
          isVis = !isVis;
        });
      }
      Future.delayed(const Duration(seconds: 5), () {
        if(_controller.value.isPlaying){
          setState(() {
            isVis = false;
          });
        }
      },);
    }

    void showHidePP(String text){
      log(text);
      if(_controller.value.isPlaying){
        _controller.pause();
        setState(() {
          isVis = true;
        });
      } else{
        _controller.play();
        setState(() {
          isVis = false;
        });
      }
    }

    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: MouseRegion(
          cursor: SystemMouseCursors.click,
          //onEnter: (_) => setState(() => isVis = true),
          child: GestureDetector(
            onTap: ()=>timer('onTap'),
            onDoubleTap: ()=>showHidePP('onDoubleTap'),
            child: Container(
              color: Colors.black,
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 50),
                      reverseDuration: const Duration(milliseconds: 200),
                      child: (isVis == false)
                          ? const SizedBox.shrink()
                          : Container(
                        color: Colors.black54,
                        height: 80,
                        width: width,
                        child: Column(
                          children: [
                            Slider(
                              value: _position.inSeconds.toDouble(),
                              max: _size.inSeconds.toDouble(),
                              divisions: 100,
                              label:  _position.inSeconds.toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _controller.seekTo(
                                      Duration(seconds: value.toInt())
                                  );
                                });
                                timer('Slider setState');
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  child: Text('${minPos<10?'0$minPos':'$minPos'}:${secPos<10?'0$secPos':'$secPos'}', style: const TextStyle(color: Colors.white)),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    child: Text(
                                        nameFile,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white),

                                       // textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  child: Text('${min<10?'0$min':'$min'}:${sec<10?'0$sec':'$sec'}', style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: (isVis == false)
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
                  onPressed: ()=>showHidePP('onPressed'),
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