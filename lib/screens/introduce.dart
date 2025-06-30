import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/models/onboarding.dart';
import 'package:to_do_list_app/services/onboarding.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class Introduce extends StatefulWidget {
  const Introduce({super.key});

  @override
  State<Introduce> createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  late Future<List<OnboardingData>> _futureData;
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureData = OnboardingAPI.fetchOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OnboardingData>>(
      future: _futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.defaultText,
          appBar: AppBar(
            backgroundColor: AppColors.defaultText,
            leading: Row(
              children: List.generate(data.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor:
                        _currentIndex == index
                            ? AppColors.primary
                            : AppColors.disabledPrimary,
                  ),
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Skip'),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _controller,
            itemCount: data.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nếu ảnh là URL:
                    Image.network(
                      'http://192.168.38.126:3000${item.imageUrl}',
                      width: 300,
                      height: 300,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    MyElevatedButton(
                      onPressed: () {
                        if (_currentIndex == data.length - 1) {
                          // Chuyển sang màn chính
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      textButton:
                          _currentIndex == data.length - 1
                              ? 'Get Started'
                              : 'Next',
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
