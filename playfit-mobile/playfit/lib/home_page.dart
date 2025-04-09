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
  int _currentIndex = 0;

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
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _currentIndex == 3
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              title: const TopBar(),
              automaticallyImplyLeading: false,
            ),
      body: _pages[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: 100,
        child: ClipPath(
          clipper: NavBarClipper(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 74, 68, 89),
              unselectedItemColor: const Color.fromARGB(255, 74, 68, 89),
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                _buildNavBarItem(Icons.fitness_center, 0),
                _buildNavBarItem(Icons.list_alt, 1),
                _buildNavBarItem(Icons.shopping_cart, 2),
                _buildNavBarItem(Icons.person, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(128, 197, 222, 250)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: const Color.fromARGB(255, 74, 68, 89),
        ),
      ),
      label: '',
    );
  }
}

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 40, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(NavBarClipper oldClipper) => false;
}
