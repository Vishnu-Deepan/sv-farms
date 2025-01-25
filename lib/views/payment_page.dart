import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Add this for LatLng type
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase integration
import 'package:sv_farms/views/home_screen.dart';
import 'package:sv_farms/widgets/nav_and_app_bar.dart';
import '../logics/payment_logic.dart';
import '../services/delivery_log_service.dart';
import '../services/shared_preferences_helper.dart'; // Import the PaymentLogic class

class PaymentPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String planName;
  final int planPrice;
  final int totalAmount;
  final LatLng deliveryLocation;
  final String fullAddress;
  final int totalLitres;
  final double morningLitres;
  final double eveningLitres;
  final DateTime planStartDate;

  // Constructor to pass data from PlanDetailsPage
  const PaymentPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.planName,
    required this.planPrice,
    required this.totalAmount,
    required this.deliveryLocation,
    required this.fullAddress,
    required this.totalLitres,
    required this.morningLitres,
    required this.eveningLitres,
    required this.planStartDate,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaymentLogic _paymentLogic;

  @override
  void initState() {
    super.initState();
    _paymentLogic = PaymentLogic(
      onPaymentSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        _updateSubscriptionStatus(); // Only update for successful payment

      },
      onPaymentFailure: (message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _paymentLogic.dispose();
  }

  // Open Razorpay Checkout
  void _openCheckout() {
    _paymentLogic.openCheckout(
      userName: widget.userName,
      userEmail: widget.userEmail,
      userPhone: widget.userPhone,
      planName: widget.planName,
      totalAmount: widget.totalAmount,
      fullAddress: widget.fullAddress,
    );
  }

  // Method to update subscription status and push to Firestore (Only on successful payment)
  Future<void> _updateSubscriptionStatus() async {
    try {
      Map<String, String?> sessionData = await SharedPreferencesHelper.getUserSession();
      String userId = sessionData['userId']!;

      var orderData = {
        'userName': widget.userName,
        'userEmail': widget.userEmail,
        'userPhone': widget.userPhone,
        'planName': widget.planName,
        'planPrice': widget.planPrice,
        'deliveryLocation': {
          'latitude': widget.deliveryLocation.latitude,
          'longitude': widget.deliveryLocation.longitude,
        },
        'fullAddress': widget.fullAddress,
        'timestamp': FieldValue.serverTimestamp(),
        'isDeliveryAssigned': false,
        'totalLitres': widget.totalLitres,
        'remainingLitres': widget.totalLitres,
        'nextPlanAdded': false,
        'uid': userId,
        'morningLitres': widget.morningLitres,
        'eveningLitres': widget.eveningLitres,
        'planStartDate': widget.planStartDate,
        'isActivePlan': true, // Default to true for new plans
      };

      // Query the 'subscriptions' collection for a document with the same userId (uid)
      QuerySnapshot existingPlans = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('uid', isEqualTo: userId)
          .get();

      // Check if any document exists for this userId
      if (existingPlans.docs.isNotEmpty) {
        DocumentSnapshot oldPlanDoc = existingPlans.docs.first;
        Map<String, dynamic> oldPlanData = oldPlanDoc.data() as Map<String, dynamic>;

        if (oldPlanData['remainingLitres'] == 0 && oldPlanData['nextPlanAdded'] == false) {
          // Case 1: If remainingLitres is 0 and nextPlanAdded is false, delete the old document and add the new one
          await oldPlanDoc.reference.delete();

          // Now, insert the new plan with isActivePlan as true
          await FirebaseFirestore.instance
              .collection('subscriptions')
              .add({...orderData, 'isActivePlan': true}); // Insert with isActivePlan as true
        } else if (oldPlanData['remainingLitres'] >= 1) {
          // Case 2: If remainingLitres >= 1, update nextPlanAdded to true and insert a new plan
          await oldPlanDoc.reference.update({
            'nextPlanAdded': true,
            'isActivePlan': false, // For the current plan, set isActivePlan to false
          });

          // Now, insert the new plan with isActivePlan as false (since it's not active yet)
          await FirebaseFirestore.instance
              .collection('subscriptions')
              .add({...orderData, 'isActivePlan': false}); // Insert with isActivePlan as false
        }
      } else {
        // No existing document for the user, add the new plan with isActivePlan as true
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .add({...orderData, 'isActivePlan': true});
      }

      // Create a default delivery log for the Start to End date of this plan
      double totalDaysDouble = widget.totalLitres / (widget.morningLitres + widget.eveningLitres);
      int totalDays = totalDaysDouble == (totalDaysDouble.toInt())
          ? totalDaysDouble.toInt() // If it's an integer, use the integer part
          : (totalDaysDouble.toInt() + 1); // If it's a double, round up to the next day

      DeliveryLogsService service = DeliveryLogsService();
      service.createDefaultDeliveryLogs(userId, widget.planStartDate, totalDays);

      // Optionally, navigate to another page after updating Firestore
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (BuildContext context) => BottomNavBar()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating active plans: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title with modern styling
        title: Text(
          'SV Farms',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Elegant letter spacing
          ),
        ),
        // Automatically adjusting the title position based on platform
        centerTitle: true,
        elevation: 4, // Adds subtle shadow for elevation
        backgroundColor: Color(0xFF202C59), // Deep blue color for modern look
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B4C7C), // Lighter blue
                Color(0xFF202C59), // Deep blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Customize the app bar height (optional)
        toolbarHeight: 70, // Slightly larger app bar for a premium look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Title
            Text(
              'Invoice',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // User Information Section
            Text(
              'Name: ${widget.userName}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              'Email: ${widget.userEmail}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              'Phone: ${widget.userPhone}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),

            // Plan Details Section
            Text(
              'Plan: ${widget.planName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(
              'Morning Litres: ${widget.morningLitres*1000} ml',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              'Evening Litres: ${widget.eveningLitres*1000} ml',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 20),

            // Total Amount Section
            Text(
              'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // Delivery Location Section (Lat/Lng)
            Text(
              'Delivery Location: ${widget.deliveryLocation.latitude}, ${widget.deliveryLocation.longitude}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text("\nStart Date : ${widget.planStartDate.day} / ${widget.planStartDate.month} / ${widget.planStartDate.year}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),

            SizedBox(height: 40),

            // Payment Button
            ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
