import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sv_farms/views/login_page.dart';
import '../app_theme.dart';
import '../views/history_page.dart';
import '../views/home_screen.dart';
import '../views/plan_details_page.dart';
import '../views/profile_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;


  final List<Widget> _pages = [
    const HomePage(),
    const PlanDetailsPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  // Standard Flutter icons that can be used with AnimatedBottomNavigationBar
  final List<IconData> _icons = [
    Icons.home,      // Home Icon
    Icons.play_arrow,      // Plan Details Icon
    Icons.history,   // History Icon
    Icons.account_circle, // Profile Icon
  ];



  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('SV Farms'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logOut, icon: Icon(Icons.logout_rounded),color: Colors.white,),
        ],
      ),

        body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        scaleFactor: 0.5,
        icons: _icons,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.none,
        onTap: _onNavItemTapped,
        activeColor: AppTheme.primaryColor,
        inactiveColor: Colors.black54,
        height: 60,
        elevation: 2,
        iconSize: 28,
        blurEffect: true,
      ),
    );
  }

  // Log out the user and navigate to login page
  Future<void> _logOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>LoginPage())); // Navigate to login screen
    } catch (e) {
      Fluttertoast.showToast(msg: "Error logging out: $e");
    }
  }
}
