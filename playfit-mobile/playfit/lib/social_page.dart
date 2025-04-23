import 'package:flutter/material.dart';
import 'package:playfit/components/social/user_search_bar.dart';
import 'package:playfit/components/social/post_feed.dart';
import 'package:playfit/profile_page.dart';

// Social Page.
// This page is part of the PlayFit app and is used to display social features.
// It has a search bar to search users.
// The page displays the workout shared by the following users.
// - People you follow first.
// - Then the people you don't follow.
//
// Under each post, you can like it or comment on it. Only 3 comments are displayed.
// When you click on a post, it opens the post page. You can see the full post and all the comments.
// When you click on a user, it opens the user page. You can see the user's profile.
// You can follow or unfollow the user.

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
        title: const Text('Social'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: UserSearchBar(
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
          Expanded(
            child: PostFeed(),
          ),
        ],
      ),
    );
  }
}
