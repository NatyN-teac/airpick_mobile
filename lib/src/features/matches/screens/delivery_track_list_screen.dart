import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/screens/chat_screen.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../cubit/delivery_track_cubit.dart';
import '../models/delivery_track_models.dart';
import '../widgets/delivery_track_card.dart';

void openDeliveryTrackList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<DeliveryTrackCubit>(),
        child: const DeliveryTrackListScreen(),
      ),
    ),
  );
}

class DeliveryTrackListScreen extends StatefulWidget {
  const DeliveryTrackListScreen({super.key});

  @override
  State<DeliveryTrackListScreen> createState() =>
      _DeliveryTrackListScreenState();
}

class _DeliveryTrackListScreenState extends State<DeliveryTrackListScreen> {
  DeliveryTrackFilter _filter = DeliveryTrackFilter.all;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mode = context.watch<UserModeCubit>().state;
    final viewerIsCarrier = mode == UserMode.carrier;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'In delivery',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<DeliveryTrackCubit, DeliveryTrackState>(
        builder: (context, state) {
          if (state.loading && state.data == null) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            );
          }

          final data = state.data;
          final items = data?.filtered(_filter) ?? const [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: DeliveryTrackFilter.values.map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          f.label,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                          ),
                        ),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        backgroundColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    state.error!,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? _EmptyFilterState(
                        isDark: isDark,
                        filter: _filter,
                        onRefresh: () =>
                            context.read<DeliveryTrackCubit>().reload(),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () =>
                            context.read<DeliveryTrackCubit>().reload(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => DeliveryTrackCard(
                            item: items[i],
                            isDark: isDark,
                            viewerIsCarrier: viewerIsCarrier,
                            onTap: items[i].match.id.isEmpty
                                ? null
                                : () {
                                    openChatScreen(
                                      context,
                                      items[i].match.id,
                                      initialMatch: items[i].match,
                                    );
                                  },
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  final bool isDark;
  final DeliveryTrackFilter filter;
  final Future<void> Function() onRefresh;

  const _EmptyFilterState({
    required this.isDark,
    required this.filter,
    required this.onRefresh,
  });

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
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Icon(
            Icons.local_shipping_outlined,
            size: 52,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              filter == DeliveryTrackFilter.all
                  ? 'No active deliveries'
                  : 'No ${filter.label.toLowerCase()} deliveries',
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
              'Deliveries appear here after pickup and while en route.',
              textAlign: TextAlign.center,
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
