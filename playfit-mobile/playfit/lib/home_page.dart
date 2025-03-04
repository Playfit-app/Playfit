import 'package:flutter/material.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'adventure_page.dart';
import 'missions_page.dart';
import 'boutique_page.dart';
import 'profile_page.dart';
import 'components/top_bar.dart';

class HomePage extends StatefulWidget {
  final bool firstLogin;
  const HomePage({
    super.key,
    this.firstLogin = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: prefer_final_fields
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdventurePage(),
    const MissionsPage(),
    const BoutiquePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.firstLogin) {
      Future.delayed(const Duration(), () async {
        final service = NotificationService();

        await service.requestNotificationPermission();
        await service.getToken();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const TopBar(),
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Aventure',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
