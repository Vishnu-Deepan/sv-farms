import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:sv_farms/logics/plan_details_logic.dart';
import 'package:sv_farms/views/payment_page.dart';
import 'package:intl/intl.dart';
import 'map_page.dart';

class PlanDetailsPage extends StatefulWidget {
  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  bool pastOrderPending = false;
  PageController _pageController = PageController();
  String selectedPlan = '';
  int selectedPlanPrice = 0;
  double morningAmount = 0;
  double eveningAmount = 0;
  LatLng deliveryLocation = LatLng(0, 0);
  bool isLocationSelected = false;
  String fullAddress = '';
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  int selectedPlanLitres = 0;
  DateTime selectedStartDate = DateTime.now();

  List<Map<String, dynamic>> plans = [
    {'name': '30 Litres', 'price': 1800, 'litres': 30},
    {'name': '90 Litres', 'price': 5400, 'litres': 90},
    {'name': '175 Litres', 'price': 10500, 'litres': 175},
    {'name': '265 Litres', 'price': 15900, 'litres': 265},
    {'name': '355 Litres', 'price': 20590, 'litres': 355, 'discount': 710},
  ];

  Future<void> showConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Cash Payment"),
          content: Text(
              "Are you sure you want to pay by cash? The plan will be activated once the cash is received by the admin."),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Handle the confirmation action here (e.g., save data to Firestore)
                addPendingPayment(userName: userName,
                    userEmail: userEmail,
                    userPhone: userPhone,
                    planName: selectedPlan,
                    planPrice: selectedPlanPrice,
                    deliveryLocation: deliveryLocation,
                    fullAddress: fullAddress,
                    totalLitres: selectedPlanLitres,
                    morningLitres: morningAmount,
                    eveningLitres: eveningAmount,
                    planStartDate: selectedStartDate,
                    context: context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Your order is pending confirmation from the admin.")));
                setState(() {
                  pastOrderPending = true;
                });
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'Guest';
        userEmail = user.email ?? 'N/A';
        userPhone = user.phoneNumber ?? 'N/A';
      });
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userPhone = userDoc['phone'];
        });
      }
    }
  }

  void _updateLocation(LatLng location) {
    setState(() {
      deliveryLocation = location;
      isLocationSelected = true;
    });
  }

  // Function to check if the logged-in user has a pending payment
  void isPreviousPaymentPending() async {
    String? userId =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user ID

    if (userId == null) {
      print("No user logged in.");
      return;
    }

    try {
      // Check if the document with the user's UID exists in 'pendingPayments'
      DocumentSnapshot userPaymentDoc = await FirebaseFirestore.instance
          .collection("pendingCashOrders")
          .doc(userId) // Document ID is the UID of the logged-in user
          .get();

      if (userPaymentDoc.exists) {
        // If the document exists, set pastOrderPending to true
        setState(() {
          pastOrderPending = true;
        });
      } else {
        // If the document does not exist, set pastOrderPending to false
        setState(() {
          pastOrderPending = false;
        });
      }
    } catch (e) {
      print("Error checking payment status: $e");
      setState(() {
        pastOrderPending = false; // In case of error, assume no pending order
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    isPreviousPaymentPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plan Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color(0xFF202C59),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B4C7C), Color(0xFF202C59)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: pastOrderPending
          ? Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child: Center(
                child: Text("Previous Order Payment Pending"),
              ),
            )
          : PageView(
              controller: _pageController,
              children: [
                _buildPlanSelectionPage(),
                _buildQuantitySelectionPage(),
                _buildDateSelectionPage(),
                MapPage(_pageController, _updateLocation),
                _buildAddressInputPage(),
                _buildOrderSummaryPage(),
              ],
            ),
    );
  }

  // Plan Selection Page
  Widget _buildPlanSelectionPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Select Delivery Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...plans
            .map((plan) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Color(0xFFE5E5E5),
                  child: ListTile(
                    title: Text(plan['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${plan['price']}'),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      setState(() {
                        selectedPlan = plan['name'];
                        selectedPlanPrice = plan['price'];
                        selectedPlanLitres = plan['litres'];
                      });
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  ),
                ))
            .toList(),
      ],
    );
  }

  // Quantity Selection Page
  Widget _buildQuantitySelectionPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Select Delivery Quantity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Morning: "),
            DropdownButton<double>(
              value: morningAmount,
              items: [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0].map((amount) {
                return DropdownMenuItem(
                    value: amount,
                    child: Text('${(amount * 1000).toInt()} ml'));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  morningAmount = value ?? 0;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Evening: "),
            DropdownButton<double>(
              value: eveningAmount,
              items: [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0].map((amount) {
                return DropdownMenuItem(
                    value: amount,
                    child: Text('${(amount * 1000).toInt()} ml'));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  eveningAmount = value ?? 0.0;
                });
              },
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            _pageController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          child: Text('Next'),
        ),
      ],
    );
  }

  // Date Selection Page
  Widget _buildDateSelectionPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Select Plan Start Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != selectedStartDate) {
              setState(() {
                selectedStartDate = pickedDate;
              });
            }
          },
          child: Text(
            selectedStartDate == null
                ? "Select Date"
                : DateFormat('yyyy-MM-dd').format(selectedStartDate!),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedStartDate != null) {
              _pageController.nextPage(
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a start date")));
            }
          },
          child: Text('Next'),
        ),
      ],
    );
  }

  // Address Input Page
  Widget _buildAddressInputPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Enter Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              fullAddress = value;
            });
          },
          decoration: InputDecoration(hintText: "Enter full address..."),
        ),
        ElevatedButton(
          onPressed: () {
            _pageController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          child: Text('Next'),
        ),
      ],
    );
  }

  // Order Summary Page
  Widget _buildOrderSummaryPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Color(0xFFE5E5E5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Plan: $selectedPlan"),
                Text("Morning Delivery: ${morningAmount * 1000} ml"),
                Text("Evening Delivery: ${eveningAmount * 1000} ml"),
                Text(
                    "Location: ${deliveryLocation.latitude}, ${deliveryLocation.longitude}"),
                Text("Address: $fullAddress"),
                Text("User: $userName"),
                Text("Email: $userEmail"),
                Text("Phone: $userPhone"),
                Text(
                    "Start Date : ${selectedStartDate.day} / ${selectedStartDate.month} / ${selectedStartDate.year}"),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => PaymentPage(
                          userName: userName,
                          userEmail: userEmail,
                          userPhone: userPhone,
                          planName: selectedPlan,
                          planPrice: selectedPlanPrice,
                          totalAmount: selectedPlanPrice,
                          deliveryLocation: deliveryLocation,
                          fullAddress: fullAddress,
                          totalLitres: selectedPlanLitres,
                          morningLitres: morningAmount,
                          eveningLitres: eveningAmount,
                          planStartDate: selectedStartDate,
                        )));
          },
          child: Text('Pay Online'),
        ),
        ElevatedButton(
          onPressed: () {
            showConfirmationDialog(context); // Call the dialog function
          },
          child: Text("Pay as CASH"),
        ),
      ],
    );
  }
}
