import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerSlider extends StatefulWidget {
  final List<dynamic> bannerImages;

  // Constructor to accept the list of banner images
  const BannerSlider({Key? key, required this.bannerImages}) : super(key: key);

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Auto-scroll functionality to move to the next banner
  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < widget.bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.bannerImages.isEmpty
        ? Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 200,
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      ),
    )
        : SizedBox(
      height: 220, // Increase height for better visual impact
      child: Stack(
        children: [
          // PageView for image sliding
          PageView.builder(
            controller: _pageController,
            itemCount: widget.bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15), // Rounded corners
                child: Image.network(
                  widget.bannerImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
          // Custom Page Indicator
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.bannerImages.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: _currentPage == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
