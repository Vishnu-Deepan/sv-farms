import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DeliveryLog {
  final bool morningDelivered;
  final bool eveningDelivered;
  final bool morningSkipped;
  final bool eveningSkipped;
  final double remainingLitres;
  final double skippedLitres;

  DeliveryLog({
    required this.morningDelivered,
    required this.eveningDelivered,
    required this.morningSkipped,
    required this.eveningSkipped,
    required this.remainingLitres,
    required this.skippedLitres
  });

  // Convert Firestore DocumentSnapshot to DeliveryLog instance
  factory DeliveryLog.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return DeliveryLog(
      morningDelivered: data['morningDelivered'] ,
      eveningDelivered: data['eveningDelivered'] ,
      morningSkipped: data['morningSkipped'] ,
      eveningSkipped: data['eveningSkipped'] ,
      remainingLitres: data['remainingLitres'],
      skippedLitres: data['skippedLitres'],
    );
  }

  // Convert the DeliveryLog instance to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'morningDelivered': morningDelivered,
      'eveningDelivered': eveningDelivered,
      'morningSkipped': morningSkipped,
      'eveningSkipped': eveningSkipped,
      'remainingLitres': remainingLitres,
      'skippedLitres': skippedLitres,
    };
  }
}

class DeliveryLogsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create default delivery logs for the given number of days starting from the next day
  Future<void> createDefaultDeliveryLogs(String userId, DateTime startDate, int totalDays) async {
    try {
      // Get the next day from the plan's start date
      DateTime nextDay = startDate.add(Duration(days: 1));

      // Loop through the totalDays and create a document for each date
      for (int i = 0; i < totalDays; i++) {
        // Calculate the date for this iteration
        DateTime currentDate = nextDay.add(Duration(days: i));
        String dateStr = DateFormat('yyyy-MM-dd').format(currentDate); // Format the date as a string

        // Create a default DeliveryLog for the current date
        DeliveryLog defaultLog = DeliveryLog(
          morningDelivered: false,
          eveningDelivered: false,
          morningSkipped: false,
          eveningSkipped: false,
          remainingLitres: 0.0,
          skippedLitres: 0.0,
        );

        // Store the default log in Firestore under the user's daily delivery logs collection
        await _firestore
            .collection('dailyDeliveryLogs')
            .doc(userId)
            .collection('logs')
            .doc(dateStr) // Use the formatted date as the document ID
            .set(defaultLog.toMap());
      }
    } catch (e) {
      print("Error creating default delivery logs: $e");
    }
  }
}
