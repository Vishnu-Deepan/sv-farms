import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/shared_preferences_helper.dart';

class RegisterLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to register the user
  Future<void> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String name,
    required Function onSuccess,
    required Function(String) onFailure,
  }) async {
    try {
      // Validation checks
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty || name.isEmpty) {
        onFailure("Please enter all fields.");
        return;
      }

      // Email Validation
      final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
      if (!emailRegex.hasMatch(email)) {
        onFailure("Please enter a valid email address.");
        return;
      }

      // Password and Confirm Password Validation
      if (password != confirmPassword) {
        onFailure("Passwords do not match.");
        return;
      }

      // Register the user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Set user display name
        await user.updateDisplayName(name);

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,  // User ID for easy identification
          'email': email,
          'name': name,
          'phone': phone,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Save user session
        await SharedPreferencesHelper.saveUserSession(user.uid, user.email!, phone);

        // Create the 'activePlans' collection with default values
        await _firestore.collection('subscriptions').add({
          'uid': user.uid,  // User ID for easy identification
          'planName': 'No Active Plan',
          'totalLitres': 0,
          'remainingLitres': 0,
          'nextPlanAdded':false,
          'userEmail': email,
          'userPhone': phone,
          'userName': name
        });


        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      // Specific Firebase Authentication error handling
      String errorMessage = _getFirebaseErrorMessage(e);
      onFailure(errorMessage);
    } catch (e) {
      // Generic error handler
      onFailure("Registration failed. Error: $e");
    }
  }

  // Method to map Firebase errors to error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid. Please check the email format.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'The password is incorrect. Please try again.';
      default:
        return 'An unknown error occurred: ${e.message}';
    }
  }
}
