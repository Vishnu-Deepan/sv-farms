import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices{
  static Future saveFcmToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> data = {
      "email": user!.email,
      "token": token,
    };
    try {
      await FirebaseFirestore.instance
          .collection("fcm_data")
          .doc(user.uid)
          .set(data);

      print("Document Added to ${user.uid}");
    } catch (e) {
      print("error in saving to firestore");
      print(e.toString());
    }
  }
}