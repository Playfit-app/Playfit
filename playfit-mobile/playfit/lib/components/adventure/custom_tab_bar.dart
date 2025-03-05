import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
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
                  'Contenu pour l\'onglet Facile',
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 214, 110),
                  const Color.fromARGB(255, 255, 235, 185),
                  'Contenu pour l\'onglet Moyen',
                ),
                _buildTabContent(
                  const Color.fromARGB(255, 255, 124, 124),
                  const Color.fromARGB(255, 255, 186, 186),
                  'Contenu pour l\'onglet Facile',
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

  Widget _buildTabContent(Color borderColor, Color color, String text) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Column(
        children: [
          Container(
            height: 9,
            width: double.infinity,
            color: borderColor,
          ),
        ],
      ),
    );
  }
}
