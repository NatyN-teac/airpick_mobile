import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/bloc/app_bloc.dart';
import '../../../core/l10n/l10n.dart';
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

  static const _pageImages = [
    'assets/onboarding/community.png',
    'assets/onboarding/second.png',
    'assets/onboarding/trust3.png',
  ];

  static const int _pageCount = 3;

  // Built at render time so the copy follows the active locale.
  List<OnboardingPageModel> _pagesFor(BuildContext context) {
    final l = l10n(context);
    return [
      OnboardingPageModel(
        image: _pageImages[0],
        title: l.onboardingTitle1,
        subtitle: l.onboardingSubtitle1,
      ),
      OnboardingPageModel(
        image: _pageImages[1],
        title: l.onboardingTitle2,
        subtitle: l.onboardingSubtitle2,
      ),
      OnboardingPageModel(
        image: _pageImages[2],
        title: l.onboardingTitle3,
        subtitle: l.onboardingSubtitle3,
      ),
    ];
  }

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
    if (currentPage < _pageCount - 1) {
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
          final l = l10n(context);
          final pages = _pagesFor(context);
          final currentPage =
              state is OnboardingInProgress ? state.currentPage : 0;
          final totalPages =
              state is OnboardingInProgress ? state.totalPages : _pageCount;

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
                          child: Text(l.skip),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: OnboardingPageView(
                      pages: pages,
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
                            currentPage == _pageCount - 1
                                ? l.getStarted
                                : l.next,
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
