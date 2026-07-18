import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/create_offer_cubit.dart';
import '../cubit/create_offer_state.dart';
import '../models/offer_models.dart';
import '../../items/models/item_models.dart';
import 'form_widgets.dart';
import 'item_picker_dialog.dart';

class OfferFormStep extends StatelessWidget {
  final bool isDark;
  const OfferFormStep({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);

    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return BlocBuilder<CreateOfferCubit, CreateOfferState>(
      builder: (context, state) {
        final cubit = context.read<CreateOfferCubit>();

        return SingleChildScrollView(
          // Drag anywhere on the form to dismiss the keyboard, and keep the
          // last fields reachable above it while it's open.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(18, 16, 18, 18 + keyboardH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pickup / Delivery areas ────────────────────────────
              FormLabel(l.pickupArea, isDark: isDark),
              const SizedBox(height: 6),
              FormTextField(
                isDark: isDark,
                hint: 'e.g. New York, NY',
                onChanged: cubit.setPickupArea,
              ),
              const SizedBox(height: 12),
              FormLabel(l.deliveryArea, isDark: isDark),
              const SizedBox(height: 6),
              FormTextField(
                isDark: isDark,
                hint: 'e.g. Los Angeles, CA',
                onChanged: cubit.setDeliveryArea,
              ),
              const SizedBox(height: 16),

              // ── Urgency ────────────────────────────────────────────
              // FormLabel(l.urgencyLevel, isDark: isDark),
              // const SizedBox(height: 6),
              // _FormDropdown<UrgencyLevel>(
              //   isDark: isDark,
              //   value: state.urgencyLevel,
              //   options: UrgencyLevel.values,
              //   label: (u) => u.label,
              //   onChanged: cubit.setUrgencyLevel,
              // ),
              // const SizedBox(height: 16),

              // ── Payment methods (horizontal scroll, multi-select) ──
              FormLabel(l.paymentMethods, isDark: isDark),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : (isDark
                                    ? AppColors.darkBackground
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (active) ...[
                                const Icon(Icons.check_rounded,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                              ],
                              Text(
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
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Meetup places ──────────────────────────────────────
              FormLabel(l.meetupPlaces, isDark: isDark),
              const SizedBox(height: 8),
              _MeetupSection(isDark: isDark, cubit: cubit, state: state),
              const SizedBox(height: 16),

              // ── Currency ───────────────────────────────────────────
              FormLabel('Accepted Currency', isDark: isDark),
              const SizedBox(height: 6),
              _FormDropdown<Currency>(
                isDark: isDark,
                value: state.currency,
                options: Currency.values,
                label: (c) => c.label,
                onChanged: cubit.setCurrency,
              ),
              const SizedBox(height: 16),

              // ── Items ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: FormLabel(l.offerItems, isDark: isDark)),
                  GestureDetector(
                    onTap: () async {
                      final selected = await showItemPickerDialog(
                        context,
                        availableItems: state.availableItems,
                        isLoading: state.itemsLoading,
                        itemsError: state.itemsError,
                        onRetry: cubit.loadItems,
                        onCreate: cubit.createAndSelectItem,
                      );
                      if (selected.isNotEmpty) cubit.addItems(selected);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          l.addItem,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No items added yet — tap Add Item',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                )
              else ...[
                // Total price strip
                _TotalPriceBar(state: state, isDark: isDark),
                const SizedBox(height: 8),
                // List — 2 cards visible, rest scrollable
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemRow(
                          key: ValueKey(state.items[i].id),
                          item: state.items[i],
                          isDark: isDark,
                          cubit: cubit),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Discount (optional) ────────────────────────────────
              FormLabel('${l.discount}  (${l.optional})', isDark: isDark),
              const SizedBox(height: 6),
              FormTextField(
                isDark: isDark,
                hint: '0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => cubit.setDiscount(double.tryParse(v)),
              ),
              const SizedBox(height: 12),

              // ── Special note (optional) ────────────────────────────
              FormLabel('${l.specialNote}  (${l.optional})', isDark: isDark),
              const SizedBox(height: 6),
              FormTextField(
                isDark: isDark,
                hint: 'e.g. Fragile items handled with care',
                maxLines: 2,
                onChanged: cubit.setSpecialNote,
              ),
              const SizedBox(height: 20),

              // ── Create offer button ────────────────────────────────
              if (state.offerError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    state.offerError!,
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: AppColors.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: state.offerFormValid && !state.creatingOffer
                      ? () => cubit.createOffer()
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: state.offerFormValid
                          ? AppColors.primaryGradient
                          : null,
                      color: state.offerFormValid
                          ? null
                          : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: state.creatingOffer
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : Text(
                            l.createOfferButton,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: state.offerFormValid
                                  ? Colors.white
                                  : AppColors.textDisabled,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

// ── Total price bar ───────────────────────────────────────────────────────────

class _TotalPriceBar extends StatelessWidget {
  final CreateOfferState state;
  final bool isDark;
  const _TotalPriceBar({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final allComplete = state.items.every((d) => d.quantity > 0 && d.pricePerItem > 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${state.items.length} item${state.items.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: AppColors.primary,
              ),
            ),
          ),
          if (allComplete)
            Text(
              'Total  ${state.currency.symbol}${state.totalPrice.toStringAsFixed(2)} ${state.currency.apiValue}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
          else
            const Text(
              'Add price & qty to each item',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Generic form dropdown — matches FormTextField sizing exactly ───────────────

class _FormDropdown<T> extends StatelessWidget {
  final bool isDark;
  final T value;
  final List<T> options;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  const _FormDropdown({
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
      style: TextStyle(
          fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
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
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: options
          .map((o) => DropdownMenuItem<T>(
                value: o,
                child: Text(label(o),
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: textPrimary)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ── Meetup places ─────────────────────────────────────────────────────────────

class _MeetupSection extends StatelessWidget {
  final bool isDark;
  final CreateOfferCubit cubit;
  final CreateOfferState state;

  const _MeetupSection({
    required this.isDark,
    required this.cubit,
    required this.state,
  });

  Future<void> _addPlace(BuildContext context) async {
    final choice = await showDialog<MeetupPlace>(
      context: context,
      builder: (_) => _MeetupPickerDialog(isDark: isDark),
    );
    if (choice == null || !context.mounted) return;

    if (choice == MeetupPlace.other) {
      final custom = await showDialog<String>(
        context: context,
        builder: (_) => _CustomMeetupDialog(isDark: isDark),
      );
      if (custom != null && custom.trim().isNotEmpty && context.mounted) {
        cubit.addMeetupPlace(custom.trim());
      }
    } else {
      cubit.addMeetupPlace(choice.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected places chips
        if (state.meetupPlaces.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: state.meetupPlaces.asMap().entries.map((e) {
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
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => cubit.removeMeetupPlace(e.key),
                      child: const Icon(Icons.close_rounded,
                          size: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (state.meetupPlaces.isNotEmpty) const SizedBox(height: 8),
        // Add meetup place button
        GestureDetector(
          onTap: () => _addPlace(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_location_alt_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Add meetup place',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetupPickerDialog extends StatelessWidget {
  final bool isDark;
  const _MeetupPickerDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                'Select meetup place',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            ...MeetupPlace.values.map((p) => InkWell(
                  onTap: () => Navigator.of(context).pop(p),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: border, width: 0.5)),
                    ),
                    child: Text(
                      p.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: p == MeetupPlace.other
                            ? AppColors.primary
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CustomMeetupDialog extends StatefulWidget {
  final bool isDark;
  const _CustomMeetupDialog({required this.isDark});

  @override
  State<_CustomMeetupDialog> createState() => _CustomMeetupDialogState();
}

class _CustomMeetupDialogState extends State<_CustomMeetupDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surface =
        widget.isDark ? AppColors.darkBackground : AppColors.surface;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.border;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom meetup place',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Starbucks on 5th Ave',
                hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: widget.isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Cancel',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: AppColors.textDisabled,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(_ctrl.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Add',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item row ──────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final OfferItemDraft item;
  final bool isDark;
  final CreateOfferCubit cubit;

  const _ItemRow({
    super.key,
    required this.item,
    required this.isDark,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final isComplete = item.quantity > 0 && item.pricePerItem > 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isComplete ? border : AppColors.error.withValues(alpha: 0.5),
          width: isComplete ? 1.0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.item.name,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Text(
                item.item.measurementUnit.label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => cubit.removeItem(item.id),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Quantity
              Expanded(
                child: _MiniField(
                  isDark: isDark,
                  hint: 'Qty',
                  initialValue: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      cubit.updateItem(item.id, quantity: int.tryParse(v) ?? 1),
                ),
              ),
              const SizedBox(width: 8),
              // Price
              Expanded(
                flex: 2,
                child: _MiniField(
                  isDark: isDark,
                  hint: 'Price per item',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => cubit.updateItem(item.id,
                      pricePerItem: double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final bool isDark;
  final String hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _MiniField({
    required this.isDark,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(
          fontFamily: 'Manrope', fontSize: 12, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color:
                isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
    );
  }
}
