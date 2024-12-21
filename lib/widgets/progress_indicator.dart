import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DecreasingProgressIndicator extends StatelessWidget {
  final int _remainingLiters; // Remaining liters of milk
  final int _totalLiters; // Total liters of milk

  DecreasingProgressIndicator({
    required int remainingLiters,
    required int totalLiters,
  })  : _remainingLiters = remainingLiters,
        _totalLiters = totalLiters;

  @override
  Widget build(BuildContext context) {

    // Calculate the progress percentage (0 to 1)
    double progress = _totalLiters==0 ? 0.001 : _remainingLiters / _totalLiters;

    // Define the color logic based on progress
    Color progressColor;
    if (progress > 0.5) {
      progressColor = Colors.green; // Plenty of milk
    } else if (progress > 0.2) {
      progressColor = Colors.yellow; // Warning, less milk
    } else {
      progressColor = Colors.red; // Almost out of milk
    }

    return
        // Circular Progress Indicator
        CircularPercentIndicator(
      radius: MediaQuery.sizeOf(context).width/5,
      lineWidth: 20.0,
      percent: progress,
      center: Text(
        "${_remainingLiters.toStringAsFixed(1)} L",
        style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: progressColor),
      ),
      progressColor: progressColor,
      backgroundColor: Colors.grey.shade300,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
