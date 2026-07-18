import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_validation.dart';
import '../../countries/repository/country_repository.dart';
import '../../countries/widgets/country_picker_field.dart';
import '../../items/models/item_models.dart';
import '../../items/repository/item_repository.dart';
import '../../offers/models/offer_models.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
import '../../offers/widgets/item_picker_dialog.dart';
import '../cubit/create_offer_request_cubit.dart';
import '../cubit/create_offer_request_state.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> showCreateOfferRequestBubble(
  BuildContext context, {
  required ItemRepository items,
  required OfferRequestRepository offerRequests,
  required CountryRepository countries,
  required ValueChanged<OfferRequestResponse> onSaved,
  OfferRequestResponse? existing,
}) async {
  await showAirpickSheet(
    context,
    contentBuilder: (dismiss) => BlocProvider(
      create: (_) => CreateOfferRequestCubit(
        items: items,
        offerRequests: offerRequests,
        countries: countries,
      )..init(existing: existing),
      child: _OfferRequestContent(
        onDismiss: dismiss,
        onSaved: onSaved,
      ),
    ),
  );
}

// ── Content ───────────────────────────────────────────────────────────────────

class _OfferRequestContent extends StatelessWidget {
  final VoidCallback onDismiss;
  final ValueChanged<OfferRequestResponse> onSaved;

