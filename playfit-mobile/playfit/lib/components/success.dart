import 'dart:ui';
import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  final String image;
  final bool completed;
  final String? title;
  final int? meters;

  const Success({
    super.key,
    required this.image,
    required this.completed,
    this.title,
    this.meters,
  });

  void _showSuccessPopup(BuildContext context) {
    if (!completed) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Success Dialog",
      barrierColor: Colors.black.withAlpha((0.2 * 255).toInt()),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(image),
                  ),
                  const SizedBox(height: 16),
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const Divider(color: Colors.orange),
                  const SizedBox(height: 8),
                  if (meters != null)
                    Text(
                      "Parcourir $meters mètres",
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSuccessPopup(context),
      child: Opacity(
        opacity: completed ? 1.0 : 0.4,
        child: Container(
          height: MediaQuery.of(context).size.width * 0.17,
          width: MediaQuery.of(context).size.width * 0.17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? Colors.black : Colors.grey,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
