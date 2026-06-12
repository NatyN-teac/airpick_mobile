import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../matches/models/match_models.dart';
import '../../matches/repository/match_repository.dart';
import '../service/chat_socket.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../cubit/chats_list_cubit.dart';
import '../repository/chat_repository.dart';

// Entry point — pushes the chat for a given match.
Future<void> openChatScreen(
  BuildContext context,
  String matchId, {
  String? welcomeMessage,
  MatchResponse? initialMatch,
}) async {
  final api = context.read<ApiClient>();
  final tokenStorage = context.read<TokenStorage>();
  ChatsListCubit? chatsListCubit;
  try {
    chatsListCubit = context.read<ChatsListCubit>();
    chatsListCubit.clearUnreadForMatch(matchId);
  } catch (_) {}

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => ChatCubit(
          repo: ChatRepository(api),
          socket: ChatSocket(tokenStorage),
          matches: MatchRepository(api),
          tokenStorage: tokenStorage,
          matchId: matchId,
          welcomeMessage: welcomeMessage,
          initialMatch: initialMatch,
        )..open(),
        child: const ChatScreen(),
      ),
    ),
  );

  if (context.mounted && chatsListCubit != null) {
    await chatsListCubit.reload();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();
  final _input = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
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
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (p, c) => p.messages.length != c.messages.length,
      listener: (context, _) => _scrollToBottom(),
      builder: (context, state) {
        final ctx = state.context;
        final name = ctx?.otherPartyName ?? 'Chat';
        final route = state.routeLabel ?? _routeLabel(ctx);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: GestureDetector(
              onTap: () => _showMatchSheet(context, state),
              child: Row(
                children: [
                  _Avatar(
                    name: name,
                    url: ctx?.otherPartyAvatarUrl,
                    size: 36,
                    presenceColor: _statusColor(state.connState),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        _StatusLine(
                          connState: state.connState,
                          route: route,
                          itemSummary: state.itemSummary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Match details',
                icon: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 20),
                onPressed: () => _showMatchSheet(context, state),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              _MatchBanner(
                state: state,
                isDark: isDark,
                onTap: () => _showMatchSheet(context, state),
              ),
              if (state.inDelivery && !state.isCarrier)
                _DeliveryNotice(isDark: isDark, forCarrier: false),
              if (state.inDelivery && state.isCarrier)
                _DeliveryNotice(isDark: isDark, forCarrier: true),
              if (state.error != null && state.status == ChatStatus.ready)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Text(
                    state.error!,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: AppColors.error,
                    ),
                  ),
                ),
              Expanded(child: _body(context, state, isDark)),
              if (state.canPickUp)
                _PickupBar(
                  isDark: isDark,
                  busy: state.pickingUp,
                  onPickUp: () => _confirmPickup(context),
                ),
              _Composer(
                controller: _input,
                isDark: isDark,
                enabled: state.status == ChatStatus.ready &&
                    state.connState == ChatConnState.connected,
                onSend: () {
                  context.read<ChatCubit>().send(_input.text);
                  _input.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, ChatState state, bool isDark) {
    if (state.status == ChatStatus.loading) {
      return const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary));
    }
    if (state.status == ChatStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 36, color: AppColors.error),
            const SizedBox(height: 10),
            Text(state.error ?? 'Could not load chat',
                style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 13)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.read<ChatCubit>().retry(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
    if (state.messages.isEmpty) {
      return Center(
        child: Text('Say hello 👋',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            )),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: state.messages.length,
      itemBuilder: (_, i) {
        final m = state.messages[i];
        final prev = i > 0 ? state.messages[i - 1] : null;
        final showDay = prev == null || !_sameDay(prev.sentAt, m.sentAt);
        return Column(
          children: [
            if (showDay) _DaySeparator(date: m.sentAt, isDark: isDark),
            _Bubble(message: m, mine: state.isMine(m), isDark: isDark),
          ],
        );
      },
    );
  }

  Future<void> _confirmPickup(BuildContext context) async {
    final photoPath = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PickupPhotoSheet(),
    );
    if (photoPath == null || !context.mounted) return;
    await context.read<ChatCubit>().startPickup(photoPath: photoPath);
  }

  void _showMatchSheet(BuildContext context, ChatState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MatchDetailSheet(state: state, isDark: isDark),
    );
  }

  String? _routeLabel(MatchContext? c) {
    if (c == null) return null;
    if (c.fromLabel != null && c.toLabel != null) {
      return '${c.fromLabel}  →  ${c.toLabel}';
    }
    return c.fromLabel ?? c.toLabel;
  }

  Color _statusColor(ChatConnState s) => switch (s) {
        ChatConnState.connected => AppColors.success,
        ChatConnState.connecting ||
        ChatConnState.reconnecting =>
          AppColors.warning,
        ChatConnState.disconnected => AppColors.textDisabled,
      };

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// Subtle status line under the name (WhatsApp-style): "Active" when connected,
// "connecting…/reconnecting…" otherwise — no intrusive banner.
class _StatusLine extends StatelessWidget {
  final ChatConnState connState;
  final String? route;
  final String itemSummary;
  final Color textSecondary;
  const _StatusLine({
    required this.connState,
    required this.route,
    required this.itemSummary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    if (connState == ChatConnState.connected) {
      if (route != null && route!.isNotEmpty) {
        return Text(
          route!,
          style: TextStyle(
              fontFamily: 'Manrope', fontSize: 11, color: textSecondary),
          overflow: TextOverflow.ellipsis,
        );
      }
      return Text(
        itemSummary,
        style: TextStyle(
            fontFamily: 'Manrope', fontSize: 11, color: textSecondary),
        overflow: TextOverflow.ellipsis,
      );
    }
    final label = connState == ChatConnState.reconnecting
        ? 'reconnecting…'
        : connState == ChatConnState.connecting
            ? 'connecting…'
            : 'offline';
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
      ),
    );
  }
}

// ── Match banner (pinned, collapsible context) ────────────────────────────────

class _MatchBanner extends StatelessWidget {
  final ChatState state;
  final bool isDark;
  final VoidCallback onTap;

  const _MatchBanner({
    required this.state,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext ctx) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final route = state.routeLabel;
    final status = state.displayStatus;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (status != null) _StatusPill(status: status),
                      if (status != null) const SizedBox(width: 6),
                      Text(
                        '${state.itemCount} item${state.itemCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.itemSummary,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (route != null && route.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      route,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Row(
              children: [
                Text('Match',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryNotice extends StatelessWidget {
  final bool isDark;
  final bool forCarrier;
  const _DeliveryNotice({required this.isDark, required this.forCarrier});

  @override
  Widget build(BuildContext context) {
    final bg = forCarrier
        ? AppColors.info.withValues(alpha: 0.12)
        : AppColors.success.withValues(alpha: 0.12);
    final color = forCarrier ? AppColors.info : AppColors.success;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            forCarrier ? Icons.local_shipping_rounded : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              forCarrier
                  ? 'Delivery in progress — head to the destination.'
                  : 'Your carrier has picked up the items.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupBar extends StatelessWidget {
  final bool isDark;
  final bool busy;
  final VoidCallback onPickUp;

  const _PickupBar({
    required this.isDark,
    required this.busy,
    required this.onPickUp,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready for pickup',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Take a photo of the items to start delivery.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: busy ? null : onPickUp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: busy ? null : AppColors.primaryGradient,
                color: busy ? AppColors.textDisabled : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Pick up',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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

class _PickupPhotoSheet extends StatefulWidget {
  const _PickupPhotoSheet();

  @override
  State<_PickupPhotoSheet> createState() => _PickupPhotoSheetState();
}

class _PickupPhotoSheetState extends State<_PickupPhotoSheet> {
  final _picker = ImagePicker();
  String? _photoPath;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null && mounted) setState(() => _photoPath = file.path);
  }

  Future<void> _chooseSource() async {
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
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm pickup',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Photograph the items you received from the sender. This starts tracked delivery.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _chooseSource,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _photoPath != null
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _photoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 32,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Image.file(
                      File(_photoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _photoPath == null
                ? null
                : () => Navigator.pop(context, _photoPath),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient:
                    _photoPath != null ? AppColors.primaryGradient : null,
                color: _photoPath == null ? AppColors.textDisabled : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Start delivery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchDetailSheet extends StatelessWidget {
  final ChatState state;
  final bool isDark;

  const _MatchDetailSheet({required this.state, required this.isDark});

  @override
  Widget build(BuildContext ctx) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final context = state.context;
    final items = state.match?.matchedItems ?? const [];
    final route = state.routeLabel ?? '';

    return DraggableScrollableSheet(
      initialChildSize: items.length > 2 ? 0.72 : 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(ctx).padding.bottom + 20,
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Avatar(
                  name: context?.otherPartyName ?? '?',
                  url: context?.otherPartyAvatarUrl,
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context?.otherPartyName ?? 'Match',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      if (state.displayStatus != null) ...[
                        const SizedBox(height: 4),
                        _StatusPill(status: state.displayStatus!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (route.isNotEmpty) _kv('Route', route, isDark),
            if (state.totalPrice > 0)
              _kv('Total', '\$${state.totalPrice.toStringAsFixed(2)}', isDark),
            const SizedBox(height: 4),
            Text(
              'Items (${state.itemCount})',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Item details could not be loaded.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              )
            else
              ...items.map((item) => _MatchItemRow(item: item, isDark: isDark)),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, bool isDark) {
    if (v.isEmpty) return const SizedBox.shrink();
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              k,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchItemRow extends StatelessWidget {
  final MatchedItemResponse item;
  final bool isDark;

  const _MatchItemRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final qtyLabel = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Text(
                  [
                    if (item.category != null) item.category,
                    'Qty $qtyLabel',
                    if (item.pricePerItem > 0)
                      '\$${item.pricePerItem.toStringAsFixed(2)} each',
                  ].whereType<String>().join(' · '),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (item.displayStatus != null)
            _StatusPill(status: item.displayStatus!),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  final bool isDark;
  const _Bubble(
      {required this.message, required this.mine, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mineColor = AppColors.primary.withValues(alpha: 0.14);
    final theirsColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
        decoration: BoxDecoration(
          color: mine ? mineColor : theirsColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                height: 1.3,
                color: mine ? AppColors.primaryDark : textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.sentAt),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9,
                    color: textTertiary,
                  ),
                ),
                if (mine && message.pending) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.access_time_rounded,
                      size: 10, color: textTertiary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  const _DaySeparator({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day)
        ? 'Today'
        : DateFormat('MMM d, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ── Composer ──────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool enabled;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isDark,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final fieldBg = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      color: surface,
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 14, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
                filled: true,
                fillColor: fieldBg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared avatar + pills ─────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double size;
  // When set, shows a small presence dot (connection state) on the avatar.
  final Color? presenceColor;
  const _Avatar({
    required this.name,
    this.url,
    this.size = 40,
    this.presenceColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget avatar;
    if (url != null && url!.isNotEmpty) {
      avatar = CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(url!));
    } else {
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
      avatar = Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(initial,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
        ),
      );
    }

    if (presenceColor == null) return avatar;
    final ring = isDark ? AppColors.darkBackground : AppColors.background;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.30,
              height: size * 0.30,
              decoration: BoxDecoration(
                color: presenceColor,
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  Color get _color => switch (status.toUpperCase()) {
        'MATCHED' || 'ACCEPTED' => AppColors.success,
        'IN_PROGRESS' || 'IN_DELIVERY' || 'IN_TRANSIT' => AppColors.info,
        'COLLECTED' => AppColors.info,
        'COMPLETED' => AppColors.textSecondary,
        _ => AppColors.primary,
      };

  String get _label {
    final s = status.replaceAll('_', ' ').toLowerCase();
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(_label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _color,
            )),
      );
}
