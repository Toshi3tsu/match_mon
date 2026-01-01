import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../models/monster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
    final recentCollaborations = filteredCollaborations.take(3).toList();
    final recentProduction = state.productionHistory.take(3).toList();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ホーム',
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
              child: isDesktop
                  ? _buildDesktopLayout(
                      context,
                      state,
                      theme,
                      ref,
                      isMobile,
                      isTablet,
                      recentCollaborations,
                      recentProduction,
                    )
                  : _buildMobileLayout(
                      context,
                      state,
                      theme,
                      ref,
                      isMobile,
                      isTablet,
                      recentCollaborations,
                      recentProduction,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
    List recentCollaborations,
    List recentProduction,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左カラム（自キャラクター + 状態）
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlayerCharacterCard(
                context,
                state,
                theme,
                isMobile,
                isTablet,
                true, // isDesktop
              ),
              const SizedBox(height: 12),
              _buildUserStateCard(context, state, theme, isMobile, isTablet),
              const SizedBox(height: 12),
              _buildPersistentAssetsCard(context, state, theme, isMobile, isTablet),
              const SizedBox(height: 12),
              _buildDungeonExplorationCard(context, state, theme, ref, isMobile, isTablet),
              const SizedBox(height: 12),
              if (state.userState.targetSpecies != null)
                _buildTargetCard(context, state, theme, isMobile, isTablet),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 右カラム（マッチング + 交配結果）
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (recentCollaborations.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  theme,
                  '直近のマッチング',
                  () => context.go('/collaborations'),
                ),
                const SizedBox(height: 8),
                _buildHorizontalList(
                  context,
                  recentCollaborations,
                  (collab) => collab.partner,
                  isMobile,
                  isTablet,
                  true, // isDesktop
                ),
                const SizedBox(height: 16),
              ],
              if (recentProduction.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  theme,
                  '直近の交配結果',
                  () => context.go('/production'),
                ),
                const SizedBox(height: 8),
                _buildHorizontalList(
                  context,
                  recentProduction,
                  (prod) => prod.child,
                  isMobile,
                  isTablet,
                  true, // isDesktop
                ),
              ],
              if (state.collaborations.isEmpty && state.productionHistory.isEmpty)
                _buildEmptyState(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
    List recentCollaborations,
    List recentProduction,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlayerCharacterCard(
          context,
          state,
          theme,
          isMobile,
          isTablet,
          false, // isDesktop
        ),
        const SizedBox(height: 12),
        _buildUserStateCard(context, state, theme, isMobile, isTablet),
        const SizedBox(height: 12),
        _buildPersistentAssetsCard(context, state, theme, isMobile, isTablet),
        const SizedBox(height: 12),
        _buildDungeonExplorationCard(context, state, theme, ref, isMobile, isTablet),
        const SizedBox(height: 12),
        if (state.userState.targetSpecies != null) ...[
          _buildTargetCard(context, state, theme, isMobile, isTablet),
          const SizedBox(height: 12),
        ],
        if (recentCollaborations.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            theme,
            '直近のマッチング',
            () => context.go('/collaborations'),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(
            context,
            recentCollaborations,
            (collab) => collab.partner,
            isMobile,
            isTablet,
            false, // isDesktop
          ),
          const SizedBox(height: 12),
        ],
        if (recentProduction.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            theme,
            '直近の交配結果',
            () => context.go('/history'),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(
            context,
            recentProduction,
            (prod) => prod.child,
            isMobile,
            isTablet,
            false, // isDesktop
          ),
        ],
        if (state.collaborations.isEmpty && state.productionHistory.isEmpty)
          _buildEmptyState(context, theme),
      ],
    );
  }

  Widget _buildPlayerCharacterCard(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Card(
      elevation: 4,
      color: state.playerCharacter != null 
          ? Colors.blue.shade50 
          : Colors.grey.shade100,
      child: InkWell(
        onTap: state.playerCharacter != null 
            ? () => context.go('/player-character')
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 14 : 16),
          child: state.playerCharacter == null
              ? _buildNoCharacterState(context, theme, isMobile)
              : isDesktop
                  ? _buildCharacterHorizontal(
                      context,
                      state.playerCharacter!,
                      theme,
                    )
                  : _buildCharacterVertical(
                      context,
                      state.playerCharacter!,
                      theme,
                      isMobile,
                    ),
        ),
      ),
    );
  }

  Widget _buildCharacterHorizontal(
    BuildContext context,
    Monster monster,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildCharacterImage(monster, theme, 200),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildCharacterInfo(monster, theme, context),
        ),
      ],
    );
  }

  Widget _buildCharacterVertical(
    BuildContext context,
    Monster monster,
    ThemeData theme,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: isMobile ? 20 : 24,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '自キャラクター',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.blue.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        MonsterCard(
          monster: monster,
          showDetails: !isMobile,
          onTap: () => context.go('/player-character'),
        ),
      ],
    );
  }

  Widget _buildCharacterImage(Monster monster, ThemeData theme, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        width: double.infinity,
        color: theme.colorScheme.surfaceVariant,
        child: monster.image != null
            ? Builder(
                builder: (context) {
                  String assetPath = monster.image!;
                  if (kIsWeb && assetPath.startsWith('assets/')) {
                    assetPath = assetPath.substring(7);
                  }
                  return Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : Container(
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCharacterInfo(Monster monster, ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monster.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${monster.species} / ${monster.rank}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.blue.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          monster.profile,
          style: theme.textTheme.bodyMedium,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: monster.tags
              .map((tag) => TagWidget(label: tag))
              .toList(),
        ),
        const SizedBox(height: 12),
        Text(
          "スキル:",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: monster.skills.take(5).map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoCharacterState(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Column(
      children: [
        Icon(
          Icons.person_outline,
          size: isMobile ? 40 : 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          '自キャラクター未所持',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '交配で新しい個体を獲得すると、\n自キャラクターになります',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/production'),
          icon: const Icon(Icons.science, size: 18),
          label: const Text('交配プランナーへ'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserStateCard(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '現在の状態',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final statGridWidth = constraints.maxWidth;
                int crossAxisCount;
                if (statGridWidth < 300) {
                  crossAxisCount = 2;
                } else if (statGridWidth < 500) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 4;
                }
                
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: crossAxisCount == 2 ? 2.8 : 3.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 12,
                  children: [
                    _StatItem(
                      label: 'いいね残量',
                      value: state.userState.likesRemaining.toString(),
                    ),
                    _StatItem(
                      label: '素材数',
                      value: '${state.inventory.length}',
                    ),
                    _StatItem(
                      label: '交配回数',
                      value: state.userState.breedingCount.toString(),
                    ),
                    _StatItem(
                      label: 'マッチング数',
                      value: state.collaborations.length.toString(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
  ) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '目標',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '目標種族: ${state.userState.targetSpecies}'
              '${state.userState.targetTags != null && state.userState.targetTags!.isNotEmpty ? " (タグ: ${state.userState.targetTags!.join(", ")})" : ""}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomButton(
                  text: '探すへ',
                  onPressed: () => context.go('/discover'),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.small,
                ),
                CustomButton(
                  text: '交配へ',
                  onPressed: () => context.go('/production'),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('すべて見る', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    List items,
    Monster Function(dynamic) monsterExtractor,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardWidth = isMobile ? 220.0 : isTablet ? 260.0 : 300.0;
    // カードの高さは幅に基づいて計算（画像が正方形 + パディング + テキスト部分）
    final imageHeight = cardWidth;
    final padding = (kIsWeb ? 8.0 : 12.0) * 2; // 上下のパディング
    final textHeight = isMobile ? 90.0 : isTablet ? 95.0 : 100.0; // テキスト部分の推定高さ（余裕を持たせる）
    final cardHeight = imageHeight + padding + textHeight;
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: cardHeight,
                ),
                child: ClipRect(
                  child: MonsterCard(
                    monster: monsterExtractor(items[index]),
                    imageFirst: true,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              'まずは「探す」で候補を見つけましょう',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '探すを始める',
              onPressed: () => context.go('/discover'),
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersistentAssetsCard(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
  ) {
    final assets = state.persistentAssets;
    final knowledge = assets.knowledge;
    final institution = assets.institution;
    final lineageCore = assets.lineageCore;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '永続資産',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/discover'),
                  icon: const Icon(Icons.business, size: 16),
                  label: const Text('相談所へ'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 知識（情報の継承）
            _buildAssetRow(
              context,
              theme,
              '知識',
              '${knowledge.breedingRecipes.length}レシピ / ${knowledge.discoveredPatterns.length}パターン / ${knowledge.enemyEncyclopedia.length}敵',
              Colors.orange,
              Icons.lightbulb,
            ),
            const SizedBox(height: 8),
            // 選択肢（手段の継承）
            _buildAssetRow(
              context,
              theme,
              '選択肢',
              'ランク${institution.consultationOfficeRank} / 契約枠${institution.contractSlots} / 行動${assets.choices.unlockedBondActions.length}個',
              Colors.blue,
              Icons.business,
            ),
            const SizedBox(height: 8),
            // 系譜資産（配合の継承）
            _buildAssetRow(
              context,
              theme,
              '系譜資産',
              '継承枠${lineageCore.inheritanceSlots} / 記録${lineageCore.lineageRecords.length}件 / 特性${assets.lineageAssets.unlockedTraitSlots.length}個',
              Colors.purple,
              Icons.account_tree,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDungeonExplorationCard(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final explorationState = state.dungeonExplorationState;
    final isExploring = explorationState.currentNodeId != null || 
                        explorationState.visitedNodeIds.isNotEmpty;
    
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.explore,
                      size: isMobile ? 20 : 24,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '深層ダンジョン探索',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
                if (isExploring)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '探索中',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'はじまりのダンジョン',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '深層ダンジョンへの入口。5階層の構造を持つ。最深部には守護者が待ち構えている。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (isExploring) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '訪問済みノード: ${explorationState.visitedNodeIds.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: isExploring ? '探索を続ける' : '探索を開始',
                    onPressed: () {
                      if (!isExploring) {
                        ref.read(appStateProvider.notifier).startDungeonExploration();
                      }
                      context.go('/dungeon');
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ),
                if (isExploring) ...[
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'リセット',
                    onPressed: () {
                      ref.read(appStateProvider.notifier).resetDungeonExploration();
                    },
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.medium,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
