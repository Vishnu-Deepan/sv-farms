import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ActivePlanShimmer extends StatelessWidget {
  const ActivePlanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First shimmer box placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 70,
              width: MediaQuery.sizeOf(context).width/0.9,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Second shimmer box placeholder
          Center(child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ), ),

          SizedBox(height: 30),

          Center(child:Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 40,
              width: MediaQuery.sizeOf(context).width/0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ), ),



        ],
      ),
    );
  }
}
