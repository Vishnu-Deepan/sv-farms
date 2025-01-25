import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/dailyLog_model.dart';
import '../services/dailyLog_localStorage_service.dart';
import 'package:intl/intl.dart';

Future<void> fetchAndStoreDeliveryLogs(String userUid) async {
  try {
    // Checking if logs have already been fetched
    bool areFetched = await LocalStorageService.areLogsFetched();

    if (!areFetched) {
      // Fetching data from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("dailyDeliveryLogs")
          .doc(userUid)
          .collection("logs")
          .get();

      if (querySnapshot.docs.isEmpty) {
        Fluttertoast.showToast(msg: "No logs found for the user.");
        return;
      }

      List<DailyDeliveryLog> logs = [];

      // Looping through each document and creating delivery logs
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Creating a DailyDeliveryLog object for each document
        DailyDeliveryLog deliveryLog = DailyDeliveryLog(
          eveningDelivered: data['eveningDelivered'] ?? false,
          eveningSkipped: data['eveningSkipped'] ?? false,
          morningDelivered: data['morningDelivered'] ?? false,
          morningSkipped: data['morningSkipped'] ?? false,
          date: doc.id,  // Using document ID (date) as the log date in "YYYY-MM-DD"
        );

        logs.add(deliveryLog);
      }

      // Storing the fetched logs locally using SharedPreferences
      await LocalStorageService.storeDeliveryLogs(logs);
      Fluttertoast.showToast(msg: "Data fetched and stored locally.");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Error fetching data: $e");
  }
}

Map<String, List<DailyDeliveryLog>> getEventsForCalendar(List<DailyDeliveryLog> logs) {
  Map<String, List<DailyDeliveryLog>> events = {};

  if (logs != null && logs.isNotEmpty) {
    for (var log in logs) {
      String dateString = log.date??"2025-01-01"; // Assuming 'log.date' is in 'yyyy-MM-dd' format
      if (!events.containsKey(dateString)) {
        events[dateString] = [];
      }
      events[dateString]!.add(log);
    }
  } else {
    print("No logs available to generate events.");
  }

  return events;
}

Future<void> fetchLogsFromDateToToday(String userUid, String lastFetchedDate) async {
  try {
    // Check if lastFetchedDate is in the correct format
    if (lastFetchedDate.isEmpty) {
      print("Error: lastFetchedDate is empty!");
      return;
    }

    // Validate the format before parsing
    DateTime startDate;
    try {
      startDate = DateFormat('yyyy-MM-dd').parse(lastFetchedDate);
    } catch (e) {
      print("Error: Invalid date format for lastFetchedDate: $lastFetchedDate");
      return;
    }

    // Get today's date
    DateTime today = DateTime.now();
    DateTime nextDay = today.add(Duration(days: 1));

    // Debug: Print the parsed dates
    print("Fetching logs from: $lastFetchedDate ($startDate) to today ($today) for userId $userUid");

    // Step 1: Fetch all the date-based collections (logs)
    var collectionSnapshot = await FirebaseFirestore.instance
        .collection("dailyDeliveryLogs")
        .doc(userUid)
        .collection("logs")
        .get(); // Get all date-based collections

    print("Fetched collections: ${collectionSnapshot.docs.length}");

    if (collectionSnapshot.docs.isEmpty) {
      print("No logs found for the given user.");
      return;
    }

    // Step 2: Filter collections based on the date range
    List<DailyDeliveryLog> newLogs = [];
    for (var doc in collectionSnapshot.docs) {
      String collectionDate = doc.id; // The collection name (the date)
      print("Found collection for date: $collectionDate");

      // Check if this collection's date is within the desired range
      if (collectionDate.compareTo(nextDay.toString()) <= 0) {
        // If the collection's date is in range, fetch documents inside this collection
        print("Fetching logs from collection: $collectionDate");

        var logSnapshot = await FirebaseFirestore.instance
            .collection("dailyDeliveryLogs")
            .doc(userUid)
            .collection("logs")
            .doc(collectionDate) // Reference to the specific date-based collection
            .get();

        if (!logSnapshot.exists) {
          print("No logs found for $collectionDate.");
        } else {
          print("Log Data: ${logSnapshot.data()}");
          DailyDeliveryLog log = DailyDeliveryLog.fromJson(logSnapshot.data()!);
          newLogs.add(log);

          // Debug: Print the log details
          print("Morning Delivered: ${log.morningDelivered}");
          print("Morning Skipped: ${log.morningSkipped}");
          print("Evening Delivered: ${log.eveningDelivered}");
          print("Evening Skipped: ${log.eveningSkipped}");
        }
      } else {
        print("Skipping collection $collectionDate, not within date range $startDate and $nextDay.");
      }
    }

    // Debug: Print the number of logs fetched
    print("Fetched ${newLogs.length} new logs from Firestore.");

    // If logs are fetched, update the UI (or process them)
    if (newLogs.isNotEmpty) {
      // Now you can pass this `newLogs` list to your UI or further logic
      print("Successfully fetched logs for the selected date range.");
      // Example: update the calendar events or UI based on newLogs
    } else {
      print("No logs found between $lastFetchedDate and today.");
    }
  } catch (e) {
    print("Error fetching logs: $e");
  }
}

