import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
// import 'package:test/pages/login_page.dart';

import 'profileScreen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  XFile? _imageFile;
  int _cameraIndex = 0;
  int _selectedIndex = 0;

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

      _cameraController = CameraController(frontCamera, ResolutionPreset.low);

      // Start controlling the camera
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Image captured and saved successfully!')),
        );
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
  }

  // Flip image horizontally
  Future<void> _flipImageHorizontally(String filePath) async {
    final imageBytes = File(filePath).readAsBytesSync();
    img.Image image = img.decodeImage(imageBytes)!;

    // Flip image horizontally
    img.Image flippedImage = img.flipHorizontal(image);

    // Save the flipped image
    final flippedImageBytes = img.encodeJpg(flippedImage);
    File(filePath).writeAsBytesSync(flippedImageBytes);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Update index when a menu item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const Dashboard_Page(),
      TakePicture(
        cameraController: _cameraController,
        takePicture: _takePicture,
        imageFile: _imageFile,
        isCameraInitialized: _isCameraInitialized,
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex], // Show page based on selected menu
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class Dashboard_Page extends StatelessWidget {
  const Dashboard_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class TakePicture extends StatelessWidget {
  final CameraController? cameraController;
  final VoidCallback takePicture;
  final XFile? imageFile;
  final bool isCameraInitialized;

  const TakePicture({
    Key? key,
    required this.cameraController,
    required this.takePicture,
    required this.imageFile,
    required this.isCameraInitialized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isCameraInitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200.0,
                  height: 260.0,
                  child: AspectRatio(
                    aspectRatio: cameraController!.value.aspectRatio,
                    child: CameraPreview(cameraController!),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: takePicture,
                  child: const Text('Take Picture'),
                ),
                const SizedBox(height: 20),
                imageFile != null
                    ? Image.file(
                        File(imageFile!.path),
                        height: 200,
                      )
                    : const Text('No image captured'),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bagian foto profil
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150', // Gambar profil placeholder
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama pengguna
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Email pengguna
            const SizedBox(height: 10),
            const Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            // Divider untuk memisahkan bagian profil dan aksi
            const SizedBox(height: 30),
            const Divider(
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),

            // Tombol-tombol profil
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    onTap: () {
                      // Aksi ketika tombol ditekan
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.lock,
                    title: 'Privacy Settings',
                    onTap: () {
                      // Aksi ketika tombol ditekan
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Activity History',
                    onTap: () {
                      // Aksi ketika tombol ditekan
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      // Aksi ketika tombol ditekan
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi helper untuk membangun opsi di profil
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
