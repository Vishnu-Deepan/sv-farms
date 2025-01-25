import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logics/home_logic.dart';
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
  final HomePageLogic _homePageLogic = HomePageLogic();
  String _planName = 'Loading...';
  double _remainingLiters = 0;
  int _totalLiters = 0;
  List<dynamic> _bannerImages = [];
  bool _isNextPlanAdded = false;
  String? _username = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    await _homePageLogic.fetchData((username, planName, remainingLiters,
        totalLiters, bannerImages, nextPlanAdded) {
      setState(() {
        _planName = planName;
        _remainingLiters = remainingLiters;
        _totalLiters = totalLiters;
        _bannerImages = bannerImages;
        _isNextPlanAdded = nextPlanAdded;
        _username = username;
      });
    });
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
            // IconButton for logout with modern styling
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _logOut, // Call logOut method
              ),
            ],
            // Customize the app bar height (optional)
            toolbarHeight: 70, // Slightly larger app bar for a premium look
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(),
            _buildActivePlanCard(),
            _buildBannerSlider(),
            _buildContactSupport(),
          ],
        ),
      ),
    );
  }

  // Top section with welcome and quick summary
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFAF9F6), // Light neutral background for a clean look
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 6))
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_username',
              style: TextStyle(
                  color: Color(0xFF202C59),
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_drink, color: Color(0xFF56A8B2), size: 32),
                SizedBox(width: 10),
                Text(
                  '$_remainingLiters Liters Remaining of $_totalLiters Liters',
                  style: TextStyle(
                      color: Color(0xFF3E5C6E),
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 10),
            _remainingLiters < 8
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF56A8B2), // Soft teal button
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      final bottomNavBarState =
                          context.findAncestorStateOfType<BottomNavBarState>();
                      bottomNavBarState?.onNavItemTapped(2);
                    },
                    child: Text(
                      'Activate New Plan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  // Banner Slider Section
  Widget _buildBannerSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: BannerSlider(bannerImages: _bannerImages),
    );
  }

  // Active Plan Card with smoother look
  Widget _buildActivePlanCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF1F1F1), // Light grey card background
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, 6))
          ],
        ),
        padding: EdgeInsets.all(20),
        child: _planName == 'Loading...'
            ? ActivePlanShimmer() // Shimmer effect while loading
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_planName Plan',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202C59)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Track your milk delivery and enjoy fresh milk every day!',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8A9A9D),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: DecreasingProgressIndicator(
                      remainingLiters: _remainingLiters,
                      totalLiters: _totalLiters,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Contact Support Section with modern button
  Widget _buildContactSupport() {
    final String supportPhoneNumber =
        'tel:+919080700123'; // Actual support number
    Uri supportPhoneNumberUrl = Uri.parse(supportPhoneNumber);

    Future<void> launchPhoneCall() async {
      if (await canLaunchUrl(supportPhoneNumberUrl)) {
        await launchUrl(supportPhoneNumberUrl);
      } else {
        throw 'Could not launch $supportPhoneNumber';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: GestureDetector(
        onTap: launchPhoneCall,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF56A8B2), Color(0xFF56C3B0)], // Gradient button
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Contact Support',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Log out functionality
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferencesHelper.clearSession();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Error logging out: $e");
    }
  }
}
