import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(centerTitle: true, title:
          _selectedIndex==0?const Text('Camera preview'):const Text('Images gallery')),


          body: _selectedIndex==0?CameraPreview(controller):
        ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
              return const Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: SizedBox(
                    height: 200,
                    child: Placeholder(),
                  ),
              );
            },
          ),
          floatingActionButton: Visibility(
            visible: _selectedIndex==0,
            child: FloatingActionButton(
              onPressed: () {

              },
              child: const Icon(Icons.camera),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image_rounded),
                label: 'Gellary',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
          ),
      ),
    );
  }
}