import 'package:flutter/material.dart';
import 'package:playfit/styles/styles.dart';

class StatisticBar extends StatelessWidget {
  const StatisticBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StatisticItem(
          title: 'VITESSE',
          value: 17,
        ),
        StatisticItem(
          title: 'PRECISION',
          value: 2,
        ),
        StatisticItem(
          title: 'FORCE',
          value: 4,
        ),
        StatisticItem(
          title: "ENDURANCE",
          value: 10,
        )
      ],
    );
  }
}

class StatisticItem extends StatelessWidget {
  final String title;
  final int value;

  const StatisticItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppStyles.beige,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // Drop shadow
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                title,
                style: AppStyles.bodyRegular,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ProgressBar(
                value: value,
                maxValue: 20,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 60,
              child: Text(
                "niv. $value",
                style: AppStyles.bodyRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final int value;
  final int maxValue;

  const ProgressBar({
    super.key,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = value / maxValue;

    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppStyles.brown,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Container(
          height: 10,
          width: percentage * 100,
          decoration: BoxDecoration(
            color: AppStyles.red,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}