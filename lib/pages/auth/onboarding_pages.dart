import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Welcome to the Ultimate Shopping Experience",
      "description":
          "Explore a world of endless possibilities with our user-friendly platform, offering convenience, variety, and quality at your fingertips."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Discover Categories Tailored for You",
      "description":
          "Browse through an extensive collection of curated categories designed to match your interests, making shopping easier and more enjoyable.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Exclusive Offers Just for You",
      "description":
          "Unlock special discounts and limited-time deals curated to bring you the best value on your favorite items.",
    },
    {
      "image": "assets/images/onboarding4.png",
      "title": "Fast, Secure, and Easy Checkout",
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
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          data["image"]!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 24),
                        Text(
                          data["title"]!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          data["description"]!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.black : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
                    child: Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        // Navigate to the next page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => YourNextPage()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Next"),
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

class YourNextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Welcome to the App!"),
      ),
    );
  }
}
