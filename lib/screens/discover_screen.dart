import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';
import '../services/production_service.dart';
import '../models/production.dart' as production;
import '../models/breeding.dart';
import '../data/mock_data.dart';
import 'monster_detail_dialog.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  double _dragPosition = 0;
  bool _showRecommended = false;
  int _selectedTab = 0; // 0: マッチング準備, 1: 目標・整備, 2: 相談所の成長

  @override
  void initState() {
    super.initState();
    // キーボード操作のリスナーを設定
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }


  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final state = ref.read(appStateProvider);
      if (state.currentDiscoverIndex >= state.discoverQueue.length) return;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey.keyLabel == 'a' ||
          event.logicalKey.keyLabel == 'A') {
        _handleSkip();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey.keyLabel == 'd' ||
          event.logicalKey.keyLabel == 'D') {
        _handleLike();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _showDetail();
      }
    }
  }

  void _handleLike() {
    final state = ref.read(appStateProvider);
    if (state.userState.likesRemaining <= 0) return;

    ref.read(appStateProvider.notifier).likeCurrent();
    setState(() {
      _dragPosition = 0;
    });
  }

  void _handleSkip() {
    ref.read(appStateProvider.notifier).skipCurrent();
    setState(() {
      _dragPosition = 0;
    });
  }

  void _handleBookmark() {
    ref.read(appStateProvider.notifier).bookmarkCurrent();
    setState(() {
      _dragPosition = 0;
    });
  }

  void _showDetail() {
    final state = ref.read(appStateProvider);
    if (state.currentDiscoverIndex >= state.discoverQueue.length) return;

    final currentMonster = state.discoverQueue[state.currentDiscoverIndex];
    final inventory = state.inventory;
    
    Compatibility? compatibility;
    if (inventory.isNotEmpty) {
      final prodCompatibility = ProductionService.calculateCompatibility(
        currentMonster,
        inventory[0],
      );
      // production.dartのCompatibilityをbreeding.dartのCompatibilityに変換
      CompatibilityLevel level;
      switch (prodCompatibility.level) {
        case production.CompatibilityLevel.high:
          level = CompatibilityLevel.high;
          break;
        case production.CompatibilityLevel.medium:
          level = CompatibilityLevel.medium;
          break;
        case production.CompatibilityLevel.low:
          level = CompatibilityLevel.low;
          break;
      }
      compatibility = Compatibility(
        level: level,
        reason: prodCompatibility.reason,
        matchingTags: prodCompatibility.matchingTags,
        complementaryTags: prodCompatibility.complementaryTags,
        conflictingTags: prodCompatibility.conflictingTags,
      );
    }

    // 既にいいね済みかチェック
    final isLiked = state.collaborations.any((c) => c.partnerId == currentMonster.id);
    final canLike = state.userState.likesRemaining > 0 && !isLiked;

    showDialog(
      context: context,
      builder: (context) => MonsterDetailDialog(
        monster: currentMonster,
        compatibility: compatibility,
        onLike: _handleLike,
        onSkip: _handleSkip,
        onBookmark: _handleBookmark,
        canLike: canLike,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '相談所',
      ),
      body: _showRecommended
          ? _buildRecommendedTab(state, theme)
          : _buildTabbedView(state, theme),
    );
  }

  Widget _buildTabbedView(AppState state, ThemeData theme) {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTab.clamp(0, 1),
      child: Column(
        children: [
          // タブバー
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: TabBar(
              tabs: const [
                Tab(text: 'マッチング準備', icon: Icon(Icons.search)),
                Tab(text: '相談所の成長', icon: Icon(Icons.trending_up)),
              ],
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
          ),
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              children: [
                _buildSearchTab(state, theme, true), // マッチング準備
                _buildInstitutionGrowthTab(state, theme), // 相談所の成長
              ],
            ),
          ),
        ],
      ),
    );
  }

  // オススメタブ（スワイプ機能）
  Widget _buildRecommendedTab(AppState state, ThemeData theme) {
    return Column(
      children: [
        // 戻るボタン
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CustomButton(
                text: '探すに戻る',
                onPressed: () {
                  setState(() {
                    _showRecommended = false;
                  });
                },
                variant: ButtonVariant.secondary,
                icon: const Icon(Icons.arrow_back, size: 20),
              ),
            ],
          ),
        ),
        // オススメコンテンツ
        Expanded(
          child: _buildRecommendedContent(state, theme),
        ),
      ],
    );
  }

  Widget _buildRecommendedContent(AppState state, ThemeData theme) {
    if (state.currentDiscoverIndex >= state.discoverQueue.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'これ以上候補がありません',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'リロード',
              onPressed: () {
                ref.read(appStateProvider.notifier).setDiscoverQueue(
                      List.from(state.discoverQueue),
                    );
              },
            ),
          ],
        ),
      );
    }

    final currentMonster = state.discoverQueue[state.currentDiscoverIndex];
    final inventory = state.inventory;
    
    Compatibility? compatibility;
    if (inventory.isNotEmpty) {
      final prodCompatibility = ProductionService.calculateCompatibility(
        currentMonster,
        inventory[0],
      );
      // production.dartのCompatibilityをbreeding.dartのCompatibilityに変換
      CompatibilityLevel level;
      switch (prodCompatibility.level) {
        case production.CompatibilityLevel.high:
          level = CompatibilityLevel.high;
          break;
        case production.CompatibilityLevel.medium:
          level = CompatibilityLevel.medium;
          break;
        case production.CompatibilityLevel.low:
          level = CompatibilityLevel.low;
          break;
      }
      compatibility = Compatibility(
        level: level,
        reason: prodCompatibility.reason,
        matchingTags: prodCompatibility.matchingTags,
        complementaryTags: prodCompatibility.complementaryTags,
        conflictingTags: prodCompatibility.conflictingTags,
      );
    }

    final rotation = _dragPosition / 10;
    final opacity = 1.0 - (_dragPosition.abs() / 500).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'いいね残量: ${state.userState.likesRemaining}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),

          // いいね残量がゼロの場合の警告
          if (state.userState.likesRemaining <= 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border.all(color: Colors.yellow.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '本日はこれ以上いいねできません',
                style: TextStyle(
                  color: Colors.yellow.shade800,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // カード表示エリア
          SizedBox(
            height: 600,
            child: Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dragPosition += details.delta.dx;
                  });
                },
                onPanEnd: (details) {
                  const threshold = 100;
                  if (_dragPosition.abs() > threshold) {
                    if (_dragPosition > 0) {
                      _handleLike();
                    } else {
                      _handleSkip();
                    }
                  } else {
                    setState(() {
                      _dragPosition = 0;
                    });
                  }
                },
                child: Transform.translate(
                  offset: Offset(_dragPosition, 0),
                  child: Transform.rotate(
                    angle: rotation * 0.0174533, // 度をラジアンに変換
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        width: 350,
                        child: MonsterCard(
                          monster: currentMonster,
                          showDetails: false,
                          showParameters: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 目標への貢献度
          if (compatibility != null && state.userState.targetSpecies != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                '目標への貢献度: ${compatibility.matchingTags.isNotEmpty ? "${compatibility.matchingTags.length}個のタグが一致" : "相補的なタグの組み合わせ"}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 12,
                ),
              ),
            ),

          // 操作ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'スキップ',
                onPressed: _handleSkip,
                variant: ButtonVariant.secondary,
                icon: const Icon(Icons.close, size: 20),
              ),
              const SizedBox(width: 8),
              CustomButton(
                text: '詳細',
                onPressed: _showDetail,
                variant: ButtonVariant.ghost,
                icon: const Icon(Icons.info, size: 20),
              ),
              const SizedBox(width: 8),
              CustomButton(
                text: 'いいね',
                onPressed: _handleLike,
                variant: ButtonVariant.primary,
                disabled: state.userState.likesRemaining <= 0,
                icon: const Icon(Icons.favorite, size: 20),
              ),
              const SizedBox(width: 8),
              CustomButton(
                text: 'あとで見る',
                onPressed: _handleBookmark,
                variant: ButtonVariant.ghost,
                icon: const Icon(Icons.bookmark, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PC用キーボード操作ヒント
          Center(
            child: Text(
              'キーボード操作: ←/A = スキップ, →/D = いいね, Enter = 詳細',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 探すタブ（モンスター一覧）
  Widget _buildSearchTab(AppState state, ThemeData theme, [bool showRecommendedButton = false]) {
    // すべてのモンスターを取得（mock_dataから）
    // 自キャラクターといいね済みのキャラクターを除外
    final allMonsters = mockMonsters.where((monster) {
      // 自キャラクターを除外
      if (state.playerCharacter != null && monster.id == state.playerCharacter!.id) {
        return false;
      }
      // いいね済みのキャラクターを除外
      if (state.collaborations.any((c) => c.partnerId == monster.id)) {
        return false;
      }
      return true;
    }).toList();

    if (allMonsters.isEmpty) {
      return Center(
        child: Text(
          'モンスターが見つかりません',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Column(
      children: [
        // オススメボタン
        if (showRecommendedButton)
          Container(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'オススメ',
              onPressed: () {
                setState(() {
                  _showRecommended = true;
                });
              },
              variant: ButtonVariant.primary,
              icon: const Icon(Icons.star, size: 20),
            ),
          ),
        // モンスター一覧
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 画面幅に応じて列数を計算
              final double screenWidth = constraints.maxWidth;
              int crossAxisCount;
              if (screenWidth < 600) {
                crossAxisCount = 1; // モバイル
              } else if (screenWidth < 900) {
                crossAxisCount = 2; // タブレット
              } else if (screenWidth < 1200) {
                crossAxisCount = 3; // 小デスクトップ
              } else if (screenWidth < 1800) {
                crossAxisCount = 4; // デスクトップ
              } else {
                crossAxisCount = 5; // 大画面
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65, // パラメータ表示のために高さを増やす
                ),
                itemCount: allMonsters.length,
                itemBuilder: (context, index) {
                  final monster = allMonsters[index];
                  return MonsterCard(
                    monster: monster,
                    imageFirst: true,
                    showParameters: true,
                    onTap: () {
                      final inventory = state.inventory;
                      Compatibility? compatibility;
                      if (inventory.isNotEmpty) {
                        final prodCompatibility = ProductionService.calculateCompatibility(
                          monster,
                          inventory[0],
                        );
                        // production.dartのCompatibilityをbreeding.dartのCompatibilityに変換
                        CompatibilityLevel level;
                        switch (prodCompatibility.level) {
                          case production.CompatibilityLevel.high:
                            level = CompatibilityLevel.high;
                            break;
                          case production.CompatibilityLevel.medium:
                            level = CompatibilityLevel.medium;
                            break;
                          case production.CompatibilityLevel.low:
                            level = CompatibilityLevel.low;
                            break;
                        }
                        compatibility = Compatibility(
                          level: level,
                          reason: prodCompatibility.reason,
                          matchingTags: prodCompatibility.matchingTags,
                          complementaryTags: prodCompatibility.complementaryTags,
                          conflictingTags: prodCompatibility.conflictingTags,
                        );
                      }

                      // 既にいいね済みかチェック
                      final isLiked = state.collaborations.any((c) => c.partnerId == monster.id);
                      final canLike = state.userState.likesRemaining > 0 && !isLiked;

                      showDialog(
                        context: context,
                        builder: (context) => MonsterDetailDialog(
                          monster: monster,
                          compatibility: compatibility,
                          onLike: () {
                            if (canLike) {
                              ref.read(appStateProvider.notifier).likeMonster(monster);
                            }
                          },
                          onSkip: () {
                            // 一覧からはスキップ機能は不要
                          },
                          onBookmark: () {
                            ref.read(appStateProvider.notifier).addBookmark(monster);
                          },
                          canLike: canLike,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 相談所の成長タブ
  Widget _buildInstitutionGrowthTab(AppState state, ThemeData theme) {
    final institution = state.persistentAssets.institution;
    final knowledge = state.persistentAssets.knowledge;
    final lineageCore = state.persistentAssets.lineageCore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 相談所の成長とメタ進行
          Card(
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
          ),
        ],
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
}

