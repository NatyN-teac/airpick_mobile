import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/media/upload_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/verification_gate.dart';
import '../../matches/models/match_models.dart';
import '../../offer_requests/models/proposal_models.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
import '../../offers/widgets/form_widgets.dart';
import '../../chat/navigation/match_chat_flow.dart';
import '../cubit/engagement_cubit.dart';
import '../cubit/nav_cubit.dart';
import '../models/engagement_models.dart';

class ProposalEngagementDialog {
  ProposalEngagementDialog._();

  static Future<void> show(
    BuildContext context, {
    required ProposalEngagement proposal,
    required EngagementKind kind,
  }) {
    final engagementCubit = context.read<EngagementCubit>();
    final navCubit = context.read<NavCubit>();
    final navigator = Navigator.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: engagementCubit),
          BlocProvider.value(value: navCubit),
        ],
        child: _ProposalEngagementDialogBody(
          proposal: proposal,
          kind: kind,
          navigator: navigator,
        ),
      ),
    );
  }
}

class _ProposalEngagementDialogBody extends StatefulWidget {
  final ProposalEngagement proposal;
  final EngagementKind kind;
  final NavigatorState navigator;

  const _ProposalEngagementDialogBody({
    required this.proposal,
    required this.kind,
    required this.navigator,
  });

  @override
  State<_ProposalEngagementDialogBody> createState() =>
      _ProposalEngagementDialogBodyState();
}

