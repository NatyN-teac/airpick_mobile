import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../../core/widgets/state_message.dart';
import '../cubit/chats_list_cubit.dart';
import '../cubit/chats_list_state.dart';
import '../models/chat_summary.dart';
import 'chat_screen.dart';

// Chat-list status chip: only non-default states get a label.
String? _chatStatusLabel(String status) => switch (status.toUpperCase()) {
      'IN_PROGRESS' || 'IN_DELIVERY' => 'In transit',
      'COMPLETED' => 'Delivered',
      _ => null,
    };

Color _chatStatusColor(String status) => switch (status.toUpperCase()) {
      'IN_PROGRESS' || 'IN_DELIVERY' => AppColors.info,
      'COMPLETED' => AppColors.success,
      _ => AppColors.textSecondary,
    };

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return BlocBuilder<ChatsListCubit, ChatsListState>(
      builder: (context, chatsState) {
        final chats = chatsState.chats;
        final loading = chatsState.loading && chats.isEmpty;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? const SkeletonChatList()
                  : chats.isEmpty
                  ? _EmptyState(onRefresh: () => _refresh(context))
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _refresh(context),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: chats.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 2),
                        itemBuilder: (_, i) => _ChatTile(
                          summary: chats[i],
                          isDark: isDark,
                          showUnread: true,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _refresh(BuildContext context) async {
    await context.read<ChatsListCubit>().reload();
  }
}

class _ChatTile extends StatelessWidget {
  final ChatSummary summary;
  final bool isDark;
  final bool showUnread;

  const _ChatTile({
    required this.summary,
    required this.isDark,
    required this.showUnread,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final partyName = summary.otherPartyName;
    // The conversation is with a person — lead with their name. Fall back to
    // the item summary only when the other party is unknown.
    final title = (partyName != null && partyName.trim().isNotEmpty)
        ? partyName
        : summary.title;
    final statusLabel = _chatStatusLabel(summary.status);
    final avatarName = title;
    final hasUnread = showUnread && summary.unreadCount > 0;
    // Secondary line: the item(s) this conversation is about (previously shown
    // as the title). Fall back to the status/last message if unavailable.
    final subtitle = summary.title.isNotEmpty && summary.title != title
        ? summary.title
        : (summary.lastMessage.isNotEmpty
            ? summary.lastMessage
            : 'No messages yet');

    return InkWell(
      onTap: () => openChatScreen(context, summary.matchId),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: summary.otherPartyAvatarUrl != null
                  ? NetworkImage(summary.otherPartyAvatarUrl!)
                  : null,
              child: summary.otherPartyAvatarUrl == null
                  ? Text(
                      avatarName.isNotEmpty ? avatarName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (statusLabel != null) ...[
                        const SizedBox(width: 6),
                        _StatusChip(
                          label: statusLabel,
                          color: _chatStatusColor(summary.status),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                      color: hasUnread ? textPrimary : textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (summary.lastMessageAt != null)
                  Text(
                    DateFormat('HH:mm').format(summary.lastMessageAt!),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      summary.unreadCount > 99
                          ? '99+'
                          : '${summary.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          const AppEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            message: 'Matched deliveries will appear here.',
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
