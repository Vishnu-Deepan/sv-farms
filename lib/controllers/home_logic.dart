import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  String _planName = 'Loading...';
  int _remainingLiters = 0;
  int _totalLiters = 0;  // Add total liters
  late List<dynamic> _bannerImages = [];

  // Method to fetch user data and banner images
  Future<void> fetchData(Function(String planName, int remainingLiters, int totalLiters, List<dynamic> bannerImages) onDataFetched) async {
    try {
      // Fetch user ID
      _userId = _auth.currentUser!.uid;

      // Fetch user data (for now we will use user data only to get uid)
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (!userDoc.exists) {
        Fluttertoast.showToast(msg: "User not found.");
        return;
      }

      // Fetch active plan data based on the user ID (from activePlans collection)
      var planDoc = await FirebaseFirestore.instance.collection('activePlans').doc(_userId).get();
      if (planDoc.exists) {
        _planName = planDoc['planName'] ?? 'No Active Plan';
        _remainingLiters = planDoc['remainingLitres'] ?? 0;
        _totalLiters = planDoc['totalLitres'] ?? 0;  // Fetch total liters
      } else {
        _planName = 'No Active Plan';
        _remainingLiters = 0;
        _totalLiters = 0;  // If no active plan, set total liters to 0
      }

      // Fetch banner images
      QuerySnapshot<Map<String, dynamic>> bannersSnapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();

      _bannerImages = bannersSnapshot.docs
          .map((doc) => doc['imageUrl'] ?? '')
          .where((url) => url.isNotEmpty)
          .toList();

      // Pass data back to UI
      onDataFetched(_planName, _remainingLiters, _totalLiters, _bannerImages);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching data: $e");
    }
  }
}
