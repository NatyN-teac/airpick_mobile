import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/media/upload_repository.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/navigation/match_chat_flow.dart';
import '../../chat/screens/chat_screen.dart';
import '../../offers/models/offer_models.dart';
import '../../offers/models/offer_response.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
import '../../offers/widgets/browse_offer_card.dart';
import '../../offers/widgets/form_widgets.dart';
import '../cubit/create_match_cubit.dart';
import '../models/match_models.dart';
import '../repository/match_repository.dart';

void openCreateMatch(
  BuildContext context,
  OfferResponse offer, {
  required void Function(MatchResponse response) onMatched,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (ctx) => CreateMatchCubit(
          matches: ctx.read<MatchRepository>(),
          uploads: ctx.read<UploadRepository>(),
          offer: offer,
        ),
        child: CreateMatchScreen(onMatched: onMatched),
      ),
    ),
  );
}

class CreateMatchScreen extends StatefulWidget {
  final void Function(MatchResponse response) onMatched;

  const CreateMatchScreen({super.key, required this.onMatched});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _picker = ImagePicker();
  bool _showSuccess = false;

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface : Colors.white;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo library',
                      style: TextStyle(fontFamily: 'Manrope')),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera',
                      style: TextStyle(fontFamily: 'Manrope')),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null || !mounted) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null && mounted) {
      context.read<CreateMatchCubit>().setPhotoLocal(file.path);
    }
  }

  void _onSuccessDismiss(BuildContext context, MatchResponse result) {
    widget.onMatched(result);
    // Return to the home stack, then open the match chat so the sender and
    // carrier can coordinate pickup and delivery — they can arrange the pickup
    // later from that conversation rather than losing the thread here.
    Navigator.of(context).popUntil((route) => route.isFirst);
    final matchId = result.id;
    if (matchId.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = appNavigatorKey.currentContext;
      if (ctx != null) {
        openChatScreen(
          ctx,
          matchId,
          welcomeMessage: buildMatchWelcomeMessage(result),
          initialMatch: result,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return BlocConsumer<CreateMatchCubit, CreateMatchState>(
      listenWhen: (p, c) =>
          c.status == CreateMatchStatus.success && p.status != c.status,
      listener: (context, state) {
        if (state.result != null) setState(() => _showSuccess = true);
      },
      builder: (context, state) {
        final cubit = context.read<CreateMatchCubit>();
        final offer = cubit.offer;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: state.isBusy
                  ? null
                  : () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Match Offer',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _showSuccess && state.result != null
                ? BubbleSuccessScreen(
                    key: const ValueKey('success'),
                    isDark: isDark,
                    onDismiss: () =>
                        _onSuccessDismiss(context, state.result!),
                    title: 'Match Created!',
                    subtitle:
                        'Opening your chat with the carrier so you can arrange pickup and delivery.',
                  )
                : Stack(
                    key: const ValueKey('form'),
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          8,
                          18,
                          MediaQuery.of(context).padding.bottom + 120,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroCard(offer: offer, isDark: isDark),
                            const SizedBox(height: 22),
                            _SectionTitle('What do you need?', isDark: isDark),
                            const SizedBox(height: 4),
                            Text(
                              'Select items and quantities to match.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...state.items.map(
                              (draft) => _MatchItemRow(
                                draft: draft,
                                isDark: isDark,
                                currency: offer.currencyEnum.symbol,
                                onToggle: (v) =>
                                    cubit.toggleItem(draft.item.id, v),
                                onQuantity: (q) =>
                                    cubit.setQuantity(draft.item.id, q),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _SectionTitle('Who receives?', isDark: isDark),
                            const SizedBox(height: 10),
                            _ReceiverToggle(
                              receiverNeeded: state.receiverNeeded,
                              isDark: isDark,
                              onChanged: cubit.setReceiverNeeded,
                            ),
                            if (state.receiverNeeded) ...[
                              const SizedBox(height: 16),
                              _ReceiverForm(
                                isDark: isDark,
                                firstName: state.firstName,
                                lastName: state.lastName,
                                phone: state.phone,
                                photoPath: state.photoLocalPath,
                                onFirstName: cubit.setFirstName,
                                onLastName: cubit.setLastName,
                                onPhone: cubit.setPhone,
                                onPickPhoto: _pickPhoto,
                              ),
                            ],
                            if (state.error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        AppColors.error.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    color: AppColors.error,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _StickyFooter(
                        isDark: isDark,
                        total: state.totalPrice,
                        currency: offer.currencyEnum.symbol,
                        canSubmit: state.canSubmit,
                        busy: state.isBusy,
                        busyLabel: state.status ==
                                CreateMatchStatus.uploadingPhoto
                            ? 'Uploading ID…'
                            : 'Sending match…',
                        onSubmit: cubit.submit,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final OfferResponse offer;
  final bool isDark;

  const _HeroCard({required this.offer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final leg = offer.firstLeg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            surface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CarrierAvatar(
                carrier: offer.carrier,
                fallbackSeed: offer.carrierId,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.carrier?.displayName ?? 'Carrier',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (leg != null)
                      Text(
                        '${leg.srcAirport.iataCode} → ${leg.destAirport.iataCode}  ·  ${offer.formattedDepartureDate}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (offer.pickupArea.isNotEmpty || offer.deliveryArea.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (offer.pickupArea.isNotEmpty)
                  Expanded(
                    child: _MiniTile(
                      icon: Icons.flight_takeoff_rounded,
                      label: 'Pickup',
                      value: offer.pickupArea,
                      isDark: isDark,
                    ),
                  ),
                if (offer.pickupArea.isNotEmpty &&
                    offer.deliveryArea.isNotEmpty)
                  const SizedBox(width: 8),
                if (offer.deliveryArea.isNotEmpty)
                  Expanded(
                    child: _MiniTile(
                      icon: Icons.flight_land_rounded,
                      label: 'Delivery',
                      value: offer.deliveryArea,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _MiniTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9,
                        color: textSecondary)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionTitle(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _MatchItemRow extends StatelessWidget {
  final MatchItemDraft draft;
  final bool isDark;
  final String currency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onQuantity;

  const _MatchItemRow({
    required this.draft,
    required this.isDark,
    required this.currency,
    required this.onToggle,
    required this.onQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final item = draft.item;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final selected = draft.selected && draft.quantity > 0;
    final step = item.quantityStep;
    final max = item.remainingQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.45)
              : border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: selected,
                  onChanged: (v) => onToggle(v ?? false),
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: border),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '$currency${item.pricePerItem.toStringAsFixed(2)} / ${item.unitLabel}  ·  ${OfferResponse.formatQuantity(max)} available',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Text(
                  '$currency${draft.lineTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (selected) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _QtyButton(
                  icon: Icons.remove_rounded,
                  enabled: draft.quantity - step >= step - 0.001,
                  isDark: isDark,
                  onTap: () => onQuantity(
                    ((draft.quantity - step) * 1000).round() / 1000,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    OfferResponse.formatQuantity(draft.quantity),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add_rounded,
                  enabled: draft.quantity + step <= max + 0.0001,
                  isDark: isDark,
                  onTap: () => onQuantity(
                    ((draft.quantity + step) * 1000).round() / 1000,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.unitLabel,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkBackground : AppColors.surface),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _ReceiverToggle extends StatelessWidget {
  final bool receiverNeeded;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ReceiverToggle({
    required this.receiverNeeded,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReceiverOption(
            label: 'I\'ll receive',
            subtitle: 'Items come to me',
            icon: Icons.person_rounded,
            selected: !receiverNeeded,
            isDark: isDark,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ReceiverOption(
            label: 'Someone else',
            subtitle: 'Third-party receiver',
            icon: Icons.people_rounded,
            selected: receiverNeeded,
            isDark: isDark,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _ReceiverOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ReceiverOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AppColors.primary : textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiverForm extends StatelessWidget {
  final bool isDark;
  final String firstName;
  final String lastName;
  final String phone;
  final String? photoPath;
  final ValueChanged<String> onFirstName;
  final ValueChanged<String> onLastName;
  final ValueChanged<String> onPhone;
  final VoidCallback onPickPhoto;

  const _ReceiverForm({
    required this.isDark,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.photoPath,
    required this.onFirstName,
    required this.onLastName,
    required this.onPhone,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel('Receiver details', isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormTextField(
                  isDark: isDark,
                  hint: 'First name',
                  onChanged: onFirstName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FormTextField(
                  isDark: isDark,
                  hint: 'Last name',
                  onChanged: onLastName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FormTextField(
            isDark: isDark,
            hint: 'Phone (e.g. +12025551234)',
            keyboardType: TextInputType.phone,
            onChanged: onPhone,
          ),
          const SizedBox(height: 14),
          FormLabel('Photo ID', isDark: isDark),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onPickPhoto,
            child: Container(
              width: double.infinity,
              height: photoPath != null ? 140 : 100,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: photoPath != null
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : border,
                  width: photoPath != null ? 1.5 : 1,
                ),
              ),
              child: photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(photoPath!), fit: BoxFit.cover),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 28, color: textSecondary),
                        const SizedBox(height: 6),
                        Text(
                          'Upload government-issued ID',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  final bool isDark;
  final double total;
  final String currency;
  final bool canSubmit;
  final bool busy;
  final String busyLabel;
  final VoidCallback onSubmit;

  const _StickyFooter({
    required this.isDark,
    required this.total,
    required this.currency,
    required this.canSubmit,
    required this.busy,
    required this.busyLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 14, 18, bottom + 14),
        decoration: BoxDecoration(
          color: surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Estimated total',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$currency${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: canSubmit && !busy ? onSubmit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            busyLabel,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Send Match',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
