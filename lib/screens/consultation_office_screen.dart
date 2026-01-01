import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/monster_card.dart';

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
                  // 目標選択セクション
                  _buildGoalSection(context, state, theme, ref, isMobile),
                  const SizedBox(height: 16),

                  // 手持ちの整備セクション
                  _buildInventorySection(context, state, theme, isMobile),
                  const SizedBox(height: 16),

                  // マッチング準備セクション
                  _buildMatchingSection(context, state, theme, isMobile),
                  const SizedBox(height: 16),

                  // 相談所の成長とメタ進行セクション
                  _buildInstitutionSection(context, state, theme, isMobile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalSection(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '目標選択',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 公共指標（世界の存続に効く評価）
            _buildGoalCard(
              context,
              theme,
              '公共指標',
              '深層の楔を打ち直す',
              '封印維持：封印装置の維持率を上げる\n深層突破：より深い層へ到達する\n汚染浄化：瘴気の後退率を上げる',
              Colors.deepPurple,
            ),
            const SizedBox(height: 8),
            // 個人指標（系譜研究）
            _buildGoalCard(
              context,
              theme,
              '個人指標',
              '系譜研究・法則解析',
              '系譜研究：特定の系譜を発見・完成させる\n法則解析：配合の法則や事故条件を解明する',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            // その他の目標
            _buildGoalCard(
              context,
              theme,
              'その他の目標',
              '資源回収・素材確保',
              '資源回収：必要な素材を集める\n特定素材確保：目標ビルドに必要な素材を集める',
              Colors.green,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // 目標設定ダイアログを表示
                    _showGoalDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('目標を設定'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // ダンジョン探索を開始
                    ref.read(appStateProvider.notifier).startDungeonExploration();
                    context.go('/dungeon');
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('探索を開始'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String mainGoal,
    String description,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mainGoal,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '手持ちの整備',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 自キャラクター
            if (state.playerCharacter != null) ...[
              Text(
                '自キャラクター',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              MonsterCard(monster: state.playerCharacter!),
              const SizedBox(height: 16),
            ],
            // 編成
            Text(
              '編成',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.inventory.isEmpty)
              Text(
                '所持個体がありません',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              SizedBox(
                height: isMobile ? 400 : 500,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: state.inventory.length,
                  itemBuilder: (context, index) {
                    return MonsterCard(
                      monster: state.inventory[index],
                      imageFirst: false,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/inventory');
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('所持一覧を開く'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingSection(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'マッチング準備（相談所の案件）',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '相談所は個体そのものを売るのではなく「系譜の型」「継承枠の期待値」「事故率保証」「契約条件」を商品として提示します。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '相談所の商品',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 系譜の型：配合結果の種族が決定論で予測可能\n'
                    '• 継承枠の期待値：次世代に継承できる枠の平均値\n'
                    '• 事故率保証：配合時の事故率の低さ\n'
                    '• 契約条件：マッチ後のボンド行動や盟約条項',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    theme,
                    '相談所ランク',
                    '${state.persistentAssets.institution.consultationOfficeRank}',
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
                    '${state.persistentAssets.institution.contractSlots}',
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
                    '${state.persistentAssets.institution.recommendationSlots}',
                    Icons.recommend,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/discover');
              },
              icon: const Icon(Icons.search),
              label: const Text('候補を探す'),
            ),
          ],
        ),
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

  Widget _buildInstitutionSection(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
  ) {
    final institution = state.persistentAssets.institution;
    final knowledge = state.persistentAssets.knowledge;
    final lineageCore = state.persistentAssets.lineageCore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '相談所の成長とメタ進行',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 知識（情報の継承）
            _buildAssetCard(
              context,
              theme,
              '知識（情報の継承）',
              [
                '配合レシピ: ${knowledge.breedingRecipes.length}件',
                '候補確率情報: ${knowledge.candidateProbabilities.length}件',
                '事故条件: ${knowledge.accidentConditions.length}件',
                '発見パターン: ${knowledge.discoveredPatterns.length}件',
                '敵図鑑: ${knowledge.enemyEncyclopedia.length}件',
                '遭遇分岐条件: ${knowledge.encounterBranchConditions.length}件',
                '相談所の噂: ${knowledge.consultationOfficeRumors.length}件',
              ],
              Icons.lightbulb,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            // 選択肢（手段の継承）
            _buildAssetCard(
              context,
              theme,
              '選択肢（手段の継承）',
              [
                '相談所ランク: ${institution.consultationOfficeRank}',
                '候補提示の質: ${(institution.candidateQualityBonus * 100).toStringAsFixed(0)}%',
                '希少遭遇率: ${(institution.rareEncounterRate * 100).toStringAsFixed(0)}%',
                '固定枠ボーナス: +${institution.fixedSlotBonus}',
                '契約条項: ${state.persistentAssets.choices.availableCovenantClauses.length}個',
                'ボンド行動: ${state.persistentAssets.choices.unlockedBondActions.length}個',
                '遭遇プロトコル: ${state.persistentAssets.choices.unlockedEncounterProtocols.length}個',
              ],
              Icons.business,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            // 系譜資産（配合の継承）
            _buildAssetCard(
              context,
              theme,
              '系譜資産（配合の継承）',
              [
                '継承枠期待値: ${lineageCore.inheritanceSlots}',
                'スキルスロット: ${lineageCore.skillSlots}',
                '特性スロット: ${state.persistentAssets.lineageAssets.unlockedTraitSlots.length}個',
                '事故率改善: ${(state.persistentAssets.lineageAssets.accidentRateImprovement * 100).toStringAsFixed(0)}%',
                '候補スキル幅: ${state.persistentAssets.lineageAssets.candidateSkillWidth}',
                '初期タグ: ${lineageCore.initialTags.length}個',
                '系譜記録: ${lineageCore.lineageRecords.length}件',
              ],
              Icons.account_tree,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    ThemeData theme,
    String title,
    List<String> items,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall,
                ),
              )),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を設定'),
        content: const Text('目標設定機能は今後実装予定です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

