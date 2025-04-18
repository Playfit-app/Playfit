import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final Map<String, List<dynamic>> workoutSessionExercises;
  final void Function(String difficulty)? onTabChanged;

  const CustomTabBar({
    super.key,
    required this.workoutSessionExercises,
    this.onTabChanged,
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Map<String, List<List<Map<String, dynamic>>>> _exercises = {
    'beginner': [],
    'intermediate': [],
    'advanced': [],
  };

  @override
  void initState() {
    super.initState();
    _exercises.addAll(_groupExercises());
  }

  Map<String, List<List<Map<String, dynamic>>>> _groupExercises() {
    Map<String, List<List<Map<String, dynamic>>>> groupedExercises = {
      'beginner': [],
      'intermediate': [],
      'advanced': [],
    };

    for (var difficulty in widget.workoutSessionExercises.keys) {
      List<List<Map<String, dynamic>>> rows = [];

      for (var exercise in widget.workoutSessionExercises[difficulty]!) {
        if (exercise['name'] == "jumpingJack") {
          rows.add([exercise]);
        } else {
          if (rows.isEmpty || rows.last.length == 2) {
            rows.add([exercise]);
          } else {
            rows.last.add(exercise);
          }
        }
      }
      groupedExercises[difficulty] = rows;
    }
    return groupedExercises;
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (widget.onTabChanged != null) {
      String difficulty = ['beginner', 'intermediate', 'advanced'][index];
      widget.onTabChanged!(difficulty);
    }
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
            height: MediaQuery.of(context).size.height * 0.4,
            child: IndexedStack(
              sizing: StackFit.expand,
              index: _selectedIndex,
              children: [
                _buildTabContent(
                  const Color.fromARGB(255, 187, 255, 137),
                  const Color.fromARGB(255, 232, 255, 215),
                  _exercises['beginner'] ?? [],
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 214, 110),
                  const Color.fromARGB(255, 255, 235, 185),
                  _exercises['intermediate'] ?? [],
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 124, 124),
                  const Color.fromARGB(255, 255, 186, 186),
                  _exercises['advanced'] ?? [],
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 9,
            width: double.infinity,
            color: borderColor,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: content.length,
              itemBuilder: (context, index) {
                final row = content[index];

                if (row.length == 1) {
                  return _buildExerciseCard(row[0], fullWidth: true);
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildExerciseCard(row[0]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildExerciseCard(row[1]),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise,
      {bool fullWidth = false}) {
    final name = exercise['name'];
    final image = exercise['image'];
    final reps = exercise['repetitions'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              height: fullWidth ? 140 : 100,
            ),
          ),
          Text(
            "$reps $name",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
