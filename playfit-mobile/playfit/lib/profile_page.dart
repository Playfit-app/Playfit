import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/components/profile/edit_character_button.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/experience_circle.dart';
import 'package:playfit/components/success.dart';
import 'package:playfit/components/historic_chart.dart';
import 'package:playfit/components/level_progression_dialog.dart';

class ProfilePage extends StatefulWidget {
  final int? userId;

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _isFollowing = false;
  int _followerCount = 0;
  late Future<Map<String, dynamic>> _futureUserData;

  String _formatDate(String rawDate) {
    final DateTime dateTime = DateTime.parse(rawDate);
    final DateFormat formatter = DateFormat('MMMM yyyy');
    return formatter.format(dateTime);
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final String userId =
        widget.userId != null ? widget.userId.toString() : 'me';

    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/auth/profile/$userId/';
    final String? token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void _follow() async {
    if (widget.userId == null) return;

    final String url = '${dotenv.env['SERVER_BASE_URL']}/api/social/follow/';
    final String? token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id': widget.userId,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _isFollowing = true;
        _followerCount += 1;
      });
    } else {
      debugPrint("Failed to follow user: ${response.statusCode}");
    }
  }

  void _unfollow() async {
    if (widget.userId == null) return;

    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/social/unfollow/${widget.userId}/';
    final String? token = await storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        _isFollowing = false;
        _followerCount -= 1;
      });
    } else {
      // Handle error
      debugPrint("Failed to unfollow user: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureUserData = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureUserData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data as Map<String, dynamic>;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        if (userData['is_following'] != null) {
          _isFollowing = userData['is_following'];
        }
        if (userData['followers'] != null) {
          _followerCount = userData['followers'];
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: Colors.black,
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: screenHeight / 2,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        '${dotenv.env['SERVER_BASE_URL']}${userData['decorations']['mountains'][userData['progress']['level'] - 1]}',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Align(
                    alignment: const Alignment(0, -0.3),
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 204, 255, 178),
                            shape: BoxShape.circle,
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14),
                            child: Image.network(
                              '${dotenv.env['SERVER_BASE_URL']}${userData['customization']['base_character']}',
                            ),
                          ),
                        ),
                        if (widget.userId == null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: EditCharacterButton(
                              backgroundImageUrl:
                                  '${dotenv.env['SERVER_BASE_URL']}${userData['decorations']['mountains'][userData['progress']['level'] - 1]}',
                              onClosed: () {
                                setState(() {
                                  _futureUserData = fetchUserData();
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: screenHeight * 0.3,
                bottom: 0,
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                userData['user']['first_name'] != null
                                    ? Text(
                                        userData['user']['first_name'],
                                        style:
                                            GoogleFonts.amaranth(fontSize: 36),
                                      )
                                    : const SizedBox(),
                                Padding(
                                  padding: userData['user']['first_name'] !=
                                          null
                                      ? EdgeInsets.only(left: 8.0, top: 14.0)
                                      : const EdgeInsets.only(left: 0.0),
                                  child: Text(
                                    userData['user']['username'],
                                    style: TextStyle(
                                        fontSize: userData['user']
                                                    ['first_name'] !=
                                                null
                                            ? 14
                                            : 36),
                                  ),
                                ),
                                // Completely to the right
                                const Spacer(),
                                if (widget.userId != null)
                                  // Button to follow/unfollow
                                  TextButton(
                                    onPressed: () {
                                      if (_isFollowing) {
                                        _unfollow();
                                      } else {
                                        _follow();
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        const Color(0XFFF8871F),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        !_isFollowing
                                            ? t.profile.follow
                                            : t.profile.unfollow,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                // "Membre depuis ${userData['user']['date_joined'].substring(0, 7)}",
                                t.profile.member_since(
                                    date: _formatDate(
                                        userData['user']['date_joined'])),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 120, 119, 111),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _followerCount.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    t.profile.followers,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 120, 119, 111),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    userData['following'].toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    t.profile.following,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 120, 119, 111),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showLevelProgressionPopup(context,
                                        userData['decorations']['mountains']);
                                  },
                                  child: ExperienceCircle(
                                    currentXP: (userData['progress']
                                            ['current_xp'] as num)
                                        .toDouble(),
                                    requiredXP: (userData['progress']
                                            ['required_xp'] as num)
                                        .toDouble(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: screenWidth * 0.1,
                                        width: screenWidth * 0.1,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              '${dotenv.env['SERVER_BASE_URL']}${userData['decorations']['mountains'][userData['progress']['level'] - 1]}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _buildDivider(),
                                _buildInfoSection(
                                  const Icon(Icons.local_fire_department,
                                      color: Color(0XFFFF7A00), size: 24),
                                  "${userData['progress']['current_streak']}\nDay streak",
                                ),
                                _buildDivider(),
                                _buildInfoSection(
                                  const Icon(Icons.flag_rounded, size: 24),
                                  "${userData['progress']['cities_finished']}\n${t.profile.cities_finished}",
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Container(
                              height: screenHeight * 0.2,
                              decoration: const BoxDecoration(
                                color: Color(0XFFFFE9CA),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: HistoricChart(
                                last7Dates:
                                    (userData['last_7_days']['dates'] as List)
                                        .cast<String>(),
                                last7Exos: (userData['last_7_days']
                                        ['repetitions'] as List)
                                    .cast<int>(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 1.5,
                                            width: screenWidth * 0.1,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Color(0XFF7391FD),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              t.profile.nb_exercises_done_title,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0XFF1D1B20),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            height: 1.5,
                                            width: screenWidth * 0.1,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Color(0XFFFF0000),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              t.profile.bpm_title,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0XFF1D1B20),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // if (widget.userId == null)
                                //   TextButton(
                                //     onPressed: () {},
                                //     style: ButtonStyle(
                                //       backgroundColor: WidgetStateProperty.all(
                                //         const Color(0XFFF8871F),
                                //       ),
                                //       shape: WidgetStateProperty.all(
                                //         RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(20),
                                //         ),
                                //       ),
                                //     ),
                                //     child: const Padding(
                                //       padding: EdgeInsets.symmetric(
                                //         horizontal: 10,
                                //       ),
                                //       child: Text(
                                //         "Voir plus",
                                //         style: TextStyle(
                                //           fontSize: 14,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t.profile.achievements,
                                style: GoogleFonts.amaranth(fontSize: 36),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                for (var success in userData['achievements'])
                                  Success(
                                    image:
                                        '${dotenv.env['SERVER_BASE_URL']}${success['image']}',
                                    completed: success['is_completed'],
                                    title: success['name'],
                                    description: success['description'],
                                    target: success['target'],
                                    current: success['current_value'],
                                    awardedAt: success['awarded_at'],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const SizedBox(
      height: 50,
      child: VerticalDivider(
        color: Color(0XFFE57106),
        thickness: 1,
      ),
    );
  }

  Widget _buildInfoSection(Icon icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0XFF1D1B20),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
