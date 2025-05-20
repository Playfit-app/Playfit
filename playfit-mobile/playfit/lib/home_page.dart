import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'adventure_page.dart';
import 'missions_page.dart';
import 'boutique_page.dart';
import 'profile_page.dart';
import 'package:playfit/social_page.dart';
import 'components/top_bar.dart';

class HomePage extends StatefulWidget {
  final bool firstLogin;
  final bool workoutDone;
  final String? completedDifficulty;

  HomePage({
    super.key,
    this.firstLogin = false,
    this.workoutDone = false,
    this.completedDifficulty,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late int currentStreak;
  late Future<void> _userProgressFuture;

  Future<void> _fetchUserProgress() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String url = "${dotenv.env['SERVER_BASE_URL']}/api/auth/get_my_progress/";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int current_streak = data['current_streak'];

      setState(() {
        currentStreak = current_streak;
      });
    } else {
      throw Exception('Failed to load user progress');
    }
  }

  @override
  void initState() {
    super.initState();
    currentStreak = 0;
    _userProgressFuture = _fetchUserProgress();
    _pages = [
      AdventurePage(
        moveCharacter: widget.workoutDone,
        completedDifficulty: widget.completedDifficulty,
      ),
      const MissionsPage(),
      const BoutiquePage(),
      const SocialPage(),
      const ProfilePage(),
    ];
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
    return FutureBuilder(
      future: _userProgressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(t.home.error_loading));
        }

        final double navBaseHeight = kBottomNavigationBarHeight;
        final double curvedClipExtra = 40;
        final double paddingExtra = 10;

        final double navBarHeight =
            navBaseHeight + curvedClipExtra + paddingExtra;

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: _currentIndex == 4 || _currentIndex == 3
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  title: TopBar(currentStreak: currentStreak),
                  automaticallyImplyLeading: false,
                ),
          body: _pages[_currentIndex],
          bottomNavigationBar: SizedBox(
            height: navBarHeight,
            child: ClipPath(
              clipper: NavBarClipper(),
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
                  _buildNavBarItem(Icons.group, 3),
                  _buildNavBarItem(Icons.person, 4),
                ],
              ),
            ),
          ),
        );
      },
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
