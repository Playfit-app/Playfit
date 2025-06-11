import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoricChart extends StatefulWidget {
  final List<String> last7Dates;
  final List<int> last7Exos;

  const HistoricChart({
    super.key,
    required this.last7Dates,
    required this.last7Exos,
  });

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

  /// Normalizes the right axis values to the left axis values.
  /// 
  /// This method takes a value from the right axis and scales it to fit within the range of the left axis.
  /// 
  /// `y` is the value from the right axis to be normalized.
  /// 
  /// Returns a [double] representing the normalized value on the left axis.
  double normalizeRightAxis(double y) {
    return ((y - minYRight) / (maxYRight - minYRight)) * (maxYLeft - minYLeft) +
        minYLeft;
  }

  /// Denormalizes the right axis values to the original right axis values.
  /// 
  /// This method takes a normalized value from the left axis and scales it back to the original range of the right axis.
  /// 
  /// `y` is the normalized value on the left axis to be denormalized.
  /// 
  /// Returns a [double] representing the denormalized value on the right axis.
  double denormalizeRightAxis(double y) {
    return ((y - minYLeft) / (maxYLeft - minYLeft)) * (maxYRight - minYRight) +
        minYRight;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        // Create the LineChartData object with the necessary configurations
        // including grid, titles, borders, and line bars.
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
                    widget.last7Dates[0],
                    widget.last7Dates[1],
                    widget.last7Dates[2],
                    widget.last7Dates[3],
                    widget.last7Dates[4],
                    widget.last7Dates[5],
                    widget.last7Dates[6],
                    ""
                  ];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.black, fontSize: 8),
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
            // Blue Line (left axis) (exos)
            LineChartBarData(
              spots: List.generate(
                widget.last7Exos.length,
                (index) => FlSpot(
                    index.toDouble(), widget.last7Exos[index].toDouble()),
              ),
              isCurved: false,
              barWidth: 2,
              color: leftColor,
              dotData: const FlDotData(show: true),
            ),
            // Red Line (right axis) (bpm)
            LineChartBarData(
              spots: [],
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
