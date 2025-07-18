import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/social/social_search_bar.dart';
import 'package:playfit/components/social/post_feed.dart';
import 'package:playfit/profile_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.social.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            // The SocialSearchBar allows users to search for other users
            // and navigate to their profile page when a user is selected.
            child: SocialSearchBar(
              onUserSelected: (user) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      userId: user['id'],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // The PostFeed displays a list of posts from users
          // It is a scrollable list that shows posts with images, text, and user interactions.
          Expanded(
            child: PostFeed(),
          ),
        ],
      ),
    );
  }
}
