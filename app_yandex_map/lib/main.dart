import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  final animation = const MapAnimation(type: MapAnimationType.smooth, duration: 2.0);
  double minZoom = 1;
  double maxZoom = 10;
  double currentZoomValue = 1;
  late YandexMapController controller;

  Future<void> positionLTRB(double left, double top, double right, double bottom) async {
    var position = await controller.getCameraPosition();
    double scale = 160/pow(2, currentZoomValue.round());

    dev.log('$left, $top, $right, $bottom');
    dev.log('$currentZoomValue:scale:$scale');
    CameraPosition newPosition =
    CameraPosition(
      target: Point(
        latitude: position.target.latitude+(bottom>0?-bottom*scale:top*scale),
        longitude: position.target.longitude+(left>0?-left*scale:right*scale),
      ),
      azimuth: position.azimuth,
      tilt: position.tilt,
      zoom: position.zoom,);
    dev.log('   position:$position');
    dev.log('newPosition:$newPosition');
    await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition.target,
            azimuth: newPosition.azimuth,
            tilt: newPosition.tilt,
            zoom: newPosition.zoom,
          ),
        ),
        animation: animation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: YandexMap(
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,

                      onMapCreated:  (YandexMapController yandexMapController) async {
                        controller = yandexMapController;
                        minZoom = await controller.getMinZoom();
                        maxZoom = await controller.getMaxZoom();
                        setState(() {

                        });
                      },
                    ),
                )
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () async {
              await controller.moveCamera(CameraUpdate.zoomIn(), animation: animation);
              currentZoomValue++;
              if(currentZoomValue>=maxZoom)currentZoomValue=maxZoom;
              setState(() {
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            mini: true,
            onPressed: () async {
              await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
              currentZoomValue--;
              if (currentZoomValue <= minZoom) currentZoomValue = minZoom;
              setState(() {
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.remove),
          ),
          Row(
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  currentZoomValue = 14;
                  await controller.moveCamera(
                      CameraUpdate.newCameraPosition(
                          CameraPosition(target: _point, zoom: currentZoomValue),),
                      animation: animation
                  );
                  setState(() {
                  });
                },
                tooltip: 'Increment',
                child: const Icon(Icons.home),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: () => positionLTRB(0,1,0,0),
                tooltip: 'Increment',
                child: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
          Row(
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: () => positionLTRB(1,0,0,0),
                tooltip: 'Increment',
                child: const Icon(Icons.arrow_back),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: () => positionLTRB(0,0,0,1),
                tooltip: 'Increment',
                child: const Icon(Icons.arrow_downward),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: () => positionLTRB(0,0,1,0),
                tooltip: 'Increment',
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          Slider(
            value: currentZoomValue.round().toDouble(),
            min: minZoom.round().toDouble(),
            max: maxZoom.round().toDouble(),
            divisions: maxZoom.round(),
            label: currentZoomValue.round().toString(),
            onChanged: (double value) async {

              await controller.moveCamera(CameraUpdate.zoomTo(value.round().toDouble()), animation: animation);
              setState(() {
                currentZoomValue = value.round().toDouble();
              });
            },
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
