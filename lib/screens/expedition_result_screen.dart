import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../models/expedition_result.dart';

class ExpeditionResultScreen extends ConsumerWidget {
  final String? resultId;

  const ExpeditionResultScreen({
    super.key,
    this.resultId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    
    // モックの遠征リザルト（実際の実装では、resultIdから取得）
    final result = _createMockResult(state);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '遠征リザルト',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;
          final isDesktop = screenWidth >= 1200;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : isTablet ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 遠征概要
                  _buildExpeditionSummary(context, theme, result, isMobile, isTablet),
                  const SizedBox(height: 16),
                  // 持ち帰り資産
                  _buildCarriedAssets(context, theme, result.carriedAssets, isMobile, isTablet),
                  const SizedBox(height: 16),
                  // 消失した資産
                  _buildLostAssets(context, theme, result.lostAssets, isMobile, isTablet),
                  const SizedBox(height: 16),
                  // 継承された資産
                  _buildInheritedAssets(context, theme, result.inheritedAssets, isMobile, isTablet),
                  const SizedBox(height: 24),
                  // 次の行動への導線
                  _buildNextActions(context, theme, ref, isMobile, isTablet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpeditionSummary(
    BuildContext context,
    ThemeData theme,
    ExpeditionResult result,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      color: _getEndReasonColor(result.endReason).shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '遠征概要',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getEndReasonColor(result.endReason).shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEndReasonLabel(result.endReason),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getEndReasonColor(result.endReason).shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              theme,
              '開始',
              _formatDateTime(result.startedAt),
            ),
            _buildSummaryRow(
              theme,
              '終了',
              _formatDateTime(result.endedAt),
            ),
            _buildSummaryRow(
              theme,
              '到達階層',
              '${result.reachedFloor}階層',
            ),
            if (result.goal != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: result.goalAchieved
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      result.goalAchieved ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: result.goalAchieved
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '目標: ${result.goal!.description}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: result.goalAchieved
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarriedAssets(
    BuildContext context,
    ThemeData theme,
    CarriedAssets assets,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: isMobile ? 20 : 24,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '持ち帰り資産',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assets.monsters.isNotEmpty) ...[
              Text(
                '個体: ${assets.monsters.length}体',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (assets.resources.isNotEmpty) ...[
              Text(
                '資源:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...assets.resources.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            if (assets.knowledge.isNotEmpty) ...[
              Text(
                '知識: ${assets.knowledge.length}件',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (assets.choices.isNotEmpty) ...[
              Text(
                '選択肢: ${assets.choices.length}件',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (assets.lineageAssets.isNotEmpty) ...[
              Text(
                '系譜資産: ${assets.lineageAssets.length}件',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.orange.shade700,
                ),
              ),
            ],
            if (assets.monsters.isEmpty &&
                assets.resources.isEmpty &&
                assets.knowledge.isEmpty &&
                assets.choices.isEmpty &&
                assets.lineageAssets.isEmpty)
              Text(
                '持ち帰った資産はありません',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLostAssets(
    BuildContext context,
    ThemeData theme,
    LostAssets assets,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  size: isMobile ? 20 : 24,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '消失した資産',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assets.monsters.isNotEmpty) ...[
              Text(
                '失われた個体: ${assets.monsters.length}体',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (assets.resources.isNotEmpty) ...[
              Text(
                '失われた資源:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...assets.resources.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            if (assets.temporaryBuffs.isNotEmpty) ...[
              Text(
                '失われた強化: ${assets.temporaryBuffs.length}件',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (assets.monsters.isEmpty &&
                assets.resources.isEmpty &&
                assets.temporaryBuffs.isEmpty)
              Text(
                '消失した資産はありません',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInheritedAssets(
    BuildContext context,
    ThemeData theme,
    InheritedAssets assets,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  size: isMobile ? 20 : 24,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '継承された資産（永続資産に追加）',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 知識
            if (assets.breedingRecipes.isNotEmpty ||
                assets.enemyEncyclopedia.isNotEmpty ||
                assets.encounterBranchConditions.isNotEmpty ||
                assets.consultationOfficeRumors.isNotEmpty) ...[
              _buildAssetCategory(
                theme,
                '知識',
                [
                  if (assets.breedingRecipes.isNotEmpty)
                    '配合レシピ: ${assets.breedingRecipes.length}件',
                  if (assets.enemyEncyclopedia.isNotEmpty)
                    '敵図鑑: ${assets.enemyEncyclopedia.length}件',
                  if (assets.encounterBranchConditions.isNotEmpty)
                    '遭遇分岐: ${assets.encounterBranchConditions.length}件',
                  if (assets.consultationOfficeRumors.isNotEmpty)
                    '相談所の噂: ${assets.consultationOfficeRumors.length}件',
                ],
                Colors.orange,
              ),
              const SizedBox(height: 8),
            ],
            // 選択肢
            if (assets.covenantClauses.isNotEmpty ||
                assets.bondActions.isNotEmpty ||
                assets.encounterProtocols.isNotEmpty) ...[
              _buildAssetCategory(
                theme,
                '選択肢',
                [
                  if (assets.covenantClauses.isNotEmpty)
                    '契約条項: ${assets.covenantClauses.length}件',
                  if (assets.bondActions.isNotEmpty)
                    'ボンド行動: ${assets.bondActions.length}件',
                  if (assets.encounterProtocols.isNotEmpty)
                    '遭遇プロトコル: ${assets.encounterProtocols.length}件',
                ],
                Colors.purple,
              ),
              const SizedBox(height: 8),
            ],
            // 系譜資産
            if (assets.lineageRecords.isNotEmpty ||
                assets.lineageBonuses.isNotEmpty) ...[
              _buildAssetCategory(
                theme,
                '系譜資産',
                [
                  if (assets.lineageRecords.isNotEmpty)
                    '系譜記録: ${assets.lineageRecords.length}件',
                  if (assets.lineageBonuses.isNotEmpty)
                    '系譜ボーナス: ${assets.lineageBonuses.length}種族',
                ],
                Colors.amber,
              ),
            ],
            if (assets.breedingRecipes.isEmpty &&
                assets.enemyEncyclopedia.isEmpty &&
                assets.encounterBranchConditions.isEmpty &&
                assets.consultationOfficeRumors.isEmpty &&
                assets.covenantClauses.isEmpty &&
                assets.bondActions.isEmpty &&
                assets.encounterProtocols.isEmpty &&
                assets.lineageRecords.isEmpty &&
                assets.lineageBonuses.isEmpty)
              Text(
                '継承された資産はありません',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCategory(
    ThemeData theme,
    String category,
    List<String> items,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNextActions(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '次の行動',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomButton(
                  text: '次世代の準備（配合）',
                  onPressed: () {
                    context.go('/production');
                  },
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                ),
                CustomButton(
                  text: '相談所へ',
                  onPressed: () {
                    context.go('/discover');
                  },
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                ),
                CustomButton(
                  text: '再遠征',
                  onPressed: () {
                    // 遠征をリセットして再開
                    ref.read(appStateProvider.notifier).resetDungeonExploration();
                    context.go('/dungeon');
                  },
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                ),
                CustomButton(
                  text: 'ホームへ',
                  onPressed: () {
                    context.go('/');
                  },
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEndReasonLabel(ExpeditionEndReason reason) {
    switch (reason) {
      case ExpeditionEndReason.retreat:
        return '撤退';
      case ExpeditionEndReason.defeat:
        return '全滅';
      case ExpeditionEndReason.goalAchieved:
        return '目標達成';
      case ExpeditionEndReason.sealRepaired:
        return '楔修復完了';
    }
  }

  MaterialColor _getEndReasonColor(ExpeditionEndReason reason) {
    switch (reason) {
      case ExpeditionEndReason.retreat:
        return Colors.orange;
      case ExpeditionEndReason.defeat:
        return Colors.red;
      case ExpeditionEndReason.goalAchieved:
        return Colors.green;
      case ExpeditionEndReason.sealRepaired:
        return Colors.blue;
    }
  }

  // モックの遠征リザルトを作成（実際の実装では、stateから取得）
  ExpeditionResult _createMockResult(dynamic state) {
    return ExpeditionResult(
      id: 'expedition_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      endedAt: DateTime.now(),
      endReason: ExpeditionEndReason.retreat,
      reachedFloor: state.expeditionState.currentFloor,
      goal: state.expeditionState.currentGoal,
      goalAchieved: state.expeditionState.currentGoal?.isAchieved ?? false,
      carriedAssets: CarriedAssets(
        monsters: [],
        resources: {'素材': 5, '結晶': 3},
        knowledge: ['配合レシピ1', '敵情報1'],
        choices: ['契約条項1'],
        lineageAssets: [],
      ),
      lostAssets: LostAssets(
        monsters: [],
        resources: {},
        temporaryBuffs: [],
      ),
      inheritedAssets: InheritedAssets(
        breedingRecipes: [],
        enemyEncyclopedia: [],
        encounterBranchConditions: [],
        consultationOfficeRumors: [],
        covenantClauses: [],
        bondActions: [],
        encounterProtocols: [],
        lineageRecords: [],
        lineageBonuses: {},
      ),
    );
  }
}

