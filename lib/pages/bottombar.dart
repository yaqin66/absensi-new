import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        // primaryColor: Colors.green,
        canvasColor: Colors.grey, // Menghilangkan latar belakang default
        splashColor: Colors.transparent, // Menghilangkan efek splash
        // highlightColor: Colors.transparent, // Menghilangkan efek highlight
      ),
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.blue : Colors.white,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 1 ? Colors.blue : Colors.white,
              ),
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,  // Warna untuk item yang dipilih
        unselectedItemColor: Colors.grey[600],  // Warna untuk item yang tidak dipilih
        onTap: _onItemTapped,  // Mengatur index yang dipilih
        showSelectedLabels: false,  // Sembunyikan label item yang dipilih
        showUnselectedLabels: false,  // Sembunyikan label item yang tidak dipilih
        iconSize: 40.0,  // Ukuran ikon
      ),
    );
  }
}
