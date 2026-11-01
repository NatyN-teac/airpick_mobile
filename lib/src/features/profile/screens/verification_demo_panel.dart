import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/account_verification_cubit.dart';
import '../repository/demo_verification_repository.dart';

/// Debug-only: jumps the demo backend to a given verification state so every
/// screen can be checked. Only shown when [verificationDemoEnabled].
class VerificationDemoButton extends StatelessWidget {
  /// Clears the "submitted" success view so the new state is visible.
  final VoidCallback onReset;

  const VerificationDemoButton({super.key, required this.onReset});

  static const _labels = {
    DemoVerificationState.notStarted: 'Not started',
    DemoVerificationState.underReview: 'Under review',
    DemoVerificationState.approved: 'Approved',
    DemoVerificationState.declinedCooldown: 'Declined · 24h cooldown',
    DemoVerificationState.declinedRetryNow: 'Declined · retry now',
    DemoVerificationState.resubmission: 'Resubmission requested',
    DemoVerificationState.locked: 'Locked (3 declines)',
  };

  Future<void> _open(BuildContext context) async {
    final cubit = context.read<AccountVerificationCubit>();
    final repo = DemoVerificationRepository.shared(context.read<ApiClient>());
    final choice = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text(
                'Verification demo state',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            for (final entry in _labels.entries)
              ListTile(
                title: Text(entry.value),
                onTap: () => Navigator.pop(sheet, entry.key),
              ),
            ListTile(
              title: const Text('Account blocked (USER_BLOCKED)'),
              subtitle: const Text('Restart the app to leave this screen'),
              onTap: () => Navigator.pop(sheet, 'blocked'),
            ),
          ],
        ),
      ),
    );
    if (choice is DemoVerificationState) {
      repo.setState(choice);
      onReset();
      await cubit.refresh();
    } else if (choice == 'blocked') {
      AppSession.notifyBlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FloatingActionButton.small(
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        tooltip: 'Demo states',
        onPressed: () => _open(context),
        child: const Text(
          'DEMO',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
