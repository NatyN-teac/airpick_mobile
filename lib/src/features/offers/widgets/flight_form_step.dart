import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../flights/models/flight_models.dart';
import '../cubit/create_offer_cubit.dart';
import '../cubit/create_offer_state.dart';
import 'form_widgets.dart';

class FlightFormStep extends StatelessWidget {
  final bool isDark;
  const FlightFormStep({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return BlocBuilder<CreateOfferCubit, CreateOfferState>(
      builder: (context, state) {
        final cubit = context.read<CreateOfferCubit>();

        return SingleChildScrollView(
          // Extra bottom padding when keyboard is open so all fields stay reachable
          padding: EdgeInsets.fromLTRB(18, 16, 18, 18 + keyboardH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Flight type toggle ─────────────────────────────────
              _SegmentedToggle(
                isDark: isDark,
                value: state.flightType,
                onChanged: cubit.setFlightType,
                leftLabel: l.oneWay,
                rightLabel: l.roundTrip,
              ),
              const SizedBox(height: 16),

              // ── From / To airports ─────────────────────────────────
              if (state.airportsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              else if (state.airportsError != null)
                _AirportError(
                  isDark: isDark,
                  message: l.errorLoadingAirports,
                  onRetry: () => cubit.loadAirports(),
                )
              else ...[
                FormLabel(l.fromAirport, isDark: isDark),
                const SizedBox(height: 6),
                AirportPicker(
                  isDark: isDark,
                  airports: state.airports,
                  selected: state.fromAirport,
                  hint: l.searchAirport,
                  onSelected: cubit.setFromAirport,
                ),
                const SizedBox(height: 12),
                FormLabel(l.toAirport, isDark: isDark),
                const SizedBox(height: 6),
                AirportPicker(
                  isDark: isDark,
                  airports: state.airports,
                  selected: state.toAirport,
                  hint: l.searchAirport,
                  onSelected: cubit.setToAirport,
                ),
              ],
              const SizedBox(height: 16),

              // ── Outbound departure ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: l.departureDate,
                      value: state.departureDate,
                      onTap: () async {
                        final d = await _pickDate(
                          context,
                          initial: state.departureDate,
                          firstDate: DateTime.now(),
                        );
                        if (d != null) cubit.setDepartureDate(d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: l.departureTime,
                      isTime: true,
                      timeValue: state.departureTime,
                      onTap: () async {
                        final t = await _pickTime(context, state.departureTime);
                        if (t != null) cubit.setDepartureTime(t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Outbound arrival ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: l.arrivalDate,
                      value: state.arrivalDate,
                      onTap: () async {
                        // Cannot arrive before departure date
                        final d = await _pickDate(
                          context,
                          initial: state.arrivalDate,
                          firstDate: state.departureDate ?? DateTime.now(),
                        );
                        if (d != null) cubit.setArrivalDate(d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: l.arrivalTime,
                      isTime: true,
                      timeValue: state.arrivalTime,
                      onTap: () async {
                        final t = await _pickArrivalTime(
                          context,
                          current: state.arrivalTime,
                          departureDate: state.departureDate,
                          arrivalDate: state.arrivalDate,
                          departureTime: state.departureTime,
                        );
                        if (t != null) cubit.setArrivalTime(t);
                      },
                    ),
                  ),
                ],
              ),

              // ── Return leg (round trip) ────────────────────────────
              if (state.flightType == FlightType.roundTrip) ...[
                const SizedBox(height: 16),
                FormLabel(l.returnLeg, isDark: isDark),
                const SizedBox(height: 10),

                FormLabel(l.fromAirport, isDark: isDark),
                const SizedBox(height: 6),
                AirportPicker(
                  isDark: isDark,
                  airports: state.airports,
                  selected: state.returnFromAirport,
                  hint: l.searchAirport,
                  onSelected: cubit.setReturnFromAirport,
                ),
                const SizedBox(height: 12),
                FormLabel(l.toAirport, isDark: isDark),
                const SizedBox(height: 6),
                AirportPicker(
                  isDark: isDark,
                  airports: state.airports,
                  selected: state.returnToAirport,
                  hint: l.searchAirport,
                  onSelected: cubit.setReturnToAirport,
                ),
                const SizedBox(height: 12),

                // Return departure — cannot be before outbound arrival
                Row(
                  children: [
                    Expanded(
                      child: DateTimeTile(
                        isDark: isDark,
                        label: l.departureDate,
                        value: state.returnDepartureDate,
                        onTap: () async {
                          final d = await _pickDate(
                            context,
                            initial: state.returnDepartureDate,
                            firstDate: state.arrivalDate ?? state.departureDate ?? DateTime.now(),
                          );
                          if (d != null) cubit.setReturnDepartureDate(d);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DateTimeTile(
                        isDark: isDark,
                        label: l.departureTime,
                        isTime: true,
                        timeValue: state.returnDepartureTime,
                        onTap: () async {
                          final t = await _pickArrivalTime(
                            context,
                            current: state.returnDepartureTime,
                            departureDate: state.arrivalDate,
                            arrivalDate: state.returnDepartureDate,
                            departureTime: state.arrivalTime,
                          );
                          if (t != null) cubit.setReturnDepartureTime(t);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Return arrival — cannot be before return departure
                Row(
                  children: [
                    Expanded(
                      child: DateTimeTile(
                        isDark: isDark,
                        label: l.arrivalDate,
                        value: state.returnArrivalDate,
                        onTap: () async {
                          final d = await _pickDate(
                            context,
                            initial: state.returnArrivalDate,
                            firstDate: state.returnDepartureDate ?? state.arrivalDate ?? DateTime.now(),
                          );
                          if (d != null) cubit.setReturnArrivalDate(d);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DateTimeTile(
                        isDark: isDark,
                        label: l.arrivalTime,
                        isTime: true,
                        timeValue: state.returnArrivalTime,
                        onTap: () async {
                          final t = await _pickArrivalTime(
                            context,
                            current: state.returnArrivalTime,
                            departureDate: state.returnDepartureDate,
                            arrivalDate: state.returnArrivalDate,
                            departureTime: state.returnDepartureTime,
                          );
                          if (t != null) cubit.setReturnArrivalTime(t);
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // ── Continue button ────────────────────────────────────
              if (state.flightError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    state.flightError!,
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: AppColors.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: state.flightFormValid && !state.creatingFlight
                      ? () => cubit.createFlight()
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: state.flightFormValid
                          ? AppColors.primaryGradient
                          : null,
                      color: state.flightFormValid
                          ? null
                          : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: state.creatingFlight
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : Text(
                            l.continueToOffer,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: state.flightFormValid
                                  ? Colors.white
                                  : AppColors.textDisabled,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Date picker with enforced firstDate ─────────────────────────────────────

  Future<DateTime?> _pickDate(
    BuildContext context, {
    DateTime? initial,
    required DateTime firstDate,
  }) {
    final safeInitial = initial != null && !initial.isBefore(firstDate)
        ? initial
        : firstDate;
    return showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  // ── Arrival time picker — enforces at least 1 hr gap on same-day flights ────

  Future<TimeOfDay?> _pickArrivalTime(
    BuildContext context, {
    required TimeOfDay? current,
    required DateTime? departureDate,
    required DateTime? arrivalDate,
    required TimeOfDay? departureTime,
  }) async {
    final bool sameDay = departureDate != null &&
        arrivalDate != null &&
        _isSameDay(departureDate, arrivalDate);

    // Suggest a sensible initial time: dep + 1hr if same day
    TimeOfDay initial = current ?? TimeOfDay.now();
    if (sameDay && departureTime != null && current == null) {
      final depMins = departureTime.hour * 60 + departureTime.minute + 60;
      initial = TimeOfDay(hour: (depMins ~/ 60) % 24, minute: depMins % 60);
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return null;

    // Validate: same day → must be ≥ 1 hr after departure
    if (sameDay && departureTime != null) {
      final depMins = departureTime.hour * 60 + departureTime.minute;
      final arrMins = picked.hour * 60 + picked.minute;
      if (arrMins < depMins + 60) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Arrival must be at least 1 hour after departure on the same day.',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }
    }

    return picked;
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay? initial) =>
      showTimePicker(
        context: context,
        initialTime: initial ?? TimeOfDay.now(),
      );

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Segmented toggle ──────────────────────────────────────────────────────────

class _SegmentedToggle extends StatelessWidget {
  final bool isDark;
  final FlightType value;
  final ValueChanged<FlightType> onChanged;
  final String leftLabel, rightLabel;

  const _SegmentedToggle({
    required this.isDark,
    required this.value,
    required this.onChanged,
    required this.leftLabel,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.surface;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _Segment(
            label: leftLabel,
            active: value == FlightType.oneWay,
            isDark: isDark,
            onTap: () => onChanged(FlightType.oneWay),
          ),
          _Segment(
            label: rightLabel,
            active: value == FlightType.roundTrip,
            isDark: isDark,
            onTap: () => onChanged(FlightType.roundTrip),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active, isDark;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AirportError extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  const _AirportError({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(message,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: AppColors.error)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              l10n(context).retry,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
