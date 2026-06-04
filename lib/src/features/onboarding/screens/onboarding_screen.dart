import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/bloc/app_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../models/onboarding_page_model.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      image: 'assets/onboarding/community.png',
      title: 'A trusted community',
      subtitle: 'Join a verified network of travelers and senders with confidence.',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding/second.png',
      title: 'Fast & reliable delivery',
      subtitle: 'Match with travelers headed your way and get items delivered on time.',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding/trust3.png',
      title: 'Simple & secure',
      subtitle: 'Track progress, and complete delivery with peace of mind.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(const OnboardingStarted());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(int currentPage) {
    if (currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.read<OnboardingBloc>().add(const OnboardingCompleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingDone) {
          context.read<AppBloc>().add(const AppOnboardingCompleted());
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          final currentPage =
              state is OnboardingInProgress ? state.currentPage : 0;
          final totalPages =
              state is OnboardingInProgress ? state.totalPages : _pages.length;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => context
                              .read<OnboardingBloc>()
                              .add(const OnboardingCompleted()),
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: OnboardingPageView(
                      pages: _pages,
                      controller: _pageController,
                      onPageChanged: (page) => context
                          .read<OnboardingBloc>()
                          .add(OnboardingPageChanged(page)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Row(
                      children: [
                        OnboardingIndicator(
                          totalPages: totalPages,
                          currentPage: currentPage,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _next(currentPage),
                          child: Text(
                            currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
