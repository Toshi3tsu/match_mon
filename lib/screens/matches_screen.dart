import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    // 自キャラクターを除外したマッチングを取得
    final filteredCollaborations = state.playerCharacter != null
        ? state.collaborations
            .where((collab) => collab.partner.id != state.playerCharacter!.id)
            .toList()
        : state.collaborations;

    if (filteredCollaborations.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'マッチング一覧',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'まだマッチングがありません',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '探すでいいねする',
                onPressed: () => context.go('/discover'),
                variant: ButtonVariant.primary,
                icon: const Icon(Icons.favorite, size: 20),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'マッチング一覧',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : isTablet ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            itemCount: filteredCollaborations.length,
            itemBuilder: (context, index) {
              final collaboration = filteredCollaborations[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 14 : 16),
                  child: isMobile
                      ? _buildMobileCard(
                          context,
                          collaboration,
                          theme,
                          ref,
                        )
                      : _buildDesktopCard(
                          context,
                          collaboration,
                          theme,
                          ref,
                          isTablet,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    dynamic collaboration,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonsterCard(
            monster: collaboration.partner,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        _buildInfoSection(
          context,
          collaboration,
          theme,
          ref,
          isMobile: true,
        ),
      ],
    );
  }

  Widget _buildDesktopCard(
    BuildContext context,
    dynamic collaboration,
    ThemeData theme,
    WidgetRef ref,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 2 : 3,
          child: MonsterCard(
            monster: collaboration.partner,
            onTap: () {},
          ),
        ),
        SizedBox(width: isTablet ? 12 : 16),
        Expanded(
          flex: isTablet ? 1 : 1,
          child: _buildInfoSection(
            context,
            collaboration,
            theme,
            ref,
            isMobile: false,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    dynamic collaboration,
    ThemeData theme,
    WidgetRef ref, {
    required bool isMobile,
    bool isTablet = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成立日時',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${collaboration.createdAt.year}年${collaboration.createdAt.month}月${collaboration.createdAt.day}日',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          'ボンド',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: collaboration.bond / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.blue.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${collaboration.bond} / 100',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: isMobile ? double.infinity : (isTablet ? 180.0 : 200.0),
          child: CustomButton(
            text: 'マッチ後セッション',
            onPressed: () {
              context.push(
                '/match-session',
                extra: collaboration,
              );
            },
            variant: ButtonVariant.primary,
            size: ButtonSize.small,
            icon: const Icon(Icons.games, size: 16),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isMobile ? double.infinity : (isTablet ? 180.0 : 200.0),
          child: CustomButton(
            text: '交配プランに追加',
            onPressed: () => context.go('/production'),
            variant: ButtonVariant.secondary,
            size: ButtonSize.small,
            icon: const Icon(Icons.science, size: 16),
          ),
        ),
      ],
    );
  }
}