class _ProposalEngagementDialogBodyState
    extends State<_ProposalEngagementDialogBody> {
  final _picker = ImagePicker();
  bool _receiverNeeded = false;
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String? _photoLocalPath;
  String? _busyAction;
  bool _showAcceptSuccess = false;
  MatchResponse? _acceptedMatch;

  bool get _isPending =>
      widget.proposal.status.toUpperCase() == 'PENDING';

  bool get _isCarrierView => widget.kind == EngagementKind.proposalSent;

  bool get _isSenderView => widget.kind == EngagementKind.proposalReceived;

  bool get _canWithdraw => _isCarrierView && _isPending;

  bool get _canRespond => _isSenderView && _isPending;

  bool get _hasValidReceiver {
    if (!_receiverNeeded) return true;
    return _firstName.trim().isNotEmpty &&
        _lastName.trim().isNotEmpty &&
        _phone.trim().isNotEmpty &&
        _photoLocalPath != null;
  }

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
      setState(() => _photoLocalPath = file.path);
    }
  }

  Future<void> _confirmWithdraw() async {
    final confirmed = await _confirmAction(
      title: 'Withdraw proposal?',
      message:
          'This will remove your proposal from the request. You can send a new one later.',
      confirmLabel: 'Withdraw',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyAction = 'withdraw');
    try {
      await context
          .read<EngagementCubit>()
          .withdrawProposal(widget.proposal.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Proposal withdrawn');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<void> _confirmReject() async {
    final confirmed = await _confirmAction(
      title: 'Reject proposal?',
      message: 'The carrier will be notified that you declined this offer.',
      confirmLabel: 'Reject',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyAction = 'reject');
    try {
      await context.read<EngagementCubit>().rejectProposal(widget.proposal.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Proposal rejected');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<void> _accept() async {
    if (!requireVerified(context)) return;
    if (!_hasValidReceiver) {
      _snack(
        _receiverNeeded
            ? 'Please complete receiver details and photo ID.'
            : 'Please review the proposal before accepting.',
        isError: true,
      );
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Accept proposal?',
      message:
          'This creates a match and chat. Other pending proposals on this request will be declined.',
      confirmLabel: 'Accept',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyAction = 'accept');
    final uploads = context.read<UploadRepository>();
    final engagementCubit = context.read<EngagementCubit>();
    try {
      String? photoUrl;
      if (_receiverNeeded && _photoLocalPath != null) {
        photoUrl = await uploads.uploadFile(File(_photoLocalPath!));
        if (!mounted) return;
      }

      final request = AcceptProposalRequest(
        receiverNeeded: _receiverNeeded,
        receiver: _receiverNeeded
            ? MatchReceiverRequest(
                firstName: _firstName.trim(),
                lastName: _lastName.trim(),
                phone: _phone.trim(),
                photoIdUrl: photoUrl ?? '',
              )
            : null,
      );

      final match = await engagementCubit.acceptProposal(
            widget.proposal.id,
            request,
          );
      if (!mounted) return;
      setState(() {
        _busyAction = null;
        _acceptedMatch = match;
        _showAcceptSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<bool?> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: 'Manrope')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                confirmLabel,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: destructive ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Manrope')),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  String _message(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    if (_showAcceptSuccess && _acceptedMatch != null) {
      return Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          width: 320,
          height: 300,
          child: BubbleSuccessScreen(
            isDark: isDark,
            title: 'Proposal accepted!',
            subtitle: 'Opening your match chat…',
            onDismiss: () => navigateToMatchChatAfterAccept(
              navCubit: context.read<NavCubit>(),
              navigator: widget.navigator,
              match: _acceptedMatch!,
              fallbackItemNames:
                  widget.proposal.items.map((i) => i.itemName).toList(),
            ),
          ),
        ),
      );
    }

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final proposal = widget.proposal;
    final leg = proposal.flight?.legs.isNotEmpty == true
        ? proposal.flight!.legs.first
        : null;
    final isBusy = _busyAction != null;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (_isSenderView ? AppColors.success : AppColors.info)
                          .withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSenderView
                      ? Icons.inbox_rounded
                      : Icons.outbound_rounded,
                  color: _isSenderView ? AppColors.success : AppColors.info,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _isCarrierView ? 'Your proposal' : 'Proposal for you',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                proposal.status.replaceAll('_', ' '),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isPending ? AppColors.info : textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leg != null)
                        _InfoTile(
                          icon: Icons.flight_takeoff_rounded,
                          label: 'Route',
                          value:
                              '${leg.srcAirport.iataCode} → ${leg.destAirport.iataCode}',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Pickup & delivery',
                        value:
                            '${proposal.pickupArea} → ${proposal.deliveryArea}',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      if (proposal.meetupPlaces.isNotEmpty)
                        _InfoTile(
                          icon: Icons.place_outlined,
                          label: 'Meetup',
                          value: proposal.meetupPlaces.join(', '),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      if (proposal.paymentMethods.isNotEmpty)
                        _InfoTile(
                          icon: Icons.payments_outlined,
                          label: 'Payment',
                          value: proposal.paymentMethods.join(', '),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      const SizedBox(height: 8),
                      ...proposal.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.itemName,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} × \$${item.pricePerItem.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (proposal.note != null && proposal.note!.isNotEmpty)
                        _InfoTile(
                          icon: Icons.notes_rounded,
                          label: 'Note',
                          value: proposal.note!,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            '\$${proposal.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (_canRespond) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Who will receive the items?',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ReceiverToggle(
                          receiverNeeded: _receiverNeeded,
                          isDark: isDark,
                          onChanged: isBusy
                              ? null
                              : (v) => setState(() => _receiverNeeded = v),
                        ),
                        if (_receiverNeeded) ...[
                          const SizedBox(height: 12),
                          _ReceiverFormSection(
                            isDark: isDark,
                            photoPath: _photoLocalPath,
                            onFirstName: (v) => setState(() => _firstName = v),
                            onLastName: (v) => setState(() => _lastName = v),
                            onPhone: (v) => setState(() => _phone = v),
                            onPickPhoto: isBusy ? () {} : _pickPhoto,
                          ),
                        ],
                      ] else if (_isSenderView && !_isPending) ...[
                        const SizedBox(height: 14),
                        Text(
                          'This proposal is no longer pending.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ] else if (_isCarrierView && !_isPending) ...[
                        const SizedBox(height: 14),
                        Text(
                          'This proposal can no longer be withdrawn.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_canWithdraw)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : _confirmWithdraw,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _busyAction == 'withdraw'
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Withdraw proposal',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              if (_canRespond) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : _confirmReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          minimumSize: const Size(0, 48),
                        ),
                        child: _busyAction == 'reject'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Reject',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isBusy || !_hasValidReceiver ? null : _accept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          minimumSize: const Size(0, 48),
                        ),
                        child: _busyAction == 'accept'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Accept',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: isBusy ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiverToggle extends StatelessWidget {
  final bool receiverNeeded;
  final bool isDark;
  final ValueChanged<bool>? onChanged;

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
            onTap: onChanged == null ? null : () => onChanged!(false),
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
            onTap: onChanged == null ? null : () => onChanged!(true),
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
  final VoidCallback? onTap;

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
              : (isDark ? AppColors.darkBackground : AppColors.surface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.45)
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.primary : textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
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

class _ReceiverFormSection extends StatelessWidget {
  final bool isDark;
  final String? photoPath;
  final ValueChanged<String> onFirstName;
  final ValueChanged<String> onLastName;
  final ValueChanged<String> onPhone;
  final VoidCallback onPickPhoto;

  const _ReceiverFormSection({
    required this.isDark,
    required this.photoPath,
    required this.onFirstName,
    required this.onLastName,
    required this.onPhone,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
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
              height: 88,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: photoPath == null
                  ? Center(
                      child: Text(
                        'Tap to add photo ID',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        File(photoPath!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
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
