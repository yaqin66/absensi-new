import 'package:flutter/material.dart';
import 'package:test/pages/homeScreen.dart';
import 'package:test/pages/pictureScreen.dart';
import 'package:test/pages/profileScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Homescreen(),
    const PictureScreen(), // Uncomment if you want to use TakePicture screen
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Colors.white, // Menghilangkan latar belakang default
          splashColor: Colors.transparent, // Menghilangkan efek splash
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 25,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Icons.camera_alt_rounded : Icons.camera_alt_outlined,
                size: 25,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Icons.person : Icons.person_outline,
                size: 25,
              ),
              label: '',
            ),
          ],
          showSelectedLabels: false, // Menyembunyikan label yang dipilih
          showUnselectedLabels: false, // Menyembunyikan label yang tidak dipilih
        ),
      ),
    );
  }
}
