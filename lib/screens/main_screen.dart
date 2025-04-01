import 'package:flutter/material.dart';
import 'package:the_holy_bible/components/bottom_nav.dart';
import 'bible_screen.dart'; // New name for HomePage
import 'saved_screen.dart';
import 'community_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Define screens corresponding to each nav item
  final List<Widget> _screens = [
    BibleScreen(), // The Bible screen (previously HomePage)
    SavedScreen(), // Saved bookmarks
    CommunityScreen(), // Community discussions
    SearchScreen(), // Search functionality
    SettingsScreen(), // Settings page
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Switch screens dynamically
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
