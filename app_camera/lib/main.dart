import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:camera/camera.dart';

List<CameraDescription> _cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(const MaterialApp(home: CameraApp()));
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver{
  CameraController? controller;
  bool _isCameraInitialized = false;


  int _selectedIndex = 0;

  List<XFile?> listImageFile = [];

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _logError(e.code, e.description);
      showInSnackBar('Error initializing camera: ${e.code}\n${e.description}');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    onNewCameraSelected(_cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    }
    final scale = 1 / (cameraController.value.aspectRatio /** MediaQuery.of(context).size.aspectRatio*/);

    return Scaffold(
        appBar: AppBar(centerTitle: true, title:
          _selectedIndex==0?const Text('Camera preview'):const Text('Images gallery')),
          body: _selectedIndex==0?SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: cameraController.buildPreview()//CameraPreview(cameraController),
          ):
        ListView.builder(
          itemCount: listImageFile.length,
          itemBuilder: (context, index) {
            XFile? imageFile = listImageFile[index];
              return Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(0),
                  child: SizedBox(
                    height: 300, width: double.infinity,
                    child: imageFile==null?const Placeholder(): kIsWeb
                        ? Image.network(imageFile.path, fit: BoxFit.cover,)
                        : Image.file(File(imageFile.path),fit: BoxFit.cover,)),
              );
            },
          ),
          floatingActionButton: Visibility(
            visible: _selectedIndex==0,
            child: FloatingActionButton(
              onPressed: ()=> takePicture().then((XFile? file) {
                if (file != null) {
                  if(listImageFile.length>=10)listImageFile.removeLast();
                  listImageFile.add(file);
                  showInSnackBar('Picture saved to ${file.path}');
                }
              }),
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
                label: 'Gallery',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
              if(_selectedIndex == 0 && kIsWeb){
                cameraController.dispose();
                onNewCameraSelected(cameraController.description);
              }

            },
          ),
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}