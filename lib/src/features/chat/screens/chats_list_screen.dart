import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../home/cubit/engagement_cubit.dart';
import '../../home/models/engagement_models.dart';
import '../../matches/models/match_models.dart';
import '../models/chat_summary.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  static MatchEngagement? _matchFor(String matchId, EngagementState state) {
    final matches = state.response?.matchedOffers ?? const <MatchEngagement>[];
    for (final m in matches) {
      if (m.id == matchId) return m;
    }
    return null;
  }

  static MatchResponse? _toMatchResponse(MatchEngagement? m) {
    if (m == null) return null;
    return MatchResponse(
      id: m.id,
      offerId: m.offerId,
      status: m.status,
      totalPrice: m.totalPrice,
      receiverNeeded: m.receiverNeeded,
      matchedItems: m.matchedItems,
      chatId: m.chatId,
    );
  }

  static List<ChatSummary> _summariesFromEngagements(EngagementState state) {
    final matches = state.response?.matchedOffers ?? const <MatchEngagement>[];
    final isCarrier = state.response?.mode.toUpperCase() == 'CARRIER';
    return matches
        .map(
          (m) {
            final other = m.otherParty(viewerIsCarrier: isCarrier);
            return ChatSummary(
              matchId: m.id,
              title: m.matchedItems.isNotEmpty
                  ? m.matchedItems.map((i) => i.itemName).take(2).join(', ')
                  : 'Match',
              otherPartyName: other?.displayName,
              otherPartyAvatarUrl: other?.profilePictureUrl,
              lastMessage: m.status.replaceAll('_', ' '),
              lastMessageAt: DateTime.tryParse(m.updatedAt),
            );
          },
        )
        .toList()
      ..sort((a, b) {
        final at = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return BlocBuilder<EngagementCubit, EngagementState>(
      builder: (context, state) {
        final chats = _summariesFromEngagements(state);
        final viewerIsCarrier =
            context.watch<UserModeCubit>().state == UserMode.carrier;

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
              child: state.loading && chats.isEmpty
                  ? const SkeletonChatList()
                  : chats.isEmpty
                      ? _EmptyState(
                          isDark: isDark,
                          onRefresh: () => context
                              .read<EngagementCubit>()
                              .load(force: true),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => context
                              .read<EngagementCubit>()
                              .load(force: true),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                            itemCount: chats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 2),
                            itemBuilder: (_, i) => _ChatTile(
                              summary: chats[i],
                              match: _matchFor(chats[i].matchId, state),
                              isDark: isDark,
                              viewerIsCarrier: viewerIsCarrier,
                            ),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatSummary summary;
  final MatchEngagement? match;
  final bool isDark;
  final bool viewerIsCarrier;
  const _ChatTile({
    required this.summary,
    required this.match,
    required this.isDark,
    required this.viewerIsCarrier,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final partyName = summary.otherPartyName ??
        match?.otherParty(viewerIsCarrier: viewerIsCarrier)?.displayName;
    final avatarName = partyName ?? summary.title;
    final hasUnread = summary.unreadCount > 0;

    return InkWell(
      onTap: () => openChatScreen(
        context,
        summary.matchId,
        initialMatch: ChatsListScreen._toMatchResponse(match),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              name: avatarName,
              url: summary.otherPartyAvatarUrl ??
                  match
                      ?.otherParty(viewerIsCarrier: viewerIsCarrier)
                      ?.profilePictureUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary.lastMessage.isEmpty
                        ? 'Tap to open'
                        : summary.lastMessage,
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
                if (partyName != null)
                  Text(
                    partyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                if (partyName != null) const SizedBox(height: 2),
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
                        horizontal: 6, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${summary.unreadCount}',
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
  final bool isDark;
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          Icon(
            Icons.forum_outlined,
            size: 56,
            color: isDark
                ? AppColors.darkTextTertiary
                : const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'No conversations yet',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Chats appear here once you match on a delivery.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  const _Avatar({required this.name, this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: NetworkImage(url!));
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
