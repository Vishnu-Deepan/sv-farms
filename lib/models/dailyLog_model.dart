class DailyDeliveryLog {
  bool eveningDelivered;
  bool eveningSkipped;
  bool morningDelivered;
  bool morningSkipped;
  String? date; // To store the date of the log

  DailyDeliveryLog({
    required this.eveningDelivered,
    required this.eveningSkipped,
    required this.morningDelivered,
    required this.morningSkipped,
    String? this.date,  // Date is necessary to identify each log entry
  });

  // Convert the model to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'eveningDelivered': eveningDelivered,
      'eveningSkipped': eveningSkipped,
      'morningDelivered': morningDelivered,
      'morningSkipped': morningSkipped,
      'date': date,
    };
  }

  // Convert JSON back to model (for retrieving from SharedPreferences)
  factory DailyDeliveryLog.fromJson(Map<String, dynamic> json) {
    return DailyDeliveryLog(
      eveningDelivered: json['eveningDelivered'],
      eveningSkipped: json['eveningSkipped'],
      morningDelivered: json['morningDelivered'],
      morningSkipped: json['morningSkipped'],
      date: json['date'],
    );
  }
}
