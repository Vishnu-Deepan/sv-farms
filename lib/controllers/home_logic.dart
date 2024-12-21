// home_page_logic.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  String _planName = 'Loading...';
  int _remainingLiters = 0;
  late List<dynamic> _bannerImages = [];

  // Method to fetch user data and banner images
  Future<void> fetchData(Function(String planName, int remainingLiters, List<dynamic> bannerImages) onDataFetched) async {
    try {
      // Fetch user data
      _userId = _auth.currentUser!.uid;
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      _planName = userDoc['planName'] ?? 'No Plan';
      _remainingLiters = userDoc['remainingLiters'] ?? 0;

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
      onDataFetched(_planName, _remainingLiters, _bannerImages);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching data: $e");
    }
  }
}
