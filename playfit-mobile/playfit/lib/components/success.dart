import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  final String image;
  final bool completed;
  final String title;
  final String description;
  final int target;
  final int current;
  final String? awardedAt;

  const Success({
    super.key,
    required this.image,
    required this.completed,
    required this.title,
    required this.description,
    required this.target,
    required this.current,
    this.awardedAt,
  });

  String get _formattedDate {
    if (awardedAt != null) {
      final dateTime = DateTime.parse(awardedAt!);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
    return "";
  }

  void _showSuccessPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
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
                    backgroundImage: NetworkImage(image),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: current / target,
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$current / $target",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  awardedAt != null
                      ? Text(
                          "Awarded at: $_formattedDate",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : const SizedBox.shrink(),
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
              child: Image.network(
            image,
            fit: BoxFit.cover,
          )),
        ),
      ),
    );
  }
}
