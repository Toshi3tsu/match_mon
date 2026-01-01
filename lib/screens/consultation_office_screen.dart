import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_app_bar.dart';

/// 相談所の受付画面
/// 受付の人が「どのようなご用件でしょうか？」と質問し、
/// プレイヤーは3つの選択肢から選ぶ
class ConsultationOfficeScreen extends ConsumerWidget {
  const ConsultationOfficeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '相談所',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;
          final isDesktop = screenWidth >= 1200;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : isTablet ? 24 : 32,
              vertical: isMobile ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // 受付の人のイラストまたはアバター
                  _buildReceptionistAvatar(context, theme, isMobile),
                  const SizedBox(height: 24),
                  // 受付の人の質問
                  _buildReceptionistQuestion(context, theme),
                  const SizedBox(height: 32),
                  // 3つの選択肢ボタン
                  _buildServiceOptions(context, theme, state, isMobile),
                  const SizedBox(height: 32),
                  // 相談所の成長とメタ進行（折りたたみ可能）
                  _buildInstitutionInfo(context, theme, state, isMobile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 受付の人のアバター表示
  Widget _buildReceptionistAvatar(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? 120 : 150,
      height: isMobile ? 120 : 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.person,
        size: isMobile ? 60 : 80,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// 受付の人の質問
  Widget _buildReceptionistQuestion(
    BuildContext context,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '受付',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'どのようなご用件でしょうか？',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 3つのサービス選択肢
  Widget _buildServiceOptions(
    BuildContext context,
    ThemeData theme,
    dynamic state,
    bool isMobile,
  ) {
    return Column(
      children: [
        // 候補を探す
        _buildServiceCard(
          context,
          theme,
          title: '候補を探す',
          description: '相談所の案件（候補リスト）から"当たり素材"を探します',
          icon: Icons.search,
          color: Colors.blue,
          onTap: () => context.go('/discover'),
        ),
        const SizedBox(height: 16),
        // マッチを確認する
        _buildServiceCard(
          context,
          theme,
          title: 'マッチを確認する',
          description: '既に成立したマッチの一覧を確認し、ボンドを上げます',
          icon: Icons.favorite,
          color: Colors.pink,
          onTap: () => context.go('/collaborations'),
          badge: state.collaborations.isNotEmpty
              ? state.collaborations.length.toString()
              : null,
        ),
        const SizedBox(height: 16),
        // 配合を計画する
        _buildServiceCard(
          context,
          theme,
          title: '配合を計画する',
          description: '親個体を選択し、子の種族と継承をプレビューして配合を実行します',
          icon: Icons.science,
          color: Colors.purple,
          onTap: () => context.go('/production'),
        ),
      ],
    );
  }

  /// サービスカード
  Widget _buildServiceCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              // テキスト
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 矢印
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 相談所の成長とメタ進行（折りたたみ可能）
  Widget _buildInstitutionInfo(
    BuildContext context,
    ThemeData theme,
    dynamic state,
    bool isMobile,
  ) {
    final institution = state.persistentAssets.institution;

    return Card(
      child: ExpansionTile(
        leading: Icon(
          Icons.business,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          '相談所の成長とメタ進行',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 統計情報
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        '相談所ランク',
                        '${institution.consultationOfficeRank}',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        '契約枠',
                        '${institution.contractSlots}',
                        Icons.handshake,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        '推薦枠',
                        '${institution.recommendationSlots}',
                        Icons.recommend,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 説明文
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '相談所のランク、契約枠、推薦枠などのメタ進行状況は、周回をまたいで保持され、次ランの候補提示の質や希少遭遇率に影響します。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
