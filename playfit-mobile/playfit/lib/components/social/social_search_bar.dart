import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:playfit/search_user_page.dart';

class SocialSearchBar extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onUserSelected;
  const SocialSearchBar({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<SocialSearchBar> createState() => _SocialSearchBarState();
}

/// This widget uses an [OpenContainer] to provide a smooth transition between
/// a non-interactive search bar and a full search page. When closed, it displays
/// a disabled [TextField] styled as a search bar. When tapped, it transitions
/// to the [SearchUsersPage], allowing the user to search and select users.
class _SocialSearchBarState extends State<SocialSearchBar> {
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 0,
          closedColor: Colors.transparent,
          openColor: Theme.of(context).scaffoldBackgroundColor,
          closedBuilder: (context, openContainer) {
            return IgnorePointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          },
          openBuilder: (context, _) => SearchUsersPage(onUserSelected: widget.onUserSelected),
        );
  }
}