  const _OfferRequestContent({
    required this.onDismiss,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocListener<CreateOfferRequestCubit, CreateOfferRequestState>(
      listenWhen: (prev, curr) => curr.created && !prev.created,
      listener: (context, state) {
        if (state.result != null) onSaved(state.result!);
      },
      child: BlocBuilder<CreateOfferRequestCubit, CreateOfferRequestState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: state.created
                ? BubbleSuccessScreen(
                    key: const ValueKey('success'),
                    isDark: isDark,
                    onDismiss: onDismiss,
                    title: state.isEditing ? 'Request Updated!' : 'Request Sent!',
                    subtitle: state.isEditing
                        ? 'Your changes have been saved.'
                        : 'Carriers near your route will see your request.',
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
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.inventory_2_rounded,
                                  size: 16, color: AppColors.info),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.isEditing
                                      ? 'Edit Request'
                                      : 'Offer Request',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  state.isEditing
                                      ? 'Update your delivery request'
                                      : 'Tell carriers what you need delivered',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _OfferRequestForm(isDark: isDark),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _OfferRequestForm extends StatelessWidget {
  final bool isDark;
  const _OfferRequestForm({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferRequestCubit, CreateOfferRequestState>(
      builder: (context, state) {
        final cubit = context.read<CreateOfferRequestCubit>();

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
              18, 14, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Source ────────────────────────────────────────────
              _Label('From', isDark: isDark),
              const SizedBox(height: 6),
              CountryPickerField(
                isDark: isDark,
                countries: state.availableCountries,
                selected: state.sourceCountry,
                loading: state.countriesLoading,
                locked: state.isEditing,
                hint: 'Search country',
                onSelected: cubit.setSourceCountry,
              ),
              const SizedBox(height: 8),
              _Field(
                isDark: isDark,
                hint: 'City',
                initialValue: state.isEditing ? state.sourceCity : null,
                onChanged: cubit.setSourceCity,
              ),
              const SizedBox(height: 12),

              // ── Destination ───────────────────────────────────────
              _Label('To', isDark: isDark),
              const SizedBox(height: 6),
              CountryPickerField(
                isDark: isDark,
                countries: state.availableCountries,
                selected: state.destinationCountry,
                loading: state.countriesLoading,
                locked: state.isEditing,
                hint: 'Search destination country',
                onSelected: cubit.setDestinationCountry,
              ),
              const SizedBox(height: 12),

              // ── Preferred date ────────────────────────────────────
              _Label('Preferred date', isDark: isDark),
              const SizedBox(height: 6),
              _DateTile(
                isDark: isDark,
                value: state.preferredDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.preferredDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) cubit.setPreferredDate(picked);
                },
              ),
              const SizedBox(height: 12),

              // ── Urgency ───────────────────────────────────────────
              _Label('Urgency', isDark: isDark),
              const SizedBox(height: 6),
              _DropdownField<UrgencyLevel>(
                isDark: isDark,
                value: state.urgencyLevel,
                options: UrgencyLevel.values,
                label: (u) => u.label,
                onChanged: cubit.setUrgencyLevel,
              ),
              const SizedBox(height: 12),

              // ── Partial proposals ─────────────────────────────────
              _PartialToggle(
                isDark: isDark,
                value: state.partialProposalAccepted,
                onToggle: cubit.togglePartialProposal,
              ),
              const SizedBox(height: 12),

              // ── Items ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _Label('Items to deliver', isDark: isDark),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selected = await _pickItems(context, cubit);
                      if (selected.isNotEmpty) cubit.addItems(selected);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Add Item',
                          style: TextStyle(
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
                Text(
                  'No items added yet',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                )
              else ...[
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (_, i) {
                      final draft = state.items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ItemDraftRow(
                          draft: draft,
                          isDark: isDark,
                          onQuantityChanged: (q) =>
                              cubit.updateQuantity(draft.id, q),
                          onRemove: () => cubit.removeItem(draft.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // ── Special note ──────────────────────────────────────
              _Label('Special note  (optional)', isDark: isDark),
              const SizedBox(height: 6),
              _Field(
                isDark: isDark,
                hint: 'e.g. Please handle carefully',
                maxLines: 2,
                initialValue: state.isEditing ? state.specialNote : null,
                onChanged: cubit.setSpecialNote,
              ),
              const SizedBox(height: 15),

              // ── Error ─────────────────────────────────────────────
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    state.error!,
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: AppColors.error),
                  ),
                ),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: state.submitting
                      ? null
                      : () {
                          if (state.isValid) {
                            cubit.submit();
                          } else {
                            showMissingFields(context, cubit.markErrors());
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient:
                          state.isValid ? AppColors.primaryGradient : null,
                      color: state.isValid
                          ? null
                          : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: state.submitting
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : Text(
                            state.isEditing
                                ? 'Save Changes'
                                : 'Send Request',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: state.isValid
                                  ? Colors.white
                                  : AppColors.textDisabled,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        );
      },
    );
  }
}

// Bridges the shared (cubit-agnostic) item picker to the offer-request cubit.
Future<List<ItemModel>> _pickItems(
  BuildContext context,
  CreateOfferRequestCubit cubit,
) {
  final state = cubit.state;
  return showItemPickerDialog(
    context,
    availableItems: state.availableItems,
    isLoading: state.itemsLoading,
    itemsError: state.itemsError,
    onRetry: cubit.loadItems,
    onCreate: cubit.createAndSelectItem,
  );
}

// ── Local form helpers ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
        ),
      );
}

class _Field extends StatefulWidget {
  final bool isDark;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? initialValue;

  const _Field({
    required this.isDark,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.initialValue,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(_Field old) {
    super.didUpdateWidget(old);
    // Sync the async-seeded value (edit mode) without clobbering user input.
    final v = widget.initialValue;
    if (v != null && v != old.initialValue && v != _controller.text) {
      _controller.text = v;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      style: TextStyle(
          fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.textTertiary),
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
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final bool isDark;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTile(
      {required this.isDark, required this.value, required this.onTap});

  String get _display {
    if (value == null) return 'Select date';
    return '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: value != null ? AppColors.primary : border,
              width: value != null ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14,
                color: value != null ? AppColors.primary : textTertiary),
            const SizedBox(width: 8),
            Text(
              _display,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: value != null ? textPrimary : textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final bool isDark;
  final T value;
  final List<T> options;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  const _DropdownField({
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
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
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

class _PartialToggle extends StatelessWidget {
  final bool isDark;
  final bool value;
  final VoidCallback onToggle;

  const _PartialToggle({
    required this.isDark,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? AppColors.info.withValues(alpha: 0.07)
              : surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? AppColors.info : border,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accept partial proposals',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value ? AppColors.info : textPrimary,
                    ),
                  ),
                  Text(
                    'Allow carriers to carry only some items',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.info : (isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(11),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDraftRow extends StatelessWidget {
  final OfferRequestItemDraft draft;
  final bool isDark;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _ItemDraftRow({
    required this.draft,
    required this.isDark,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = draft.quantity > 0
        ? (isDark ? AppColors.darkBorder : AppColors.border)
        : AppColors.error.withValues(alpha: 0.5);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.item.name,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  draft.item.measurementUnit.label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Qty stepper
          Row(
            children: [
              GestureDetector(
                onTap: draft.quantity > 1
                    ? () => onQuantityChanged(draft.quantity - 1)
                    : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 14,
                    color: draft.quantity > 1
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${draft.quantity}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onQuantityChanged(draft.quantity + 1),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border),
                  ),
                  child: const Icon(Icons.add_rounded,
                      size: 14, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
