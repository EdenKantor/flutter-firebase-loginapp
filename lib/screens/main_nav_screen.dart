import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';
import 'package:logionapp/screens/dashboard_screen.dart';
import 'package:logionapp/screens/profile_screen.dart';
import 'package:logionapp/screens/services_menu_screen.dart';
import 'package:logionapp/screens/settings_screen.dart';

/// Exercise 4 — wraps the Dashboard with a BottomNavigationBar that swaps
/// between three tabs: Home / Settings / Profile.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  static const _titles = ['Home', 'Settings', 'Profile'];

  int _currentIndex = 0;
  String _selectedService = 'Cleaning';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        automaticallyImplyLeading: true,
      ),
      // IndexedStack keeps every tab alive when not visible, so the
      // Dashboard selection and the Profile's loaded data stay intact when
      // the user moves between tabs.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardContent(
            onServiceChanged: (name) => _selectedService = name,
          ),
          const SettingsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ServicesMenuScreen(selected: _selectedService),
                  ),
                );
              },
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_forward),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

