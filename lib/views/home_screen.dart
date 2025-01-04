import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/home_logic.dart';
import '../services/shared_preferences_helper.dart';
import '../widgets/activePlan_shimmer.dart';
import '../widgets/banner_slider.dart';
import '../widgets/progress_indicator.dart';
import 'login_page.dart';
import '../widgets/nav_and_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageLogic _homePageLogic = HomePageLogic(); // Home logic instance
  String _planName = 'Loading...';
  int _remainingLiters = 0;
  int _totalLiters = 0; // Total Liters
  List<dynamic> _bannerImages = [];
  bool _isNextPlanAdded = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data when the page loads
  void _fetchData() async {
    await _homePageLogic
        .fetchData((planName, remainingLiters, totalLiters, bannerImages, nextPlanAdded) {
      setState(() {
        _planName = planName;
        _remainingLiters = remainingLiters;
        _totalLiters = totalLiters; // Update total liters
        _bannerImages = bannerImages;
        _isNextPlanAdded = nextPlanAdded;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(), // AppBar remains as a separate section
              _buildAnimatedCard(), // Animated Card section
              Padding(
                padding: EdgeInsets.all(15),
                child: BannerSlider(bannerImages: _bannerImages),
              ),
              _supportContact(), // Bottom section with contact info
            ],
          ),
        ),
      ),
    );
  }

  // AppBar combined with gradient background
  Widget _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SV Farms',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.white),
            onPressed:_logOut,
          ),
        ],

    );
  }

  // Animated Card with smooth transition to show plan data
  Widget _buildAnimatedCard() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, // Light background for card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _planName == 'Loading...'
          ? ActivePlanShimmer() // Shimmer effect while loading
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_planName Plan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
          ),
          Text(
            "Never run out of fresh milk. Track your plan, and enjoy the daily delivery!",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600,fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 20),
          Center(child:DecreasingProgressIndicator(
            remainingLiters: _remainingLiters,
            totalLiters: _totalLiters,
          ) ,),

          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_drink, color: Colors.blue.shade800, size: 22), // Milk drop icon
              SizedBox(width: 10),
              Text(
                'Remaining: $_remainingLiters out of $_totalLiters Liters',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.w900),
              ),
            ],
          ),

          // Inside _buildAnimatedCard() method
          (!_isNextPlanAdded && _remainingLiters < 8)
              ? Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                final bottomNavBarState = context.findAncestorStateOfType<BottomNavBarState>();
                bottomNavBarState?.onNavItemTapped(2);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orange.shade600, // White text color
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                'Activate New Plan', // Text on the button
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),)
              : SizedBox(),



        ],
      ),
    );
  }

  // Support Contact Button
  Widget _supportContact() {
    // Phone number for support
    final String supportPhoneNumber = 'tel:+919994376845'; // Replace with your actual support number

    Uri supportPhoneNumberUrl = Uri.parse(supportPhoneNumber);

    // Function to launch phone call
    Future<void> launchPhoneCall() async {
      if (await canLaunchUrl(supportPhoneNumberUrl)) {
        await launchUrl(supportPhoneNumberUrl);
      } else {
        throw 'Could not launch $supportPhoneNumber';
      }
    }

    return GestureDetector(
      onTap: launchPhoneCall, // On tap, make the phone call
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Container(
          height: 80, // Increase height to accommodate larger text
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                color: Colors.white,
                size: 28,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support', // English text for "Contact Support"
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Larger text like h1
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    'உதவிக்கு தொடர்பு கொள்ளவும்', // Tamil text for "Contact Support"
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Slightly smaller text like h2
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Log out the user and navigate to login page
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferencesHelper.clearSession();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>LoginPage())); // Navigate to login screen
    } catch (e) {
      Fluttertoast.showToast(msg: "Error logging out: $e");
    }
  }
}
