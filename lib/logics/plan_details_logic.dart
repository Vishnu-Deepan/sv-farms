import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/plans_model.dart';
import '../services/shared_preferences_helper.dart';

// List of plans (could be fetched from an API or database in a real scenario)
List<Plans> plans = [
  Plans(30, 1800),
  Plans(90, 5400),
  Plans(175, 10500),
  Plans(265, 15900),
  Plans(355, 20590, discount: 710),
];



// Customization Section Widget
class CustomizationSection extends StatelessWidget {
  final Plans plan;

  CustomizationSection({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Customize your daily delivery',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMilkQuantityOption(250),
            _buildMilkQuantityOption(500),
            _buildMilkQuantityOption(750),
            _buildMilkQuantityOption(1000),
            _buildMilkQuantityOption(1500),
            _buildMilkQuantityOption(2000),
          ],
        ),
        SizedBox(height: 20),
        ProgressBar(remainingLitres: plan.litres),
      ],
    );
  }

  Widget _buildMilkQuantityOption(int qty) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
        label: Text('${qty} ml'),
        selected: false,
        onSelected: (selected) {},
      ),
    );
  }
}

Future<void> addPendingPayment({
  required String userName,
  required String userEmail,
  required String userPhone,
  required String planName,
  required int planPrice,
  required LatLng deliveryLocation,
  required String fullAddress,
  required int totalLitres,
  required double morningLitres,
  required double eveningLitres,
  required DateTime planStartDate,
  required BuildContext context,
}) async {
  try {
    // Fetch user session from shared preferences
    Map<String, String?> sessionData = await SharedPreferencesHelper.getUserSession();
    String userId = sessionData['userId']!;

    // Prepare the order data to be stored
    var orderData = {
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'planName': planName,
      'planPrice': planPrice,
      'deliveryLocation': {
        'latitude': deliveryLocation.latitude,
        'longitude': deliveryLocation.longitude,
      },
      'fullAddress': fullAddress,
      'timestamp': FieldValue.serverTimestamp(),
      'isDeliveryAssigned': false,
      'totalLitres': totalLitres,
      'remainingLitres': totalLitres,
      'nextPlanAdded': false,
      'uid': userId,
      'morningLitres': morningLitres,
      'eveningLitres': eveningLitres,
      'planStartDate': planStartDate,
      'isActivePlan': false, // Default to true for new plans
    };

    // Add the new order data to Firestore with userId as document ID
    await FirebaseFirestore.instance
        .collection('pendingCashOrders')
        .doc(userId) // Set the userId as the document ID
        .set({...orderData, 'isActivePlan': false});

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order added to pending payments")));

  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating active plans: $e'))
    );
  }
}


// Progress Bar Widget
class ProgressBar extends StatelessWidget {
  final int remainingLitres;

  ProgressBar({required this.remainingLitres});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Remaining: $remainingLitres Litres'),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: remainingLitres / 355, // assuming max is 355 litres
          backgroundColor: Colors.grey.shade300,
          color: Colors.green,
        ),
      ],
    );
  }
}
