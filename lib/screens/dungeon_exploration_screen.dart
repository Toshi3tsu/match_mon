import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_button.dart';
import '../models/dungeon.dart';

class DungeonExplorationScreen extends ConsumerWidget {
  const DungeonExplorationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final explorationState = state.dungeonExplorationState;
    final currentNode = explorationState.getCurrentNode();

    return Scaffold(
      appBar: const CustomAppBar(
        title: '深層ダンジョン探索',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 1200;
            final isDesktop = screenWidth >= 1200;

            return Column(
              children: [
                // HUD（常時表示）
                _buildHUD(context, theme, explorationState.hud, isMobile),
                const Divider(height: 1),
                // メインコンテンツ
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : isTablet ? 12 : 16,
                      vertical: isMobile ? 8 : 12,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1600 : double.infinity,
                      ),
                      child: currentNode == null
                          ? _buildNodeMap(
                              context,
                              theme,
                              explorationState,
                              ref,
                              isMobile,
                              isTablet,
                            )
                          : explorationState.isInRoom
                              ? _buildRoomView(
                                  context,
                                  theme,
                                  currentNode,
                                  explorationState,
                                  ref,
                                  isMobile,
                                  isTablet,
                                )
                              : _buildNodeMap(
                                  context,
                                  theme,
                                  explorationState,
                                  ref,
                                  isMobile,
                                  isTablet,
                                ),
                    ),
                  ),
                ),
                // 撤退ボタン（常時表示）
                _buildRetreatButton(context, theme, ref, isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  // HUD（生存資源、継続リスク、持ち帰り資産）
  Widget _buildHUD(
    BuildContext context,
    ThemeData theme,
    ExplorationHUD hud,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      color: Colors.grey.shade800.withOpacity(0.9),
      child: Row(
        children: [
          // 生存資源
          Expanded(
            child: _buildResourceSection(
              context,
              theme,
              '生存資源',
              [
                _buildStatRow('HP', '${hud.hp} / ${hud.maxHp}'),
                _buildStatRow('回復回数', hud.recoveryCount.toString()),
              ],
              Colors.green,
              isMobile,
            ),
          ),
          const SizedBox(width: 8),
          // 継続リスク
          Expanded(
            child: _buildResourceSection(
              context,
              theme,
              '継続リスク',
              [
                _buildStatRow('ストレス', '${hud.stress} / ${hud.maxStress}'),
              ],
              Colors.red,
              isMobile,
            ),
          ),
          const SizedBox(width: 8),
          // 持ち帰り資産
          Expanded(
            child: _buildResourceSection(
              context,
              theme,
              '持ち帰り資産',
              [
                _buildStatRow('確定', _formatAssets(hud.securedAssets)),
                _buildStatRow('未確定', _formatAssets(hud.unsecuredAssets)),
              ],
              Colors.blue,
              isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection(
    BuildContext context,
    ThemeData theme,
    String title,
    List<Widget> children,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAssets(Map<String, int> assets) {
    if (assets.isEmpty) return 'なし';
    return assets.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  // 分岐ノードマップ
  Widget _buildNodeMap(
    BuildContext context,
    ThemeData theme,
    DungeonExplorationState state,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final currentNode = state.getCurrentNode();
    final nextNodes = state.getNextNodes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentNode != null) ...[
          // 現在のノード情報
          _buildCurrentNodeCard(
            context,
            theme,
            currentNode,
            isMobile,
            isTablet,
          ),
          const SizedBox(height: 16),
        ],
        // 次のノード選択
        if (nextNodes.isNotEmpty) ...[
          Text(
            '次のノードを選択',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: nextNodes
                .map((node) => _buildNodeCard(
                      context,
                      theme,
                      node,
                      () => _enterNode(context, ref, node.id),
                      isMobile,
                      isTablet,
                    ))
                .toList(),
          ),
        ] else if (currentNode == null) ...[
          // 開始ノードがない場合（探索開始前）
          // 開始ノード（'start'）を直接表示
          if (state.nodes.containsKey('start')) ...[
            Text(
              '探索を開始',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildNodeCard(
              context,
              theme,
              state.nodes['start']!,
              () => _startExploration(context, ref),
              isMobile,
              isTablet,
            ),
          ] else ...[
            // 開始ノードが見つからない場合
            Center(
              child: Column(
                children: [
                  const Icon(Icons.explore, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '探索を開始する準備ができています',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: '探索を開始',
                    onPressed: () => _startExploration(context, ref),
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCurrentNodeCard(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 8,
      color: Colors.grey.shade800.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNodeTypeIcon(node.type),
                  color: _getNodeTypeColor(node.type),
                  size: isMobile ? 24 : isTablet ? 28 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: (isMobile
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getNodeTypeLabel(node.type),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDangerLevelBadge(theme, node.dangerLevel),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            if (node.boss != null) ...[
              const SizedBox(height: 16),
              _buildBossPreview(context, theme, node.boss!, isMobile, isTablet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNodeCard(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    VoidCallback onTap,
    bool isMobile,
    bool isTablet,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        color: Colors.grey.shade800.withOpacity(0.9),
        child: Container(
          width: isMobile ? double.infinity : 200,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getNodeTypeIcon(node.type),
                    color: _getNodeTypeColor(node.type),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildDangerLevelBadge(theme, node.dangerLevel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getNodeTypeLabel(node.type),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getRewardCategoryLabel(node.rewardCategory),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerLevelBadge(ThemeData theme, DangerLevel level) {
    Color color;
    String label;
    switch (level) {
      case DangerLevel.low:
        color = Colors.green;
        label = '低';
        break;
      case DangerLevel.medium:
        color = Colors.orange;
        label = '中';
        break;
      case DangerLevel.high:
        color = Colors.red;
        label = '高';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getNodeTypeIcon(NodeType type) {
    switch (type) {
      case NodeType.combat:
        return Icons.casino;
      case NodeType.event:
        return Icons.auto_stories;
      case NodeType.rest:
        return Icons.bedtime;
      case NodeType.contract:
        return Icons.handshake;
      case NodeType.refinement:
        return Icons.build;
    }
  }

  Color _getNodeTypeColor(NodeType type) {
    switch (type) {
      case NodeType.combat:
        return Colors.red;
      case NodeType.event:
        return Colors.purple;
      case NodeType.rest:
        return Colors.green;
      case NodeType.contract:
        return Colors.blue;
      case NodeType.refinement:
        return Colors.orange;
    }
  }

  String _getNodeTypeLabel(NodeType type) {
    switch (type) {
      case NodeType.combat:
        return '戦闘';
      case NodeType.event:
        return 'イベント';
      case NodeType.rest:
        return '休息';
      case NodeType.contract:
        return '契約';
      case NodeType.refinement:
        return '精錬';
    }
  }

  String _getRewardCategoryLabel(RewardCategory category) {
    switch (category) {
      case RewardCategory.resource:
        return '資源';
      case RewardCategory.information:
        return '情報';
      case RewardCategory.lineageMaterial:
        return '系譜素材';
      case RewardCategory.contractClause:
        return '契約条項';
    }
  }

  // 部屋ビュー
  Widget _buildRoomView(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    DungeonExplorationState state,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentNodeCard(context, theme, node, isMobile, isTablet),
        const SizedBox(height: 16),
        // 部屋の内容に応じた処理
        _buildRoomContent(context, theme, node, ref, isMobile, isTablet),
      ],
    );
  }

  Widget _buildRoomContent(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    switch (node.type) {
      case NodeType.combat:
        return _buildCombatRoom(context, theme, node, ref, isMobile, isTablet);
      case NodeType.event:
        return _buildEventRoom(context, theme, node, ref, isMobile, isTablet);
      case NodeType.rest:
        return _buildRestRoom(context, theme, node, ref, isMobile, isTablet);
      case NodeType.contract:
        return _buildContractRoom(context, theme, node, ref, isMobile, isTablet);
      case NodeType.refinement:
        return _buildRefinementRoom(context, theme, node, ref, isMobile, isTablet);
    }
  }

  Widget _buildCombatRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    if (node.boss == null) {
      // ボスがいない通常戦闘
      return Card(
        elevation: 8,
        color: Colors.red.shade900.withOpacity(0.8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '戦闘',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                node.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade800.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '敵との遭遇',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '敵との戦闘が発生します。自動戦闘で進行します。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '戦闘を開始',
                onPressed: () => _completeCombatNode(context, ref, node, true),
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      );
    }
    return _buildBossCard(context, theme, node.boss!, ref, node, isMobile, isTablet);
  }

  Widget _buildBossCard(
    BuildContext context,
    ThemeData theme,
    Boss boss,
    WidgetRef ref,
    DungeonNode node,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 8,
      color: Colors.red.shade900.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.red.shade200,
                  size: isMobile ? 24 : isTablet ? 28 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boss.name,
                        style: (isMobile
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${boss.species} / ${boss.rank}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              boss.profile,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: boss.tags
                  .map<Widget>((tag) => TagWidget(label: tag))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _buildStatusSection(context, theme, boss),
            if (boss.threatProfile.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '脅威プロファイル',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: boss.threatProfile.map<Widget>((threat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      threat,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(
              text: '戦闘開始',
              onPressed: () {
                // 簡易的な自動戦闘（常に勝利）
                _completeCombatNode(context, ref, node, true);
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBossPreview(
    BuildContext context,
    ThemeData theme,
    Boss boss,
    bool isMobile,
    bool isTablet,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.red.shade200, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boss.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${boss.species} / ${boss.rank}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    ThemeData theme,
    Boss boss,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステータス',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatRow('レベル', boss.level.toString()),
        const SizedBox(height: 4),
        _buildStatRow('HP', '${boss.hp} / ${boss.maxHp}'),
        const SizedBox(height: 4),
        _buildStatRow('攻撃', boss.attack.toString()),
        const SizedBox(height: 4),
        _buildStatRow('防御', boss.defense.toString()),
        const SizedBox(height: 4),
        _buildStatRow('速度', boss.speed.toString()),
      ],
    );
  }

  Widget _buildEventRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 8,
      color: Colors.purple.shade900.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'イベント',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '選択肢',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            // 簡易的な選択肢
            _buildEventChoice(
              context,
              theme,
              '調査する',
              '情報を獲得できるが、少しストレスが増える',
              () => _completeEventNode(context, ref, node, {
                'information': 1,
                'stress': 5,
              }),
            ),
            const SizedBox(height: 8),
            _buildEventChoice(
              context,
              theme,
              '慎重に進む',
              '安全だが、報酬は少ない',
              () => _completeEventNode(context, ref, node, {
                'resource': 1,
              }),
            ),
            const SizedBox(height: 8),
            _buildEventChoice(
              context,
              theme,
              '無視する',
              '何も起こらない',
              () => _completeEventNode(context, ref, node, {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventChoice(
    BuildContext context,
    ThemeData theme,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.purple.shade800.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final state = ref.watch(appStateProvider);
    final hud = state.dungeonExplorationState.hud;
    
    return Card(
      elevation: 8,
      color: Colors.green.shade900.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '休息',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            // 現在の状態
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade800.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在の状態',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('HP: ${hud.hp} / ${hud.maxHp}', style: const TextStyle(color: Colors.white)),
                  Text('ストレス: ${hud.stress} / ${hud.maxStress}', style: const TextStyle(color: Colors.white)),
                  Text('回復回数: ${hud.recoveryCount}', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 休息オプション
            if (hud.recoveryCount > 0) ...[
              CustomButton(
                text: '回復する（HP +30、回復回数 -1）',
                onPressed: () => _completeRestNode(context, ref, node, recoverHp: 30),
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 8),
            ],
            CustomButton(
              text: '休息する（ストレス -20）',
              onPressed: () => _completeRestNode(context, ref, node, reduceStress: 20),
              variant: ButtonVariant.secondary,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: '何もしない',
              onPressed: () => _completeRestNode(context, ref, node),
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 8,
      color: Colors.blue.shade900.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '契約遭遇',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade800.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.handshake, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '希少な個体との遭遇',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ダンジョン内で希少な個体と遭遇しました。交渉のチャンスです。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: '交渉する（契約条項を獲得）',
              onPressed: () => _completeContractNode(context, ref, node),
              variant: ButtonVariant.primary,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: '見送る',
              onPressed: () => _completeContractNode(context, ref, node, skip: true),
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefinementRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      elevation: 8,
      color: Colors.orange.shade900.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '精錬',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade800.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '精錬オプション',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '資源を変換・強化できます。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: '資源を精錬する（資源 +2）',
              onPressed: () => _completeRefinementNode(context, ref, node),
              variant: ButtonVariant.primary,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: '何もしない',
              onPressed: () => _completeRefinementNode(context, ref, node, skip: true),
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  // 撤退ボタン
  Widget _buildRetreatButton(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      color: Colors.grey.shade800.withOpacity(0.9),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: '撤退',
              onPressed: () => _showRetreatDialog(context, ref),
              variant: ButtonVariant.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showRetreatDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(appStateProvider);
    final hud = state.dungeonExplorationState.hud;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤退確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('撤退すると、以下の資産を持ち帰れます：'),
            const SizedBox(height: 8),
            Text('確定資産: ${_formatAssets(hud.securedAssets)}'),
            const SizedBox(height: 4),
            Text('未確定資産: ${_formatAssets(hud.unsecuredAssets)}'),
            const SizedBox(height: 16),
            const Text(
              '未確定資産は一部失われる可能性があります。',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retreat(context, ref);
            },
            child: const Text('撤退する'),
          ),
        ],
      ),
    );
  }

  void _startExploration(BuildContext context, WidgetRef ref) {
    // 開始ノード（'start'）に入る
    final state = ref.read(appStateProvider);
    final explorationState = state.dungeonExplorationState;
    
    // 'start'ノードが存在するか確認
    if (explorationState.nodes.containsKey('start')) {
      ref.read(appStateProvider.notifier).enterDungeonNode('start');
    } else {
      // 開始ノードがない場合は、最初のノードを探す
      if (explorationState.nodes.isNotEmpty) {
        final firstNodeId = explorationState.nodes.keys.first;
        ref.read(appStateProvider.notifier).enterDungeonNode(firstNodeId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('探索可能なノードが見つかりません。')),
        );
      }
    }
  }

  void _enterNode(BuildContext context, WidgetRef ref, String nodeId) {
    // ノードに入る処理
    ref.read(appStateProvider.notifier).enterDungeonNode(nodeId);
  }

  void _retreat(BuildContext context, WidgetRef ref) {
    // 撤退処理：遠征リザルト画面に遷移
    final state = ref.read(appStateProvider);
    final explorationState = state.dungeonExplorationState;
    
    // 遠征の階層を更新
    if (explorationState.currentNodeId != null) {
      // 現在のノードから階層を推定（実際の実装では、ノードから階層を取得）
      final currentFloor = explorationState.visitedNodeIds.length;
      ref.read(appStateProvider.notifier).updateExpeditionFloor(currentFloor);
    }
    
    // 探索をリセット
    ref.read(appStateProvider.notifier).resetDungeonExploration();
    
    // 遠征リザルト画面に遷移
    context.go('/dungeon/result');
  }

  // イベントノード完了
  void _completeEventNode(
    BuildContext context,
    WidgetRef ref,
    DungeonNode node,
    Map<String, int> rewards,
  ) {
    final state = ref.read(appStateProvider);
    final hud = state.dungeonExplorationState.hud;
    
    // HUDを更新
    var newHud = hud;
    if (rewards.containsKey('stress')) {
      newHud = newHud.copyWith(
        stress: (hud.stress + rewards['stress']!).clamp(0, hud.maxStress),
      );
    }
    
    // 資産を追加
    rewards.forEach((type, amount) {
      if (type != 'stress') {
        ref.read(appStateProvider.notifier).addSecuredAsset(type, amount);
      }
    });
    
    if (newHud != hud) {
      ref.read(appStateProvider.notifier).updateExplorationHUD(newHud);
    }
    
    // 部屋から出る
    ref.read(appStateProvider.notifier).exitRoom();
    
    // フィードバック
    final rewardText = rewards.entries
        .map((e) => '${_getRewardTypeLabel(e.key)}: ${e.value > 0 ? "+" : ""}${e.value}')
        .join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('獲得: $rewardText')),
    );
  }

  // 休息ノード完了
  void _completeRestNode(
    BuildContext context,
    WidgetRef ref,
    DungeonNode node, {
    int? recoverHp,
    int? reduceStress,
  }) {
    final state = ref.read(appStateProvider);
    final hud = state.dungeonExplorationState.hud;
    
    var newHp = hud.hp;
    var newStress = hud.stress;
    var newRecoveryCount = hud.recoveryCount;
    
    if (recoverHp != null && newRecoveryCount > 0) {
      newHp = (hud.hp + recoverHp).clamp(0, hud.maxHp);
      newRecoveryCount = hud.recoveryCount - 1;
    }
    
    if (reduceStress != null) {
      newStress = (hud.stress - reduceStress).clamp(0, hud.maxStress);
    }
    
    final newHud = hud.copyWith(
      hp: newHp,
      stress: newStress,
      recoveryCount: newRecoveryCount,
    );
    
    ref.read(appStateProvider.notifier).updateExplorationHUD(newHud);
    ref.read(appStateProvider.notifier).exitRoom();
    
    final changes = <String>[];
    if (recoverHp != null) changes.add('HP +$recoverHp');
    if (reduceStress != null) changes.add('ストレス -$reduceStress');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('休息完了: ${changes.join(", ")}')),
    );
  }

  // 契約ノード完了
  void _completeContractNode(
    BuildContext context,
    WidgetRef ref,
    DungeonNode node, {
    bool skip = false,
  }) {
    if (!skip) {
      ref.read(appStateProvider.notifier).addSecuredAsset('contractClause', 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('契約条項を獲得しました')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('見送りました')),
      );
    }
    
    ref.read(appStateProvider.notifier).exitRoom();
  }

  // 精錬ノード完了
  void _completeRefinementNode(
    BuildContext context,
    WidgetRef ref,
    DungeonNode node, {
    bool skip = false,
  }) {
    if (!skip) {
      ref.read(appStateProvider.notifier).addSecuredAsset('resource', 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('資源 +2 を獲得しました')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('何もしませんでした')),
      );
    }
    
    ref.read(appStateProvider.notifier).exitRoom();
  }

  // 戦闘ノード完了
  void _completeCombatNode(
    BuildContext context,
    WidgetRef ref,
    DungeonNode node,
    bool victory,
  ) {
    final state = ref.read(appStateProvider);
    final hud = state.dungeonExplorationState.hud;
    
    if (victory) {
      // 勝利時の報酬
      final rewardType = _getRewardCategoryAssetType(node.rewardCategory);
      ref.read(appStateProvider.notifier).addSecuredAsset(rewardType, 1);
      
      // HP減少（戦闘ダメージ）
      final damage = node.dangerLevel == DangerLevel.high ? 30 : 
                     node.dangerLevel == DangerLevel.medium ? 20 : 10;
      final newHp = (hud.hp - damage).clamp(0, hud.maxHp);
      final newHud = hud.copyWith(hp: newHp);
      ref.read(appStateProvider.notifier).updateExplorationHUD(newHud);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('勝利！${_getRewardCategoryLabel(node.rewardCategory)}を獲得（HP -$damage）')),
      );
    } else {
      // 敗北時は撤退
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('敗北しました...')),
      );
    }
    
    ref.read(appStateProvider.notifier).exitRoom();
  }

  String _getRewardTypeLabel(String type) {
    switch (type) {
      case 'information':
        return '情報';
      case 'resource':
        return '資源';
      case 'lineageMaterial':
        return '系譜素材';
      case 'contractClause':
        return '契約条項';
      default:
        return type;
    }
  }

  String _getRewardCategoryAssetType(RewardCategory category) {
    switch (category) {
      case RewardCategory.resource:
        return 'resource';
      case RewardCategory.information:
        return 'information';
      case RewardCategory.lineageMaterial:
        return 'lineageMaterial';
      case RewardCategory.contractClause:
        return 'contractClause';
    }
  }
}

