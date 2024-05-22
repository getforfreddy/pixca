import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraSample extends StatefulWidget {
  const CameraSample({super.key});

  @override
  State<CameraSample> createState() => _CameraSampleState();
}

class _CameraSampleState extends State<CameraSample> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // To refresh the UI after initializing the camera
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 225,right: 225,bottom: 50),
        child: FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;

              final image = await _controller.takePicture();

              if (!mounted) return;

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: image.path),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.fitWidth,
          )),
    );
  }
}
