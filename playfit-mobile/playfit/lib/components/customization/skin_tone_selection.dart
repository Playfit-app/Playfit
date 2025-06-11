import 'package:flutter/material.dart';

class SkinToneSelection extends StatefulWidget {
  final List<String> imageUrls;
  final void Function(int selectedIndex)? onImageSelected;

  const SkinToneSelection({
    super.key,
    required this.imageUrls,
    this.onImageSelected,
  });

  @override
  State<SkinToneSelection> createState() => _SkinToneSelectionState();
}

class _SkinToneSelectionState extends State<SkinToneSelection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(2, (index) {
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            widget.onImageSelected?.call(index);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE9CA) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFFFE9CA) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.fitHeight,
            ),
          ),
        );
      }),
    );
  }
}
