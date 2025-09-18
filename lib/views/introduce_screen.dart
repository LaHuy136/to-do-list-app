// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/viewmodels/onboading_viewmodel.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class Introduce extends StatefulWidget {
  const Introduce({super.key});

  @override
  State<Introduce> createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OnboardingViewModel>(
        context,
        listen: false,
      ).fetchOnboarding();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (vm.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Lỗi: ${vm.errorMessage}",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.disabledPrimary,
                ),
              ),
            ),
          );
        }

        final data = vm.onboardingList;
        if (data.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Không có dữ liệu onboarding",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.disabledPrimary,
                ),
              ),
            ),
          );
        }

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
