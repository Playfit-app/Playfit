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
