import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sv_farms/screens/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  late String _userId;
  String _planName = 'Loading...'; // Default value
  int _remainingLiters = 0; // Default value
  late List<String> _bannerImages = [];

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid; // Get current user ID
    _fetchData();
  }

  // Fetch user data and banners from Firebase
  Future<void> _fetchData() async {
    try {
      // Fetch current plan and remaining liters
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _planName = userDoc['planName'] ??
              'No Plan'; // Default to 'No Plan' if not available
          _remainingLiters =
              userDoc['remainingLiters'] ?? 0; // Default to 0 if not available
        });
      }

      // Fetch active banners for the slider
      var bannersSnapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();

      List<String> bannerImages = [];
      for (var banner in bannersSnapshot.docs) {
        String imageUrl = banner['imageUrl'] ?? ''; // Handle null imageUrl
        if (imageUrl.isNotEmpty) {
          bannerImages.add(imageUrl);
        }
      }

      setState(() {
        _bannerImages = bannerImages;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching data: $e");
    }
  }

  // Log out the user and navigate to login page
  Future<void> _logOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      ); // Navigate to login screen
    } catch (e) {
      Fluttertoast.showToast(msg: "Error logging out: $e");
    }
  }

  // Bottom Navigation Bar action
  void _onNavItemTapped(int index) {
    // Handle navigation logic here (e.g., navigate to other pages)
    print("Navigated to index: $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('SV FARMS'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logOut, icon: Icon(Icons.logout_rounded)),
        ],
      ),
      body: Stack(
        children: [
          // Main content above the Bottom Navigation Bar
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Dairy themed UI Card for Current Plan with shimmer effect
                  _buildShimmerCard(),

                  SizedBox(height: 20),

                  // Slider Banners for Banners with shimmer effect during loading
                  _buildBannerSlider(),

                  SizedBox(
                      height:
                          80), // Adjust space to avoid overlap with bottom nav
                ],
              ),
            ),
          ),

          // Fixed Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Plan Details',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: 0,
              selectedItemColor: Colors.green,
              onTap: _onNavItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer effect for the plan details card
  Widget _buildShimmerCard() {
    return _planName == 'Loading...'
        ? Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              color: Colors.orange.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading...',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Remaining Liters: 0',
                      style:
                          TextStyle(fontSize: 18, color: Colors.brown.shade600),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            color: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _planName,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Remaining Liters: $_remainingLiters',
                    style:
                        TextStyle(fontSize: 18, color: Colors.brown.shade600),
                  ),
                ],
              ),
            ),
          );
  }

  // Shimmer effect for banner slider
  Widget _buildBannerSlider() {
    return _bannerImages.isEmpty
        ? Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200,
              color: Colors.white,
            ),
          )
        : SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          );
  }
}
