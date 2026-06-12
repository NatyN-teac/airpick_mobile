import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../offers/widgets/form_widgets.dart';
import '../cubit/offers_cubit.dart';
import '../models/offer_models.dart';
import '../models/offer_response.dart';
import '../repository/offer_repository.dart';

void openEditOffer(BuildContext context, OfferResponse offer) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => EditOfferScreen(offer: offer)),
  );
}

class EditOfferScreen extends StatefulWidget {
  final OfferResponse offer;
  const EditOfferScreen({super.key, required this.offer});

  @override
  State<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  late final TextEditingController _pickup =
      TextEditingController(text: widget.offer.pickupArea);
  late final TextEditingController _delivery =
      TextEditingController(text: widget.offer.deliveryArea);
  late final TextEditingController _discount = TextEditingController(
      text: (widget.offer.discount != null && widget.offer.discount! > 0)
          ? widget.offer.discount!.toStringAsFixed(2)
          : '');
  late final TextEditingController _note =
      TextEditingController(text: widget.offer.specialNote ?? '');
  final _meetupInput = TextEditingController();

  late Currency _currency = CurrencyX.fromApi(widget.offer.currency);
  late UrgencyLevel _urgency = UrgencyLevelX.fromApi(widget.offer.urgencyLevel);
  late final List<String> _meetups = [...widget.offer.meetupPlaces];
  late final Set<PaymentMethod> _payments = widget.offer.paymentMethods
      .map(PaymentMethodX.fromString)
      .whereType<PaymentMethod>()
      .toSet();

  bool _saving = false;

  bool get _valid =>
      _pickup.text.trim().isNotEmpty &&
      _delivery.text.trim().isNotEmpty &&
      _payments.isNotEmpty;

  @override
  void dispose() {
    _pickup.dispose();
    _delivery.dispose();
    _discount.dispose();
    _note.dispose();
    _meetupInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<OffersCubit>();
    try {
      final updated = await context.read<OfferRepository>().updateOffer(
            widget.offer.id,
            UpdateOfferRequest(
              currency: _currency,
              pickupArea: _pickup.text.trim(),
              deliveryArea: _delivery.text.trim(),
              urgencyLevel: _urgency,
              discount: double.tryParse(_discount.text.trim()),
              specialNote: _note.text.trim(),
              meetupPlaces: _meetups,
              paymentMethods: _payments.toList(),
            ),
          );
      cubit.update(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(
        content:
            Text('Offer updated', style: TextStyle(fontFamily: 'Manrope')),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Manrope')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

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
        title: Text('Edit Offer',
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
            18, 8, 18, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight is not editable — show it read-only for context.
            _RouteHint(offer: widget.offer, isDark: isDark),
            const SizedBox(height: 18),

            FormLabel('Pickup area', isDark: isDark),
            const SizedBox(height: 6),
            FormTextField(
                isDark: isDark,
                hint: 'e.g. Lagos, Nigeria',
                controller: _pickup,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            FormLabel('Delivery area', isDark: isDark),
            const SizedBox(height: 6),
            FormTextField(
                isDark: isDark,
                hint: 'e.g. Los Angeles, CA',
                controller: _delivery,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),

            FormLabel('Currency', isDark: isDark),
            const SizedBox(height: 6),
            _Dropdown<Currency>(
              isDark: isDark,
              value: _currency,
              options: Currency.values,
              label: (c) => c.label,
              onChanged: (c) => setState(() => _currency = c),
            ),
            const SizedBox(height: 12),
            FormLabel('Urgency', isDark: isDark),
            const SizedBox(height: 6),
            _Dropdown<UrgencyLevel>(
              isDark: isDark,
              value: _urgency,
              options: UrgencyLevel.values,
              label: (u) => u.label,
              onChanged: (u) => setState(() => _urgency = u),
            ),
            const SizedBox(height: 16),

            FormLabel('Payment methods', isDark: isDark),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PaymentMethod.values.map((m) {
                  final active = _payments.contains(m);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => active
                          ? _payments.remove(m)
                          : _payments.add(m)),
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
                        child: Text(m.label,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            FormLabel('Meetup places', isDark: isDark),
            const SizedBox(height: 8),
            if (_meetups.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _meetups.asMap().entries.map((e) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.value,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            )),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _meetups.removeAt(e.key)),
                          child: const Icon(Icons.close_rounded,
                              size: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (_meetups.isNotEmpty) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FormTextField(
                    isDark: isDark,
                    hint: 'Add a meetup place',
                    controller: _meetupInput,
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final v = _meetupInput.text.trim();
                    if (v.isEmpty) return;
                    setState(() {
                      _meetups.add(v);
                      _meetupInput.clear();
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FormLabel('Discount (optional)', isDark: isDark),
            const SizedBox(height: 6),
            FormTextField(
              isDark: isDark,
              hint: '0',
              controller: _discount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            FormLabel('Note (optional)', isDark: isDark),
            const SizedBox(height: 6),
            FormTextField(
              isDark: isDark,
              hint: 'e.g. Fragile items handled with care',
              controller: _note,
              maxLines: 2,
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _valid && !_saving ? _save : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: _valid ? AppColors.primaryGradient : null,
                    color: _valid
                        ? null
                        : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _saving
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Text('Save Changes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _valid
                                ? Colors.white
                                : AppColors.textDisabled,
                          )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteHint extends StatelessWidget {
  final OfferResponse offer;
  final bool isDark;
  const _RouteHint({required this.offer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.flight_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('${offer.fromCode ?? '—'} → ${offer.toCode ?? '—'}',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              )),
          const Spacer(),
          Text('Flight not editable',
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 10, color: textTertiary)),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final bool isDark;
  final T value;
  final List<T> options;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  const _Dropdown({
    required this.isDark,
    required this.value,
    required this.options,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      style: TextStyle(fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          size: 18, color: textSecondary),
      decoration: InputDecoration(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      items: options
          .map((o) => DropdownMenuItem<T>(value: o, child: Text(label(o))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
