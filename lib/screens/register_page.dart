import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/shared_preferences_helper.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();  // Added controller for the name
  final _auth = FirebaseAuth.instance;

  // Register method
  Future<void> _register() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();  // Get the name entered by the user

      if (email.isEmpty || password.isEmpty || phone.isEmpty || name.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter all fields.");
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Set user display name and phone number
        await user.updateDisplayName(name); // Set the display name to the user's input name

        // You can also update the phone number if needed
        // await user.updatePhoneNumber(PhoneAuthProvider.credential(verificationId: "", smsCode: ""));

        // Save user session
        await SharedPreferencesHelper.saveUserSession(
          user.uid,
          user.email!,
          phone,
        );

        Fluttertoast.showToast(msg: "Registration successful!");

        // Navigate to Home/Dashboard after successful registration
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed. Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Tagline Text
            Text(
              'Fresh Milk, Daily Delivered',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 40),

            // Name Input Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 20),

            // Email Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 20),

            // Password Input Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 20),

            // Phone Input Field
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: Text('Register'),
            ),

            // Login link
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Already have an account? Login",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
