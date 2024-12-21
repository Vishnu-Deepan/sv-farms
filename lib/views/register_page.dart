import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';  // Import shimmer package
import '../controllers/register_logic.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();  // Added controller for the name

  final RegisterLogic _registerLogic = RegisterLogic(); // Creating an instance of RegisterLogic

  bool _isRegistering = false;  // Flag to show shimmer effect

  // UI for Register Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset('assets/logo.png', height: 90),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Wrap everything in a SingleChildScrollView to make it scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [

              Padding(
                  padding: EdgeInsets.only(top: 20,bottom: 10),
                  child: Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 25, // Increased font size for more prominence
                      fontWeight: FontWeight.w900, // Maximum boldness
                      color: Colors.black, // Dark color for better contrast
                      letterSpacing: 2.0, // Slightly increased letter spacing for style
                      shadows: [
                        Shadow(
                          blurRadius: 10.0, // Makes the shadow more prominent
                          offset: Offset(3.0, 3.0), // Slightly offset to create depth
                          color: Colors.grey.withValues(alpha:0.5), // Shadow color with some transparency
                        ),
                      ],
                    ),
                  )
              ),

              // Tagline Text
              Text(
                'Fresh Milk, Daily Delivered',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 40),

              // Name Input Field
              _buildTextField(_nameController, 'Enter your name'),
              SizedBox(height: 20),

              // Phone Input Field
              _buildTextField(_phoneController, 'Enter your phone number', keyboardType: TextInputType.phone),
              SizedBox(height: 20),

              // Email Input Field
              _buildTextField(_emailController, 'Enter your email'),
              SizedBox(height: 20),

              // Password Input Field
              _buildTextField(_passwordController, 'Enter your password', obscureText: true),
              SizedBox(height: 20),

              // Confirm Password Input Field
              _buildTextField(_confirmPasswordController, 'Confirm your password', obscureText: true),
              SizedBox(height: 20),

              // Register Button with shimmer effect
              _isRegistering
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[100]!,
                highlightColor: Colors.grey[500]!,
                child: Container(

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Padding(padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),child:Text(
                      'Registering...',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                    ),
                  ),
                  ),
                ),
              )
                  : Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: _register, // This should be your register method
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),


              // Login link
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
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
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Register method
  void _register() {
    setState(() {
      _isRegistering = true;  // Start shimmer effect
    });

    _registerLogic.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      phone: _phoneController.text.trim(),
      name: _nameController.text.trim(),
      onSuccess: () {
        setState(() {
          _isRegistering = false;  // Stop shimmer effect
        });
        Fluttertoast.showToast(msg: "Registration successful!");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      onFailure: (errorMessage) {
        setState(() {
          _isRegistering = false;  // Stop shimmer effect
        });
        Fluttertoast.showToast(msg: errorMessage);  // Display specific error message
      },
    );
  }
}
