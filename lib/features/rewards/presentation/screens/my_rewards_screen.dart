import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/reward_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/reward_models.dart';

class MyRewardsScreen extends StatefulWidget {
  const MyRewardsScreen({super.key});

  @override
  State<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final userId = context.read<SessionController>().user.id;
    await context.read<RewardController>().refreshForUser(userId);
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _formatInr(double value) {
    final n = value.toStringAsFixed(0);
    final withCommas = n.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$withCommas';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('My Rewards'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space5),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.lgAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current balance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        _formatPoints(rewards.balance),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Reward Points',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            Text('Reward History', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space3),
            if (rewards.entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.space5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 40,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Text(
                      'No reward points earned yet.',
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'Complete a purchase to start earning rewards.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...rewards.entries.map((entry) => _RewardHistoryTile(
                    entry: entry,
                    formatPoints: _formatPoints,
                    formatInr: _formatInr,
                    formatDate: _formatDate,
                  )),
          ],
        ),
      ),
    );
  }
}

class _RewardHistoryTile extends StatelessWidget {
  const _RewardHistoryTile({
    required this.entry,
    required this.formatPoints,
    required this.formatInr,
    required this.formatDate,
  });

  final RewardLedgerEntry entry;
  final String Function(int) formatPoints;
  final String Function(double) formatInr;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = entry.isEarned;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            positive
                ? '+${formatPoints(entry.points)} Points'
                : '-${formatPoints(entry.points)} Points',
            style: theme.textTheme.titleMedium?.copyWith(
              color: positive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            'Quotation #${entry.quotationDisplayId.isEmpty ? entry.quotationId : entry.quotationDisplayId}',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            entry.description.isEmpty ? 'Sale confirmed' : entry.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.outline,
            ),
          ),
          if (entry.quotationGrandTotal > 0)
            Text(
              '${formatInr(entry.quotationGrandTotal)} quotation',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.outline,
              ),
            ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            formatDate(entry.createdAt),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
