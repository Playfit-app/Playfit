import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/components/profile_icon.dart';

class PostCardContent extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> post;
  final bool showAllComments;

  const PostCardContent({
    super.key,
    required this.storage,
    required this.post,
    required this.showAllComments,
  });

  @override
  State<PostCardContent> createState() => _PostCardContentState();
}

class _PostCardContentState extends State<PostCardContent> {
  Future<void> _like() async {
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/like/");
    final token = await widget.storage.read(key: "token");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "post": widget.post['id'].toString(),
      },
    );

    if (response.statusCode == 201) {
      setState(() {
        widget.post['is_liked'] = true;
        widget.post['nb_likes'] += 1;
      });
    } else {
      print("Failed to like post: ${response.statusCode}");
    }
  }

  /// Sends a DELETE request to the server to unlike the current post.
  Future<void> _unlike() async {
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/unlike/");
    final token = await widget.storage.read(key: "token");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "post": widget.post['id'].toString(),
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        widget.post['is_liked'] = false;
        widget.post['nb_likes'] -= 1;
      });
    } else {
      throw Exception("Failed to unlike post: ${response.statusCode}");
    }
  }

  /// Builds the main content of a social post card widget.
  ///
  /// This widget displays the post's media (if available), user information,
  /// like button with like count, and the post's textual content. The layout
  /// adapts based on the screen size and whether all comments are shown.
  ///
  /// - Displays the post's media at the top, if present, with rounded corners.
  /// - Shows the user's profile icon and username.
  /// - Provides a like/unlike button and displays the number of likes.
  /// - Shows the post's content if it is not empty.
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final user = widget.post['user'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        border: Border.all(color: const Color(0xFFF8871F), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post['media'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Center(
                  child: Image.network(
                    widget.post['media'],
                    fit: BoxFit.cover,
                    width: widget.showAllComments
                        ? screenWidth - 24
                        : 150,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfileIcon(
                        imageUrl: user['base_character'],
                        size: 30,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(user['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      widget.post['is_liked']
                          ? IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: _unlike,
                            )
                          : IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: _like,
                            ),
                      Text('${widget.post['nb_likes']}'),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.post['content'] != null &&
                widget.post['content'].toString().isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
                child: Text(widget.post['content']),
              ),
          ],
        ),
      ),
    );
  }
}
