import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/contract_settings_dialog.dart';
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
      body: Stack(
        children: [
          // 背景画像
          if (explorationState.currentNodeId == null && explorationState.contractSettings == null)
            Positioned.fill(
              child: _buildBackgroundImage(context),
            )
          else
            Container(
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
            ),
          // メインコンテンツ
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isMobile = screenWidth < 600;
              final isTablet = screenWidth >= 600 && screenWidth < 1200;
              final isDesktop = screenWidth >= 1200;

              // 探索開始前（契約設定がない場合）はHUDと撤退ボタンを非表示
              if (explorationState.contractSettings == null && explorationState.currentNodeId == null) {
                return _buildNodeMap(
                  context,
                  theme,
                  explorationState,
                  ref,
                  isMobile,
                  isTablet,
                );
              }

              return Column(
                children: [
                  // HUD（常時表示）
                  _buildHUD(context, theme, explorationState.hud, explorationState.contractSettings, explorationState.history, ref, isMobile),
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
        ],
      ),
    );
  }

  // HUD（生存資源、継続リスク、持ち帰り資産）
  Widget _buildHUD(
    BuildContext context,
    ThemeData theme,
    ExplorationHUD hud,
    ContractSettings? contractSettings,
    ExplorationHistory history,
    WidgetRef ref,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      color: Colors.grey.shade800.withOpacity(0.9),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          // 契約設定と履歴ボタン
          Row(
            children: [
              if (contractSettings != null) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '契約設定',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade300,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '階層: ${_getTargetFloorLabel(contractSettings.targetFloor)} | '
                                'リスク: ${_getRiskToleranceLabel(contractSettings.riskTolerance)} | '
                                '目的: ${_getPriorityObjectiveLabel(contractSettings.priorityObjective)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade200,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(Icons.history, size: 20),
                tooltip: '探索履歴',
                onPressed: () => _showFullHistory(context, ref),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTargetFloorLabel(TargetFloor floor) {
    switch (floor) {
      case TargetFloor.middle:
        return '中層';
      case TargetFloor.deep:
        return '深層';
      case TargetFloor.deepest:
        return '最深部';
    }
  }

  String _getRiskToleranceLabel(RiskTolerance risk) {
    switch (risk) {
      case RiskTolerance.aggressive:
        return '積極的';
      case RiskTolerance.standard:
        return '標準';
      case RiskTolerance.cautious:
        return '慎重';
    }
  }

  String _getPriorityObjectiveLabel(PriorityObjective objective) {
    switch (objective) {
      case PriorityObjective.wedge:
        return '楔';
      case PriorityObjective.resource:
        return '資源';
      case PriorityObjective.lineageMaterial:
        return '系譜';
    }
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
        // 契約設定がある場合は手動選択を非表示（自動進行）
        if (state.contractSettings == null) ...[
          // 次のノード選択（契約設定がない場合のみ表示）
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
          ],
        ] else ...[
          // 契約設定がある場合：自動進行中の表示
          _buildAutoExplorationView(context, theme, state, ref, isMobile, isTablet),
        ],
        if (currentNode == null && state.contractSettings == null) ...[
          // 探索開始前：入口の選択画面
          _buildEntranceView(context, theme, ref, isMobile, isTablet),
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
                text: '自動戦闘を実行',
                onPressed: () {
                  // 自動戦闘を実行
                  ref.read(appStateProvider.notifier).executeAutoCombat(node.id);
                  // 戦闘履歴を表示
                  _showCombatHistory(context, ref);
                  // 部屋から出る
                  Future.delayed(const Duration(milliseconds: 500), () {
                    ref.read(appStateProvider.notifier).exitRoom();
                  });
                },
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
              text: '自動戦闘を実行',
              onPressed: () {
                // 自動戦闘を実行
                ref.read(appStateProvider.notifier).executeAutoCombat(node.id);
                // 戦闘履歴を表示
                _showCombatHistory(context, ref);
                // 部屋から出る
                Future.delayed(const Duration(milliseconds: 500), () {
                  ref.read(appStateProvider.notifier).exitRoom();
                });
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
    final state = ref.watch(appStateProvider);
    final explorationState = state.dungeonExplorationState;
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
            // 契約設定がある場合は手動選択を非表示（自動進行）
            if (explorationState.contractSettings == null) ...[
              _buildEventChoice(
                context,
                theme,
                '無視する',
                '何も起こらない',
                () => _completeEventNode(context, ref, node, {}),
              ),
            ] else ...[
              // 自動進行中：選択肢を非表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade800.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 12),
                    Text(
                      '契約に基づいて自動的に選択中...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
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
    final state = ref.watch(appStateProvider);
    final explorationState = state.dungeonExplorationState;
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
            // 契約設定がある場合は手動選択を非表示（自動進行）
            if (explorationState.contractSettings == null) ...[
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
            ] else ...[
              // 自動進行中：選択肢を非表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 12),
                    Text(
                      '契約に基づいて自動的に交渉中...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
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

  Widget _buildRefinementRoom(
    BuildContext context,
    ThemeData theme,
    DungeonNode node,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final state = ref.watch(appStateProvider);
    final explorationState = state.dungeonExplorationState;
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
            // 契約設定がある場合は手動選択を非表示（自動進行）
            if (explorationState.contractSettings == null) ...[
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
            ] else ...[
              // 自動進行中：選択肢を非表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 12),
                    Text(
                      '契約に基づいて自動的に精錬中...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
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

  void _startExploration(BuildContext context, WidgetRef ref) async {
    // 契約設定ダイアログを表示
    final state = ref.read(appStateProvider);
    final explorationState = state.dungeonExplorationState;
    
    final settings = await showDialog<ContractSettings>(
      context: context,
      builder: (context) => ContractSettingsDialog(
        initialSettings: explorationState.contractSettings,
      ),
    );

    if (settings == null) return; // キャンセルされた場合

    // 契約設定を保存
    ref.read(appStateProvider.notifier).setContractSettings(settings);

    // 自動探索を開始
    ref.read(appStateProvider.notifier).proceedAutoExploration();
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


  // 戦闘履歴を表示
  void _showCombatHistory(BuildContext context, WidgetRef ref) {
    final state = ref.read(appStateProvider);
    final history = state.dungeonExplorationState.history;
    final latestEntry = history.combatEntries.isNotEmpty
        ? history.combatEntries.last
        : null;

    if (latestEntry == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('戦闘結果'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                latestEntry.nodeName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(latestEntry.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    latestEntry.victory ? Icons.check_circle : Icons.cancel,
                    color: latestEntry.victory ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    latestEntry.victory ? '勝利' : '敗北',
                    style: TextStyle(
                      color: latestEntry.victory ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('受けたダメージ: ${latestEntry.damageTaken}'),
              if (latestEntry.rewards.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('獲得報酬:'),
                ...latestEntry.rewards.entries.map((e) => 
                  Text('  ${_getRewardTypeLabel(e.key)}: ${e.value}')
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFullHistory(context, ref);
            },
            child: const Text('全履歴を見る'),
          ),
        ],
      ),
    );
  }

  // 全戦闘履歴を表示
  void _showFullHistory(BuildContext context, WidgetRef ref) {
    final state = ref.read(appStateProvider);
    final history = state.dungeonExplorationState.history;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('探索履歴'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('現在の階層: ${history.currentFloor}'),
                Text('確保した楔: ${history.wedgesSecured}'),
                const SizedBox(height: 16),
                const Text(
                  '戦闘履歴',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (history.combatEntries.isEmpty)
                  const Text('戦闘履歴はありません。')
                else
                  ...history.combatEntries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                entry.victory ? Icons.check_circle : Icons.cancel,
                                color: entry.victory ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.nodeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (entry.rewards.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '報酬: ${entry.rewards.entries.map((e) => '${_getRewardTypeLabel(e.key)} ${e.value}').join(', ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // 自動探索中の表示
  Widget _buildAutoExplorationView(
    BuildContext context,
    ThemeData theme,
    DungeonExplorationState state,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final currentNode = state.getCurrentNode();
    final history = state.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 現在の状態
        if (currentNode != null) ...[
          Card(
            elevation: 8,
            color: Colors.grey.shade800.withOpacity(0.9),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '自動探索中: ${currentNode.name}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '契約設定に基づいて自動的に進行しています...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // 探索履歴の表示
        if (history.combatEntries.isNotEmpty || history.eventEntries.isNotEmpty) ...[
          Text(
            '探索履歴',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...history.combatEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: Colors.grey.shade800.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      entry.victory ? Icons.check_circle : Icons.cancel,
                      color: entry.victory ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.nodeName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            entry.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          ...history.eventEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: Colors.grey.shade800.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ],
    );
  }

  // 背景画像（GIFアニメーション）を表示（Web対応）
  Widget _buildBackgroundImage(BuildContext context) {
    String assetPath = 'assets/field/Dungeon.gif';
    // Flutter Webでは、pubspec.yamlでassets/と指定しているため、
    // コード内のパス（assets/...）からassets/プレフィックスを削除
    if (kIsWeb) {
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring(7); // "assets/" の7文字を削除
      }
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // アセットが見つからない場合のフォールバック
        return Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '背景画像を読み込めませんでした',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 入口の選択画面（背景画像上に半透明オーバーレイ）
  Widget _buildEntranceView(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    return Center(
      child: Container(
        width: isMobile ? double.infinity : 600,
        margin: EdgeInsets.all(isMobile ? 16 : 24),
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // 半透明の黒背景
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.amber.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              '入口までしか入れない',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '深層ダンジョンは瘴気で地形も因果も揺らいでいる。\n人間は奥まで耐えられない。',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '使役獣に契約を交わして代理遠征させますか？',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.amber.shade200,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: '戻る',
                  onPressed: () => context.pop(),
                  variant: ButtonVariant.secondary,
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: '契約を交わす',
                  onPressed: () => _startExploration(context, ref),
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

