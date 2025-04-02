import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.onTabSelected,
    required this.selectedIndex,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onTabSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: false,
      selectedFontSize: 16,
      iconSize: 30,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bible'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
