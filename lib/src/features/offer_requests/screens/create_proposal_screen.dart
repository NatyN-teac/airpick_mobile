import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../airports/models/airport.dart';
import '../../airports/repository/airport_repository.dart';
import '../../offers/models/offer_models.dart';
import '../../offers/widgets/form_widgets.dart';
import '../cubit/create_proposal_cubit.dart';
import '../cubit/create_proposal_state.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';

// Opens the proposal flow. A flight is created first, then the proposal.
// [onSent] fires after a successful submission (e.g. to drop the now-non-open
// request from the browse list).
void openCreateProposal(
  BuildContext context,
  OfferRequestResponse request, {
  VoidCallback? onSent,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (ctx) => CreateProposalCubit(
          airports: ctx.read<AirportRepository>(),
          offerRequests: ctx.read<OfferRequestRepository>(),
          request: request,
        )..loadAirports(),
        child: CreateProposalScreen(onSent: onSent),
      ),
    ),
  );
}

class CreateProposalScreen extends StatelessWidget {
  final VoidCallback? onSent;
  const CreateProposalScreen({super.key, this.onSent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return BlocConsumer<CreateProposalCubit, CreateProposalState>(
      listenWhen: (p, c) => c.created && !p.created,
      listener: (context, state) {
        onSent?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposal sent',
                style: TextStyle(fontFamily: 'Manrope')),
            backgroundColor: AppColors.success,
          ),
        );
      },
      builder: (context, state) {
        final cubit = context.read<CreateProposalCubit>();
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Send Proposal',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.3,
                )),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                18, 8, 18, MediaQuery.of(context).padding.bottom + 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Your flight ─────────────────────────────────────
                _SectionTitle('Your flight', isDark: isDark),
                const SizedBox(height: 8),
                if (state.airportsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                  )
                else ...[
                  // Constrain airports to the request's countries so the carrier
                  // can only pick a flight matching the requested route.
                  FormLabel('From  ·  ${cubit.request.sourceCountry}',
                      isDark: isDark),
                  const SizedBox(height: 6),
                  AirportPicker(
                    isDark: isDark,
                    airports: _airportsIn(
                        state.airports, cubit.request.sourceCountry),
                    selected: state.fromAirport,
                    hint: 'Airport in ${cubit.request.sourceCountry}',
                    onSelected: cubit.setFromAirport,
                  ),
                  const SizedBox(height: 10),
                  FormLabel('To  ·  ${cubit.request.destinationCountry}',
                      isDark: isDark),
                  const SizedBox(height: 6),
                  AirportPicker(
                    isDark: isDark,
                    airports: _airportsIn(
                        state.airports, cubit.request.destinationCountry),
                    selected: state.toAirport,
                    hint: 'Airport in ${cubit.request.destinationCountry}',
                    onSelected: cubit.setToAirport,
                  ),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: 'Departure date',
                      value: state.departureDate,
                      onTap: () async {
                        final d = await _pickDate(context, state.departureDate);
                        if (d != null) cubit.setDepartureDate(d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: 'Departure time',
                      isTime: true,
                      timeValue: state.departureTime,
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context,
                            initialTime:
                                state.departureTime ?? TimeOfDay.now());
                        if (t != null) cubit.setDepartureTime(t);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: 'Arrival date',
                      value: state.arrivalDate,
                      onTap: () async {
                        final d = await _pickDate(context, state.arrivalDate,
                            first: state.departureDate);
                        if (d != null) cubit.setArrivalDate(d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DateTimeTile(
                      isDark: isDark,
                      label: 'Arrival time',
                      isTime: true,
                      timeValue: state.arrivalTime,
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context,
                            initialTime: state.arrivalTime ?? TimeOfDay.now());
                        if (t != null) cubit.setArrivalTime(t);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Pickup / delivery ───────────────────────────────
                _SectionTitle('Pickup & delivery', isDark: isDark),
                const SizedBox(height: 8),
                FormLabel('Pickup area', isDark: isDark),
                const SizedBox(height: 6),
                FormTextField(
                  isDark: isDark,
                  hint: 'e.g. Lagos, Nigeria',
                  onChanged: cubit.setPickupArea,
                ),
                const SizedBox(height: 10),
                FormLabel('Delivery area', isDark: isDark),
                const SizedBox(height: 6),
                FormTextField(
                  isDark: isDark,
                  hint: 'e.g. Los Angeles, CA',
                  onChanged: cubit.setDeliveryArea,
                ),
                const SizedBox(height: 20),

                // ── Payment methods ─────────────────────────────────
                _SectionTitle('Payment methods', isDark: isDark),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PaymentMethod.values.map((m) {
                      final active = state.paymentMethods.contains(m);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => cubit.togglePaymentMethod(m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : (isDark
                                      ? AppColors.darkSurface
                                      : AppColors.surface),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border),
                              ),
                            ),
                            child: Text(
                              m.label,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Items + prices ──────────────────────────────────
                Row(
                  children: [
                    _SectionTitle('Price the items', isDark: isDark),
                    const Spacer(),
                    if (state.partialAllowed)
                      const Text('Partial allowed',
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: AppColors.info)),
                  ],
                ),
                const SizedBox(height: 8),
                // Scrollable when there are many items so the form stays compact
                if (state.items.length <= 3)
                  ...state.items.map((d) => _ItemPriceRow(
                        draft: d,
                        isDark: isDark,
                        canDeselect: state.partialAllowed,
                        onToggle: () => cubit.toggleItem(d.item.id),
                        onPrice: (v) => cubit.setItemPrice(d.item.id, v),
                      ))
                else
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.items.length,
                      itemBuilder: (_, i) {
                        final d = state.items[i];
                        return _ItemPriceRow(
                          draft: d,
                          isDark: isDark,
                          canDeselect: state.partialAllowed,
                          onToggle: () => cubit.toggleItem(d.item.id),
                          onPrice: (v) => cubit.setItemPrice(d.item.id, v),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),

                // ── Note ────────────────────────────────────────────
                FormLabel('Note (optional)', isDark: isDark),
                const SizedBox(height: 6),
                FormTextField(
                  isDark: isDark,
                  hint: 'e.g. I can deliver within 2 days of arrival',
                  maxLines: 2,
                  onChanged: cubit.setNote,
                ),
                const SizedBox(height: 24),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(state.error!,
                        style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.error)),
                  ),

                // ── Submit ──────────────────────────────────────────
                Row(
                  children: [
                    Text('Total  \$${state.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        )),
                    if (state.isPartial) ...[
                      const SizedBox(width: 8),
                      const Text('· Partial',
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: AppColors.info)),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: state.isValid && !state.submitting
                          ? () => cubit.submit()
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: state.isValid
                              ? AppColors.primaryGradient
                              : null,
                          color: state.isValid
                              ? null
                              : (isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: state.submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Submit',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: state.isValid
                                      ? Colors.white
                                      : AppColors.textDisabled,
                                )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Airports whose country matches the request's country (case-insensitive).
  List<Airport> _airportsIn(List<Airport> all, String country) {
    final c = country.trim().toLowerCase();
    return all.where((a) => a.country.trim().toLowerCase() == c).toList();
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial,
      {DateTime? first}) {
    final firstDate = first ?? DateTime.now();
    final init = (initial != null && !initial.isBefore(firstDate))
        ? initial
        : firstDate;
    return showDatePicker(
      context: context,
      initialDate: init,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      );
}

class _ItemPriceRow extends StatelessWidget {
  final ProposalItemDraft draft;
  final bool isDark;
  final bool canDeselect;
  final VoidCallback onToggle;
  final ValueChanged<double> onPrice;

  const _ItemPriceRow({
    required this.draft,
    required this.isDark,
    required this.canDeselect,
    required this.onToggle,
    required this.onPrice,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: draft.selected ? AppColors.primary : border,
          width: draft.selected ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: canDeselect ? onToggle : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: draft.selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: draft.selected ? AppColors.primary : border),
              ),
              child: draft.selected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.item.name,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    )),
                Text('× ${draft.item.quantity}',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        color: textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: TextField(
              enabled: draft.selected,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => onPrice(double.tryParse(v) ?? 0),
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                    fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
                hintText: 'Price',
                hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
