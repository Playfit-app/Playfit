import 'package:flutter/material.dart';

class CharacterCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final void Function(int selectedIndex)? onImageSelected;

  const CharacterCarousel({
    super.key,
    required this.imageUrls,
    this.onImageSelected,
  });

  @override
  State<CharacterCarousel> createState() => _CharacterCarouselState();
}

class _CharacterCarouselState extends State<CharacterCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  void _goToPage(int index) {
    if (index >= 0 && index < widget.imageUrls.length) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = index);
      widget.onImageSelected?.call(index);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final newPage = _controller.page?.round() ?? 0;
      if (_currentPage != newPage) {
        setState(() => _currentPage = newPage);
        widget.onImageSelected?.call(newPage);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.fitHeight,
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 64,
            color: _currentPage == 0 ? Colors.grey : Color(0XFFF8871F),
            onPressed: () => _goToPage(_currentPage - 1),
          ),
        ),
        Positioned(
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            iconSize: 64,
            color: _currentPage == widget.imageUrls.length - 1
                ? Colors.grey
                : Color(0XFFF8871F),
            onPressed: () => _goToPage(_currentPage + 1),
          ),
        ),
      ],
    );
  }
}
