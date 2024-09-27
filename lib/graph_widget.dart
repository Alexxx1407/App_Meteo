import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import FL Chart

// Function to generate the graph for the temperature data
void showTemperatureGraphPopup(BuildContext context, String location, List<double> temperatures) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Hourly Temperatures for $location"),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: LineChart(
            LineChartData(
              minY: temperatures.reduce((a, b) => a < b ? a : b) - 2, // Adjust Y-axis to fit temperature range
              maxY: temperatures.reduce((a, b) => a > b ? a : b) + 2,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Now');
                        case 2:
                          return const Text('+6h');
                        case 4:
                          return const Text('+12h');
                        case 6:
                          return const Text('+18h');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: temperatures.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurpleAccent.withOpacity(0.3),
                        Colors.deepPurpleAccent.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
