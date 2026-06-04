import 'package:flutter/material.dart';
import '../models/onboarding_page_model.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPageView extends StatelessWidget {
  final List<OnboardingPageModel> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const OnboardingPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      onPageChanged: onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final page = pages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.38,
                child: Image.asset(page.image, fit: BoxFit.contain),
              ),
              const SizedBox(height: 24),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
