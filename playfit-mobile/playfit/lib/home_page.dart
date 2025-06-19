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
  // final bool workoutDone;
  // final String? completedDifficulty;

  HomePage({
    super.key,
    this.firstLogin = false,
    // this.workoutDone = false,
    // this.completedDifficulty,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late int currentStreak;
  late Future<void> _userProgressFuture;

  /// Fetches the user's progress from the server.
  /// This method retrieves the current streak of the user
  /// and updates the state accordingly.
  ///
  /// Returns a [Future] that completes when the data is fetched.
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.workoutDone) {
    //     refreshStreakAfterWorkout();
    //   }
    // });

    _pages = [
      AdventurePage(
        // moveCharacter: widget.workoutDone,
        // completedDifficulty: widget.completedDifficulty,
      ),
      // const MissionsPage(),
      // const BoutiquePage(),
      const SocialPage(),
      const ProfilePage(),
    ];
    // Request notification permissions if it's the user's first login
    // and get the notification token.
    // This is useful for sending notifications about new missions or updates.
    if (widget.firstLogin) {
      Future.delayed(const Duration(), () async {
        final service = NotificationService();

        await service.requestNotificationPermission();
        await service.getToken();
      });
    }
  }

  // Future<void> refreshStreakAfterWorkout() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   await _fetchUserProgress();
  // }

  /// Handles the tap event on the bottom navigation bar items.
  /// This method updates the current index of the selected page
  /// and triggers a rebuild of the widget to display the selected page.
  ///
  /// `index` is the index of the tapped item in the bottom navigation bar.
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Heights and insets
    final double navBaseHeight  = kBottomNavigationBarHeight;
    final double curvedClipExtra = 40;
    final double paddingExtra    = 10;
    final double bottomInset     = MediaQuery.of(context).padding.bottom;
    final double clipHeight      = navBaseHeight + curvedClipExtra;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      // The app bar is hidden for the Social and Profile pages
      // to provide a full-screen experience for those pages.
      appBar: _currentIndex == 1 || _currentIndex == 2
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              title: TopBar(currentStreak: currentStreak),
              automaticallyImplyLeading: false,
            ),
      // The body of the home page is a FutureBuilder that waits for the user progress data to load.
      // While loading, it shows a CircularProgressIndicator.
      // If there's an error, it displays an error message.
      // Once the data is loaded, it displays the corresponding page based on the current index.
      // This allows the app to show different content based on the user's navigation choice.
      body: FutureBuilder(
        future: _userProgressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(t.home.error_loading));
          }
          return _pages[_currentIndex];
        },
      ),
      bottomNavigationBar: SizedBox(
        height: clipHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: NavBarClipper(),
              child: Container(
                height: clipHeight + bottomInset,
                color: Colors.white,
              ),
            ),
            Positioned(
              bottom: -bottomInset,
              left: 0,
              right: 0,
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color.fromARGB(255, 74, 68, 89),
                unselectedItemColor: const Color.fromARGB(255, 74, 68, 89),
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  _buildNavBarItem(Icons.fitness_center, 0),
                  // _buildNavBarItem(Icons.list_alt, 1),
                  // _buildNavBarItem(Icons.shopping_cart, 2),
                  _buildNavBarItem(Icons.group, 1),
                  _buildNavBarItem(Icons.person, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a BottomNavigationBarItem with the specified icon and index.
  /// This method checks if the item is selected based on the current index
  /// and applies a background color if it is selected.
  ///
  /// `icon` is the icon to be displayed in the navigation bar item.
  /// `index` is the index of the item in the navigation bar.
  ///
  /// Returns a [BottomNavigationBarItem] that can be used in the BottomNavigationBar.
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

// Custom clipper for the navigation bar to create a curved effect.
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
