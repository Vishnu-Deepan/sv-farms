import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../logics/profile_logic.dart';
import '../services/shared_preferences_helper.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfilePageLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = ProfilePageLogic(context, setState);
    _logic.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Deep blue for background
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color(0xFF202C59), // Deep blue
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _logic.logout,
          ),
        ],
        toolbarHeight: 70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _logic.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Picture Section - Positioned and enlarged
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Color(0xFF3B4C7C),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Profile Info Section with modern cards for each info block
                    _buildProfileInfoCard(Icons.man,"Name", _logic.name),
                    const SizedBox(height: 20),
                    _buildProfileInfoCard(Icons.alternate_email_outlined,"Email", _logic.email),
                    const SizedBox(height: 20),
                    _buildProfileInfoCard(Icons.phone,"Phone", _logic.phone),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
    );
  }

  // Helper function to build profile information card with elegant styling
  Widget _buildProfileInfoCard(IconData icon,String label, String value) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        child: Container(
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B4C7C), // Lighter blue
                Color(0xFF202C59), // Deep blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.only(right: 10),child: Icon(icon,
                  color: Colors.white,),),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w800
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
