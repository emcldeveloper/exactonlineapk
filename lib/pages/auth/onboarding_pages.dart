import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/users_controllers.dart';
import 'package:e_online/pages/way_page.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Welcome to the Ultimate\nShopping Experience",
      "description":
          "Explore a world of endless possibilities with our user-friendly platform, offering convenience, variety, and quality at your fingertips."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Discover Categories\nTailored for You",
      "description":
          "Browse through an extensive collection of curated categories designed to match your interests, making shopping easier and more enjoyable.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Exclusive Offers Just\nfor You",
      "description":
          "Unlock special discounts and limited-time deals curated to bring you the best value on your favorite items.",
    },
    {
      "image": "assets/images/onboarding4.png",
      "title": "Fast, Secure, and Easy\nCheckout",
      "description":
          "Enjoy a hassle-free checkout process with multiple payment options, advanced security measures, and lightning-fast order confirmation.",
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingData.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          data["image"]!,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        spacer2(),
                        HeadingText(
                          data["title"]!,
                          fontSize: 23.0,
                          textAlign: TextAlign.center,
                        ),
                        spacer1(),
                        ParagraphText(
                          data["description"]!,
                          color: mutedTextColor,
                          textAlign: TextAlign.center,
                        ),
                        spacer2(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _onboardingData.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              width: _currentPage == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.black
                                    : const Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Skip to last screen
                      _controller.jumpToPage(_onboardingData.length - 1);
                    },
                    child: ParagraphText(
                      "Skip",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        // Navigate to the next page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const WayPage()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: ParagraphText(
                      "Next",
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
