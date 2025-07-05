import 'package:playfit/components/social/post_card/post_card_bottom.dart';
import 'package:playfit/components/social/post_card/post_card_comment_input.dart';
import 'package:playfit/components/social/post_card/post_card_comments.dart';
import 'package:playfit/components/social/post_card/post_card_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool showAllComments;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.post,
    this.showAllComments = false,
    this.isOwner = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

/// The private state class for the [PostCard] widget.
///
/// This class manages the UI and state for displaying a post card,
/// including its content, comments, and input for new comments.
///
/// Widgets included in the post card:
/// - [PostCardContent]: Displays the main content of the post.
/// - [PostCardCommentInput]: (conditionally shown) Input field for adding new comments.
/// - [PostCardComments]: Displays the list of comments for the post.
/// - [PostCardBottom]: Displays the bottom section of the post card (e.g., actions).
class _PostCardState extends State<PostCard> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: [
          PostCardContent(
            storage: storage,
            post: widget.post,
            showAllComments: widget.showAllComments,
          ),
          if (widget.showAllComments) ...[
            PostCardCommentInput(storage: storage, post: widget.post),
          ],
          PostCardComments(
            storage: storage,
            post: widget.post,
            showAllComments: widget.showAllComments,
            isOwner: widget.isOwner,
          ),
          PostCardBottom(),
        ],
      ),
    );
  }
}
