import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:sv_farms/views/payment_page.dart';
import 'package:intl/intl.dart';
import 'map_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PlanDetailsPage(),
    );
  }
}

class PlanDetailsPage extends StatefulWidget {
  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
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

  // Available plans
  List<Map<String, dynamic>> plans = [
    {'name': '30 Litres', 'price': 1800, 'litres': 30},
    {'name': '90 Litres', 'price': 5400, 'litres': 90},
    {'name': '175 Litres', 'price': 10500, 'litres': 175},
    {'name': '265 Litres', 'price': 15900, 'litres': 265},
    {'name': '355 Litres', 'price': 20590, 'litres': 355, 'discount': 710},
  ];

  // Get user location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Firebase authentication (simplified, you should handle errors and loading)
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'Guest';
        userEmail = user.email ?? 'N/A';
        userPhone = user.phoneNumber ?? 'N/A';
      });
      // Fetching phone number from Firestore users collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userPhone = userDoc['phone'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  // Callback function to update the delivery location
  void _updateLocation(LatLng location) {
    setState(() {
      deliveryLocation = location;
      isLocationSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Plan')),
      body: PageView(
        controller: _pageController,
        children: [
          _buildPlanSelectionPage(),
          _buildQuantitySelectionPage(),
          _buildDateSelectionPage(), // Date Picker Page
          MapPage(_pageController,_updateLocation), // Pass _pageController to MapPage
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
        Text("Select Delivery Plan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...plans
            .map((plan) => Card(
          child: ListTile(
            title: Text(plan['name']),
            subtitle: Text('₹${plan['price']}'),
            onTap: () {
              setState(() {
                selectedPlan = plan['name'];
                selectedPlanPrice = plan['price'];
                selectedPlanLitres = plan['litres']; // Set selected litres
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

  // Quantity Selection Page (Morning & Evening)
  Widget _buildQuantitySelectionPage() {
    return Column(
      children: [
        Text("Select Delivery Quantity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Text("Morning: "),
            DropdownButton<double>(
              value: morningAmount,
              items: [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0]
                  .map((amount) => DropdownMenuItem(
                  value: amount,
                  child: Text('${(amount * 1000).toInt()} ml')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  morningAmount = value ?? 0;
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            Text("Evening: "),
            DropdownButton<double>(
              value: eveningAmount,
              items: [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0]
                  .map((amount) => DropdownMenuItem(
                  value: amount,
                  child: Text('${(amount * 1000).toInt()} ml')))
                  .toList(),
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

  // Add a page for date selection
  Widget _buildDateSelectionPage() {
    return Column(
      children: [
        Text("Select Plan Start Date",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              // Proceed to the next page and pass the selected date
              _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease);
            } else {
              // Show an error message if no date is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select a start date")),
              );
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
        Text("Enter Delivery Address",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        Text("Order Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Plan: $selectedPlan"),
        Text("Morning Delivery: ${morningAmount * 1000} ml"),
        Text("Evening Delivery: ${eveningAmount * 1000} ml"),
        Text(
            "Location: ${deliveryLocation.latitude}, ${deliveryLocation.longitude}"),
        Text("Address: $fullAddress"),
        Text("User: $userName"),
        Text("Email: $userEmail"),
        Text("Phone: $userPhone"),
        Text("Start Date : ${selectedStartDate.day} / ${selectedStartDate.month} / ${selectedStartDate.year}"),
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
                    )
                )); // Pass litres
          },
          child: Text('Proceed to Pay'),
        ),
      ],
    );
  }
}
