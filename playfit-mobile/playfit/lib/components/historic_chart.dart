import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoricChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoricChartState();
}

class HistoricChartState extends State<HistoricChart> {
  final double minX = 0;
  final double maxX = 8;
  final double minYLeft = 0;
  final double maxYLeft = 5;
  final double minYRight = 50;
  final double maxYRight = 200;
  final leftColor = const Color(0xFF7391FD);
  final rightColor = const Color(0XFFFF0000);

  double normalizeRightAxis(double y) {
    // Normalize the right axis values to the left axis values
    return ((y - minYRight) / (maxYRight - minYRight)) * (maxYLeft - minYLeft) +
        minYLeft;
  }

  // Get the right axis value from the normalized right axis value
  double denormalizeRightAxis(double y) {
    return ((y - minYLeft) / (maxYLeft - minYLeft)) * (maxYRight - minYRight) +
        minYRight;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == minYLeft || value == 2.5 || value == maxYLeft) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(color: leftColor),
                    );
                  }
                  return Container();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  value = denormalizeRightAxis(value);

                  if (value == minYRight ||
                      value == 125 ||
                      value == maxYRight) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(color: rightColor),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> days = [
                    "",
                    "Lun.",
                    "Mar.",
                    "Mer.",
                    "Jeu.",
                    "Ven.",
                    "Sam.",
                    "Dim.",
                    ""
                  ];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    );
                  }
                  return Container();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            border: Border(
              left: BorderSide(
                color: leftColor,
                width: 1.5,
              ),
              bottom: const BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
              right: BorderSide(
                color: rightColor,
                width: 1.5,
              ),
            ),
          ),
          lineBarsData: [
            // Blue Line (left axis)
            LineChartBarData(
              spots: [
                const FlSpot(1, 2),
                const FlSpot(2, 3),
                const FlSpot(3, 2),
              ],
              isCurved: false,
              barWidth: 2,
              color: leftColor,
              dotData: const FlDotData(show: true),
            ),
            // Red Line (right axis)
            LineChartBarData(
              spots: [
                FlSpot(1, normalizeRightAxis(100)),
                FlSpot(2, normalizeRightAxis(125)),
                FlSpot(3, normalizeRightAxis(80)),
              ],
              isCurved: false,
              barWidth: 2,
              color: rightColor,
            ),
          ],
          minX: minX,
          maxX: maxX,
          minY: minYLeft,
          maxY: maxYLeft,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.barIndex == 0
                        ? "${spot.y.toInt()} exos"
                        : "${denormalizeRightAxis(spot.y).toInt()} bpm",
                    TextStyle(
                      color: spot.barIndex == 0 ? leftColor : rightColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
