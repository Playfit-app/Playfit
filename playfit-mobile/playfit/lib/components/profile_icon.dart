import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileIcon extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileIcon({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Build a circular profile icon with a default background color
    // and an image if provided, otherwise show a person icon.
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 204, 255, 178),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: imageUrl != null
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14),
                child: Image.network(
                  imageUrl!.startsWith('http')
                      ? imageUrl!
                      : "${dotenv.env['SERVER_BASE_URL']}${imageUrl!}",

                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              )
            : Icon(
                Icons.person,
                size: size,
              ),
      ),
    );
  }
}
