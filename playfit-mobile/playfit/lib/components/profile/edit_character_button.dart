import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:playfit/customization_page.dart';

/// A button widget that opens a character customization page when tapped.
class EditCharacterButton extends StatelessWidget {
  final String backgroundImageUrl;
  final VoidCallback? onClosed; // Add this

  const EditCharacterButton({
    super.key,
    required this.backgroundImageUrl,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 300),
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0XFFF8871F),
            ),
          ),
        );
      },
      openBuilder: (context, _) => CustomizationPage(
        backgroundImageUrl: backgroundImageUrl,
      ),
      onClosed: (_) {
        if (onClosed != null) {
          onClosed!();
        }
      },
    );
  }
}
