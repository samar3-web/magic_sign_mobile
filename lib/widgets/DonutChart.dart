import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:magic_sign_mobile/constants.dart';

class DonutChart extends StatelessWidget {
  final Map<String, int> data;

  DonutChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: getSections(data),
          centerSpaceRadius: 60,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections(Map<String, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: getColor(entry.key),
        value: percentage,
        title: '${entry.key} ${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color getColor(String mediaType) {
    switch (mediaType) {
      case 'video':
        return kSecondaryColor;
      case 'pdf':
        return Colors.red;
      case 'image':
        return Colors.blueGrey;
      case 'font':
        return Colors.orange;
      case 'module':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
