import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/components/adventure/custom_tab_bar.dart';

class WorkoutSessionDialog extends StatelessWidget {
  const WorkoutSessionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Dialog content
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      alignment: Alignment.topCenter,
      elevation: 1,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        // Cross to close dialog on top left. Title centered on top. Custom tab menu. Content.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Session n°1',
                  style: GoogleFonts.amaranth(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 20),
            // Tab menu
            CustomTabBar(),
          ],
        ),
      ),
    );
  }
}
