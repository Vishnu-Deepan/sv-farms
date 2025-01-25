import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/nav_and_app_bar.dart';
import 'app_theme.dart';
import 'services/shared_preferences_helper.dart';
import 'views/login_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool isLoggedIn = await SharedPreferencesHelper.isLoggedIn();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.black, // Transparent status bar for sleek look
    statusBarIconBrightness: Brightness.light, // White icons in the status bar
  ));
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? BottomNavBar() : LoginPage(),
    );
  }
}



