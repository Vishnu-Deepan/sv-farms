import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/home_logic.dart';
import '../widgets/activePlan_shimmer.dart';
import '../widgets/banner_slider.dart';
import '../widgets/progress_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data when the page loads
  void _fetchData() async {
    await _homePageLogic
        .fetchData((planName, remainingLiters, totalLiters, bannerImages) {
      setState(() {
        _planName = planName;
        _remainingLiters = remainingLiters;
        _totalLiters = totalLiters; // Update total liters
        _bannerImages = bannerImages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAnimatedCard(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(15),
              child: BannerSlider(bannerImages: _bannerImages),
            ),
            _supportContact(),
          ],
        ),
      ),
    );
  }

  // Animated Card with smooth transition to show plan data
  Widget _buildAnimatedCard() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade100, // Light green color for the card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: _planName == 'Loading...'
          ? ActivePlanShimmer() // Shimmer effect while loading
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _planName,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800),
                ),
                Text(
                  'This is your active plan, keep track of your progress and stay on top!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                SizedBox(height: 20),
                Center(
                  child: DecreasingProgressIndicator(
                    remainingLiters: _remainingLiters,
                    totalLiters: _totalLiters,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Remaining: $_remainingLiters / $_totalLiters Liters',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ), // Display plan information after loading
    );
  }


  Widget _supportContact() {
    // Phone number for support
    final String supportPhoneNumber = 'tel:+919994376845'; // Replace with your actual support number

    // Function to launch phone call
    Future<void> launchPhoneCall() async {
      if (await canLaunch(supportPhoneNumber)) {
        await launch(supportPhoneNumber);
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
}
