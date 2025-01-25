import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../logics/calendar_logic.dart';
import '../models/dailyLog_model.dart';
import '../services/dailyLog_localStorage_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool isDataFetched = false;
  List<DailyDeliveryLog> deliveryLogs = [];
  late Map<String, List<DailyDeliveryLog>> _events;
  DateTime _selectedDay = DateTime.now();  // Keep track of the selected day

  @override
  void initState() {
    super.initState();
    _loadData();

  }

  // Method to load data
  Future<void> _loadData() async {
    String? userId = FirebaseAuth.instance.currentUser!.uid;
    String userUid = userId!;  // Ensure user UID is non-null

    // Always fetch today's log from Firestore and update local storage
    await fetchLogsFromDateToToday(userUid, "2025-01-15");

    // After fetching and storing, get the logs from SharedPreferences (local storage)
    List<DailyDeliveryLog>? logs = await LocalStorageService.getDeliveryLogs();

    if (logs != null && logs.isNotEmpty) {
      // Find today's log after the update
      DateTime today = DateTime.now();
      String todayDateString = DateFormat('yyyy-MM-dd').format(today);
      DailyDeliveryLog? todaysLog = logs.firstWhere(
            (log) => log.date == todayDateString,
        // orElse: () => null,  // Add this to prevent an exception if no log is found
      );

      // If today's log is found in the local storage, proceed to update the UI
      if (todaysLog != null) {
        setState(() {
          deliveryLogs = logs;
          isDataFetched = true;

          // Safely pass the logs to getEventsForCalendar
          _events = getEventsForCalendar(logs);
        });
      } else {
        print("No log found for today.");
      }
    } else {
      print("No logs found in local storage.");
    }
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Convert the selected day to "YYYY-MM-DD" format (string) to match the event key
    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDay);

    setState(() {
      _selectedDay = selectedDay;
      debugPrint("Selected day: $selectedDateString");  // Debug the selected date string
    });
  }

  // Build the calendar with events and style the days based on delivery data
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),  // Set to a date far enough in the past
      lastDay: DateTime.utc(2026, 12, 31), // Set to a future date
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) {
        // Convert the selected day to "YYYY-MM-DD" format and compare
        String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay);
        String dayString = DateFormat('yyyy-MM-dd').format(day);
        return selectedDateString == dayString;  // Compare date as strings
      },
      eventLoader: (day) {
        String dayString = DateFormat('yyyy-MM-dd').format(day); // Convert day to string
        return _events[dayString] ?? [];  // Return events for the selected day
      },
      calendarFormat: CalendarFormat.month,
      onDaySelected: _onDaySelected,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        // Highlight days based on delivery status
        defaultBuilder: (context, day, focusedDay) {
          // Convert the date to "yyyy-MM-dd" format for key matching
          String dayString = DateFormat('yyyy-MM-dd').format(day);

          // Check if there are any logs for this day
          if (_events.containsKey(dayString)) {
            // Get the logs for this day
            List<DailyDeliveryLog>? logsForDay = _events[dayString];

            // Separate checks for morning/evening delivered and skipped status
            bool isMorningDelivered = logsForDay!.any((log) =>
            log.morningDelivered == true);
            bool isEveningDelivered = logsForDay.any((log) =>
            log.eveningDelivered == true);
            bool isMorningSkipped = logsForDay.any((log) =>
            log.morningSkipped == true);
            bool isEveningSkipped = logsForDay.any((log) =>
            log.eveningSkipped == true);

            // // Debug print the individual variables
            // debugPrint("Morning Delivered: $isMorningDelivered");
            // debugPrint("Evening Delivered: $isEveningDelivered");
            // debugPrint("Morning Skipped: $isMorningSkipped");
            // debugPrint("Evening Skipped: $isEveningSkipped");

            if (day.isBefore(DateTime.now())) {
              // Define day color based on delivery status
              if (isMorningDelivered && isEveningDelivered) {
                // If morning or evening delivery was done
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400, // Delivered days
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                      '${day.day}', style: TextStyle(color: Colors.white))),
                );
              }
              else if (!isMorningDelivered && !isEveningDelivered) {
                // If morning or evening delivery was skipped
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade400, // Skipped days
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                      '${day.day}', style: TextStyle(color: Colors.white))),
                );
              }
              else if (isMorningDelivered && isEveningSkipped) {
                // If morning or evening delivery was skipped
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.green.shade400,
                        Colors.red.shade400,
                      ],
                    ),
                    color: Colors.red.shade400, // Skipped days
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                      '${day.day}', style: TextStyle(color: Colors.white))),
                );
              }
              else if (isMorningSkipped && isEveningDelivered) {
                // If morning or evening delivery was skipped
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.red.shade400,
                        Colors.green.shade400,
                      ],
                    ),
                    color: Colors.red.shade400, // Skipped days
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                      '${day.day}', style: TextStyle(color: Colors.white))),
                );
              }

            }
            // Default styling if no conditions are met
            return null;
          }
        },
      ),
    );
  }


  // Display data for the selected day
  Widget _buildSelectedDayData() {
    String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay);
    List<DailyDeliveryLog>? logsForDay = _events[selectedDateString];

    // Debug print to see the logs for the selected date
    // debugPrint("Logs for selected date: $selectedDateString");
    // debugPrint("Logs: ${logsForDay?.map((log) => log.date).join(", ")}");

    if (logsForDay == null || logsForDay.isEmpty) {
      return const Center(child: Text("No delivery data for this day"));
    }

    return ListView.builder(
      itemCount: logsForDay.length,
      itemBuilder: (context, index) {
        DailyDeliveryLog log = logsForDay[index];
        return ListTile(
          title: Text('Date: ${log.date}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Morning Delivered: ${log.morningDelivered}'),
              Text('Morning Skipped: ${log.morningSkipped}'),
              Text('Evening Delivered: ${log.eveningDelivered}'),
              Text('Evening Skipped: ${log.eveningSkipped}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title with modern styling
        title: Text(
          'Delivery Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Elegant letter spacing
          ),
        ),
        // Automatically adjusting the title position based on platform
        centerTitle: true,
        elevation: 4, // Adds subtle shadow for elevation
        backgroundColor: Color(0xFF202C59), // Deep blue color for modern look
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B4C7C), // Lighter blue
                Color(0xFF202C59), // Deep blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Customize the app bar height (optional)
        toolbarHeight: 70, // Slightly larger app bar for a premium look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isDataFetched
          ? Column(
        children: [
          _buildCalendar(),  // Show the calendar
          Expanded(
            child: _buildSelectedDayData(),  // Show data for the selected day
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()), // Loading indicator
    );
  }
}
