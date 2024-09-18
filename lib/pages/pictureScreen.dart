import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:fluttertoast/fluttertoast.dart';

class PictureScreen extends StatefulWidget {
  const PictureScreen({super.key});

  @override
  State<PictureScreen> createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  XFile? _imageFile;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      final CameraDescription frontCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras![0]);

      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);

      try {
        // Start controlling the camera
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        print('Error initializing camera: $e');
      }
    }
  }

  // Take a picture
  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Capture the picture
        XFile picture = await _cameraController!.takePicture();

        // Save the file to the device
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath =
            '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await picture.saveTo(filePath);

        // Flip the image if using the front camera
        if (_cameraController!.description.lensDirection ==
            CameraLensDirection.front) {
          await _flipImageHorizontally(filePath);
        }

        setState(() {
          _imageFile = XFile(filePath);
        });
        Fluttertoast.showToast(
            msg: "Picture captured successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.NONE,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        print('Error capturing image: $e');
        Fluttertoast.showToast(
            msg: "Failed to capture picture",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  // Flip image horizontally
  Future<void> _flipImageHorizontally(String filePath) async {
    final imageBytes = await File(filePath).readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image != null) {
      // Flip image horizontally
      img.Image flippedImage = img.flipHorizontal(image);

      // Save the flipped image
      final flippedImageBytes = img.encodeJpg(flippedImage);
      await File(filePath).writeAsBytes(flippedImageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // appBar: AppBar(title: const Text('Take Picture')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Expanded(
            //   child: _cameraController!.buildPreview(),
            // ),
            child: Container(
              width: 200.0,
              height: 260.0,
              child: CameraPreview(_cameraController!),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _takePicture,
              ),
            ],
          ),
          // if (_imageFile != null)
          //   Expanded(
          //     child: Image.file(
          //       File(_imageFile!.path),
          //       width: 100.0,
          //       height: 60.0,
          //     ),
          //   ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
