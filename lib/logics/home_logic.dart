import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  String _planName = 'Loading...';
  double _remainingLiters = 0;
  int _totalLiters = 0;
  bool _isNextPlanAdded = false;
  late List<dynamic> _bannerImages = [];

  // Method to fetch user data and banner images
  Future<void> fetchData(
      Function(String username,String planName, double remainingLiters, int totalLiters,
              List<dynamic> bannerImages, bool nextPlanAdded)
          onDataFetched) async {
    try {
      // Fetch user ID
      _userId = _auth.currentUser!.uid;
      String? name = _auth.currentUser?.displayName;

      // Fetch user data (for now we will use user data only to get uid)
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (!userDoc.exists) {
        Fluttertoast.showToast(msg: "User not found.");
        return;
      }

      // Fetch active plan data based on the user ID (from subscriptions collection)
      var planDoc = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('uid', isEqualTo: _userId)
          .where("isActivePlan",isEqualTo: true)
          .get();
      if (planDoc.docs.isNotEmpty) {
        DocumentSnapshot existingPLan = planDoc.docs.first;
        Map<String, dynamic> planData =
            existingPLan.data() as Map<String, dynamic>;

        _planName = planData['planName'];
        _remainingLiters = planData['remainingLitres'];
        _totalLiters = planData['totalLitres']; // Fetch total liters
        _isNextPlanAdded = planData['nextPlanAdded'];
      } else {
        _planName = 'No Active Plan';
        _remainingLiters = 0;
        _totalLiters = 0; // If no active plan, set total liters to 0
        _isNextPlanAdded = false; // Default to false if no plan exists
      }

      // Fetch banner images
      QuerySnapshot<Map<String, dynamic>> bannersSnapshot =
          await FirebaseFirestore.instance
              .collection('banners')
              .where('isActive', isEqualTo: true)
              .orderBy('timestamp', descending: true)
              .get();

      _bannerImages = bannersSnapshot.docs
          .map((doc) => doc['imageUrl'] ?? '')
          .where((url) => url.isNotEmpty)
          .toList();

      // Pass data back to UI
      onDataFetched(name!,_planName, _remainingLiters, _totalLiters, _bannerImages,
          _isNextPlanAdded);
    } catch (e) {
      print("Error debug print : $e");
      Fluttertoast.showToast(msg: "Error fetching data: $e");
    }
  }
}
