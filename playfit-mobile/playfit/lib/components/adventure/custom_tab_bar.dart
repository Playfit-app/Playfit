import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final Map<String, List<dynamic>> workoutSessionExercises;

  const CustomTabBar({
    super.key,
    required this.workoutSessionExercises,
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildTab(
                0,
                'Facile',
                const Color.fromARGB(255, 187, 255, 137),
                isFirst: true,
              ),
              _buildTab(
                1,
                'Moyen',
                const Color.fromARGB(255, 255, 214, 110),
              ),
              _buildTab(
                2,
                'Difficile',
                const Color.fromARGB(255, 255, 124, 124),
                isLast: true,
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: IndexedStack(
              sizing: StackFit.expand,
              index: _selectedIndex,
              children: [
                _buildTabContent(
                  const Color.fromARGB(255, 187, 255, 137),
                  const Color.fromARGB(255, 232, 255, 215),
                  widget.workoutSessionExercises['beginner'] ?? [],
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 214, 110),
                  const Color.fromARGB(255, 255, 235, 185),
                  widget.workoutSessionExercises['intermediate'] ?? [],
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 124, 124),
                  const Color.fromARGB(255, 255, 186, 186),
                  widget.workoutSessionExercises['advanced'] ?? [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String text, Color color,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(10) : Radius.zero,
              topRight: isLast ? const Radius.circular(10) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
      Color borderColor, Color color, List<dynamic> content) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Column(
        children: [
          Container(
            height: 9,
            width: double.infinity,
            color: borderColor,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // two per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3 / 4, // adjust depending on card layout
              ),
              itemCount: content.length,
              itemBuilder: (context, index) {
                final item = content[index];
                final videoUrl = item['video_url'];
                final videoId = Uri.parse(videoUrl).queryParameters['v'];

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (videoId != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            'https://img.youtube.com/vi/$videoId/0.jpg',
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const SizedBox(height: 140),
                      Text(
                        item['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
