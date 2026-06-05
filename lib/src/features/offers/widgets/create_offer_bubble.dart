import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../airports/repository/airport_repository.dart';
import '../../flights/repository/flight_repository.dart';
import '../../items/repository/item_repository.dart';
import '../cubit/create_offer_cubit.dart';
import '../cubit/create_offer_state.dart';
import '../repository/offer_repository.dart';
import 'airpick_bubble_shell.dart';
import 'flight_form_step.dart';
import 'offer_form_step.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> showCreateOfferBubble(
  BuildContext context, {
  required GlobalKey plusKey,
  required AirportRepository airports,
  required FlightRepository flights,
  required OfferRepository offers,
  required ItemRepository items,
}) async {
  await showAirpickBubble(
    context,
    plusKey: plusKey,
    contentBuilder: (dismiss) => BlocProvider(
      create: (_) => CreateOfferCubit(
        airports: airports,
        flights: flights,
        offers: offers,
        items: items,
      )
        ..loadAirports()
        ..loadItems(),
      child: _BubbleContent(onDismiss: dismiss),
    ),
  );
}

// ── Content ───────────────────────────────────────────────────────────────────

class _BubbleContent extends StatelessWidget {
  final VoidCallback onDismiss;
  const _BubbleContent({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocBuilder<CreateOfferCubit, CreateOfferState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: state.offerCreated
              ? BubbleSuccessScreen(
                  key: const ValueKey('success'),
                  isDark: isDark,
                  onDismiss: onDismiss,
                  title: 'Offer Created!',
                  subtitle: 'Your offer is live and visible to senders.',
                )
              : Column(
                  key: const ValueKey('form'),
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFF1F5F9),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.createOffer,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.step == CreateOfferStep.flight
                                      ? '${l.step1of2}  ·  ${l.stepFlightDetails}'
                                      : '${l.step2of2}  ·  ${l.stepOfferDetails}',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _StepDot(
                                  active:
                                      state.step == CreateOfferStep.flight),
                              const SizedBox(width: 4),
                              _StepDot(
                                  active:
                                      state.step == CreateOfferStep.offer),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.step == CreateOfferStep.flight
                          ? FlightFormStep(isDark: isDark)
                          : OfferFormStep(isDark: isDark),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 16 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.textDisabled,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}
