// home_page.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_logic.dart';
import '../widgets/banner_slider.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageLogic _homePageLogic = HomePageLogic();  // Create an instance of the logic class

  String _planName = 'Loading...';
  int _remainingLiters = 0;
  List<dynamic> _bannerImages = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    // Fetch the data from the logic class
    await _homePageLogic.fetchData((planName, remainingLiters, bannerImages) {
      setState(() {
        _planName = planName;
        _remainingLiters = remainingLiters;
        _bannerImages = bannerImages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildShimmerCard(),
          // Use the BannerSlider component and pass the list of images
          BannerSlider(bannerImages: _bannerImages),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return _planName == 'Loading...'
        ? Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        color: Colors.orange.shade100,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loading...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
              SizedBox(height: 10),
              Text('Remaining Liters: 0', style: TextStyle(fontSize: 18, color: Colors.brown.shade600)),
            ],
          ),
        ),
      ),
    )
        : Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_planName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
            SizedBox(height: 10),
            Text('Remaining Liters: $_remainingLiters', style: TextStyle(fontSize: 18, color: Colors.brown.shade600)),
          ],
        ),
      ),
    );
  }
}
