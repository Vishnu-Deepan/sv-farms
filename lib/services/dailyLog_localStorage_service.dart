import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/dailyLog_model.dart';

class LocalStorageService {
  static const String _deliveryLogsKey = 'dailyDeliveryLogs';
  static const String _isLogsFetchedKey = 'areLogsFetched';

  // Store multiple delivery logs in SharedPreferences
  static Future<void> storeDeliveryLogs(List<DailyDeliveryLog> logs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> logsJson =
        logs.map((log) => jsonEncode(log.toJson())).toList();
    await prefs.setStringList(_deliveryLogsKey, logsJson);
    await prefs.setBool(_isLogsFetchedKey, true); // Mark data as fetched
  }

  // Retrieve delivery logs from SharedPreferences
  static Future<List<DailyDeliveryLog>?> getDeliveryLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? areFetched = prefs.getBool(_isLogsFetchedKey);

    if (areFetched == true) {
      List<String>? logsJson = prefs.getStringList(_deliveryLogsKey);
      if (logsJson != null) {
        return logsJson
            .map((logJson) => DailyDeliveryLog.fromJson(jsonDecode(logJson)))
            .toList();
      }
    }
    return null; // Return null if no data exists
  }

  // Check if logs data has been fetched before
  static Future<bool> areLogsFetched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLogsFetchedKey) ?? false;
  }

  // Clear log data from SharedPreferences
  static Future<void> clearLogsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deliveryLogsKey);
    await prefs.remove(_isLogsFetchedKey);
  }

  // Method to update isMorningDelivered or isEveningDelivered for a particular date
  static Future<void> updateLogForDate(String date,
      {bool? isMorningDelivered, bool? isEveningDelivered}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? logsJson = prefs.getStringList(_deliveryLogsKey);

    if (logsJson != null) {
      // Decode logs into objects
      List<DailyDeliveryLog> logs = logsJson
          .map((logJson) => DailyDeliveryLog.fromJson(jsonDecode(logJson)))
          .toList();

      // Find the log for the given date
      DailyDeliveryLog? logToUpdate = logs.firstWhere(
        (log) => log.date == date,
      );

      // Update the fields based on the provided parameters
      if (isMorningDelivered != null) {
        logToUpdate.morningDelivered = isMorningDelivered;
      }
      if (isEveningDelivered != null) {
        logToUpdate.eveningDelivered = isEveningDelivered;
      }

      // Save the updated list back to SharedPreferences
      await storeDeliveryLogs(logs);
    }
  }
}
