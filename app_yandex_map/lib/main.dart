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
  late double minZoom;
  late double maxZoom;
  late double currentZoomValue;
  late YandexMapController controller;

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
                      },
                    ),
                )
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await controller.moveCamera(CameraUpdate.zoomIn(), animation: animation);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: () async {
              await controller.moveCamera(
                  CameraUpdate.newCameraPosition(const CameraPosition(target: _point)),
                  animation: animation
              );
            },
            tooltip: 'Increment',
            child: const Icon(Icons.home),
          ),
          Slider(
            value: 1,
            max: maxZoom,
            divisions: maxZoom.round(),
            label: 20.round().toString(),
            onChanged: (double value) {
              setState(() async {
                //_currentSliderValue = value;
                await controller.moveCamera(CameraUpdate.zoomTo(1), animation: animation);
              });
            },
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
