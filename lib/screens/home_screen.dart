import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_button.dart';
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
        // 左カラム（自キャラクター + 今回の遠征 + 永続資産 + 現在の状態）
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
              // 遠征準備（配合目標）
              if (state.userState.targetSpecies != null)
                _buildTargetCard(context, state, theme, isMobile, isTablet),
              if (state.userState.targetSpecies != null)
                const SizedBox(height: 12),
              _buildPersistentAssetsCard(context, state, theme, ref, isMobile, isTablet),
              const SizedBox(height: 12),
              _buildUserStateCard(context, state, theme, ref, isMobile, isTablet),
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
              if (recentCollaborations.isNotEmpty || recentProduction.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  theme,
                  '直近の出来事',
                  () {
                    if (recentCollaborations.isNotEmpty) {
                      context.go('/collaborations');
                    } else if (recentProduction.isNotEmpty) {
                      context.go('/history');
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildEventLog(
                  context,
                  theme,
                  recentCollaborations,
                  recentProduction,
                  isMobile,
                ),
                const SizedBox(height: 16),
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
        // 自キャラクター
        _buildPlayerCharacterCard(
          context,
          state,
          theme,
          isMobile,
          isTablet,
          false, // isDesktop
        ),
        const SizedBox(height: 12),
        // 第2セクション：遠征準備（配合目標）
        if (state.userState.targetSpecies != null) ...[
          _buildTargetCard(context, state, theme, isMobile, isTablet),
          const SizedBox(height: 12),
        ],
        // 第3セクション：永続資産
        _buildPersistentAssetsCard(context, state, theme, ref, isMobile, isTablet),
        const SizedBox(height: 12),
        // 第4セクション：現在の状態
        _buildUserStateCard(context, state, theme, ref, isMobile, isTablet),
        const SizedBox(height: 12),
        // 第二層：直近の出来事（証跡）
        if (recentCollaborations.isNotEmpty || recentProduction.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            theme,
            '直近の出来事',
            () {
              if (recentCollaborations.isNotEmpty) {
                context.go('/collaborations');
              } else if (recentProduction.isNotEmpty) {
                context.go('/history');
              }
            },
          ),
          const SizedBox(height: 8),
          _buildEventLog(
            context,
            theme,
            recentCollaborations,
            recentProduction,
            isMobile,
          ),
          const SizedBox(height: 12),
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
      color: theme.colorScheme.surfaceContainerHighest,
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
    return _buildCharacterOverlay(monster, theme, context);
  }

  Widget _buildCharacterVertical(
    BuildContext context,
    Monster monster,
    ThemeData theme,
    bool isMobile,
  ) {
    return _buildCharacterOverlay(monster, theme, context);
  }

  // 画像の上に名前とパラメータを重ねて表示
  Widget _buildCharacterOverlay(
    Monster monster,
    ThemeData theme,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () => context.go('/player-character'),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // 画像（正方形）
          _buildCharacterImage(monster, theme),
          // 上段：名前（半透過背景）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monster.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "${monster.species} / ${monster.rank}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 性別アイコン
                            Icon(
                              monster.gender == 'female' ? Icons.female : Icons.male,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              monster.gender == 'female' ? 'メス' : 'オス',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
          // 下段：パラメータ（半透過背景）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: _buildParametersDisplay(monster, theme),
            ),
          ),
        ],
      ),
    );
  }

  // パラメータ表示
  Widget _buildParametersDisplay(Monster monster, ThemeData theme) {
    // 装備補正後のパラメータを取得
    final adjustedParams = monster.getAdjustedParameters();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 性別と寿命の情報
        Row(
          children: [
            Icon(
              monster.gender == 'female' ? Icons.female : Icons.male,
              size: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            Text(
              monster.gender == 'female' ? 'メス' : 'オス',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.timer_outlined,
              size: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            Text(
              '${monster.age}ターン目 / 残り${monster.remainingLifespan}ターン',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (monster.isBreedable) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '交配可能',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (adjustedParams.isNotEmpty) ...[
          const SizedBox(height: 8),
          // 主要パラメータを表示（最大4つ、優先順位付き）
          Builder(
            builder: (context) {
              // パラメータの優先順位を定義（7パラメータ構成）
              final priorityOrder = ['攻撃力', '魔力', '防御力', '敏捷性', '精神力', 'インテリジェンス', '魅力'];
              
              // 優先順位に従ってソートし、存在するパラメータを取得
              final sortedParams = <MapEntry<String, int>>[];
              
              // 優先順位の高い順に追加
              for (final key in priorityOrder) {
                if (adjustedParams.containsKey(key)) {
                  sortedParams.add(MapEntry(key, adjustedParams[key]!));
                }
              }
              
              // 優先順位にないパラメータも追加
              for (final entry in adjustedParams.entries) {
                if (!priorityOrder.contains(entry.key) && !sortedParams.any((e) => e.key == entry.key)) {
                  sortedParams.add(entry);
                }
              }
              
              // 最大4つまで表示
              final displayParams = sortedParams.take(4).toList();
              
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: displayParams.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'パラメータ未設定',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  /// 画像パスからベース名を抽出（拡張子とディレクトリパスを処理）
  String _getBaseName(String imagePath) {
    // パスからファイル名を取得
    String fileName = imagePath.split('/').last;
    // 拡張子を除去
    if (fileName.contains('.')) {
      fileName = fileName.substring(0, fileName.lastIndexOf('.'));
    }
    // ディレクトリパスを取得
    String directory = imagePath.substring(0, imagePath.lastIndexOf('/') + 1);
    return '$directory$fileName';
  }

  Widget _buildCharacterImage(Monster monster, ThemeData theme) {
    if (monster.image == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            width: double.infinity,
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

    // ベース名を取得
    final baseName = _getBaseName(monster.image!);
    final gifPath = '$baseName.gif';
    final backgroundPath = '${baseName}_background.png';
    final normalImagePath = monster.image!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceVariant,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景画像（_background.pngがある場合はそれを使用、ない場合は通常の画像）
              _buildImageWithFallback(
                backgroundPath,
                normalImagePath,
                theme,
                BoxFit.cover,
              ),
              // GIFアニメーション（存在する場合のみ表示）
              _buildGifAnimation(
                gifPath,
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 画像を表示（フォールバック付き）
  Widget _buildImageWithFallback(
    String primaryPath,
    String fallbackPath,
    ThemeData theme,
    BoxFit fit,
  ) {
    String assetPath = primaryPath;
    if (kIsWeb && assetPath.startsWith('assets/')) {
      assetPath = assetPath.substring(7);
    }

    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // フォールバック：通常の画像を表示
        String fallbackAssetPath = fallbackPath;
        if (kIsWeb && fallbackAssetPath.startsWith('assets/')) {
          fallbackAssetPath = fallbackAssetPath.substring(7);
        }
        return Image.asset(
          fallbackAssetPath,
          fit: fit,
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
    );
  }

  /// GIFアニメーションを表示
  Widget _buildGifAnimation(
    String gifPath,
    ThemeData theme,
  ) {
    String assetPath = gifPath;
    if (kIsWeb && assetPath.startsWith('assets/')) {
      assetPath = assetPath.substring(7);
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // GIFが読み込めない場合は何も表示しない（背景画像のみ）
        return const SizedBox.shrink();
      },
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
          onPressed: () => context.go('/consultation-office'),
          icon: const Icon(Icons.business, size: 18),
          label: const Text('相談所へ'),
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
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final isExpanded = state.userState.showUserStateDetails;
    
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '現在の状態',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(appStateProvider.notifier).setUserState(
                      state.userState.copyWith(
                        showUserStateDetails: !isExpanded,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (isExpanded) ...[
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
                        label: '本日の調停回数',
                        value: state.userState.likesRemaining.toString(),
                      ),
                      _StatItem(
                        label: '保有素材',
                        value: '${state.inventory.length}',
                      ),
                      _StatItem(
                        label: '系譜更新回数',
                        value: state.userState.breedingCount.toString(),
                      ),
                      _StatItem(
                        label: '契約成立数',
                        value: state.collaborations.length.toString(),
                      ),
                    ],
                  );
                },
              ),
            ],
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
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: isMobile ? 20 : 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '遠征準備',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.userState.targetSpecies != null) ...[
              Text(
                '目標種族: ${state.userState.targetSpecies}'
                '${state.userState.targetTags != null && state.userState.targetTags!.isNotEmpty ? " (タグ: ${state.userState.targetTags!.join(", ")})" : ""}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomButton(
                  text: '相談所へ',
                  onPressed: () => context.go('/consultation-office'),
                  variant: ButtonVariant.primary,
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

  // 第二層：直近の出来事（証跡）をログ形式で表示
  Widget _buildEventLog(
    BuildContext context,
    ThemeData theme,
    List recentCollaborations,
    List recentProduction,
    bool isMobile,
  ) {
    // 時系列でソート（新しい順）
    final allEvents = <_EventItem>[];
    
    for (var collab in recentCollaborations) {
      allEvents.add(_EventItem(
        type: _EventType.collaboration,
        monster: collab.partner,
        data: collab,
        timestamp: collab.createdAt,
      ));
    }
    
    for (var prod in recentProduction) {
      allEvents.add(_EventItem(
        type: _EventType.production,
        monster: prod.child,
        data: prod,
        timestamp: prod.createdAt,
      ));
    }
    
    allEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: allEvents.take(5).map((event) {
            String eventText;
            VoidCallback? onTap;
            
            if (event.type == _EventType.collaboration) {
              eventText = '${event.monster.name}と契約成立（継承枠+1の見込み）';
              onTap = () => context.go('/collaborations');
            } else {
              final tags = event.monster.tags.join('、');
              eventText = '交配で${event.monster.name}が誕生（${tags.isNotEmpty ? tags : "新しい個体"}）';
              onTap = () => context.go('/history');
            }
            
            return InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      event.type == _EventType.collaboration
                          ? Icons.handshake
                          : Icons.auto_awesome,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        eventText,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
              text: '相談所へ',
              onPressed: () => context.go('/consultation-office'),
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
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    final assets = state.persistentAssets;
    final knowledge = assets.knowledge;
    final institution = assets.institution;
    final lineageCore = assets.lineageCore;
    final isExpanded = state.userState.showPersistentAssetsDetails;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
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
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '継承の記録',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(appStateProvider.notifier).setUserState(
                      state.userState.copyWith(
                        showPersistentAssetsDetails: !isExpanded,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              // 第一層：知識（情報の継承）
              _buildAssetRow(
                context,
                theme,
                '知識',
                '${knowledge.breedingRecipes.length}レシピ / ${knowledge.discoveredPatterns.length}パターン / ${knowledge.enemyEncyclopedia.length}敵',
                Colors.orange,
                Icons.lightbulb,
              ),
              const SizedBox(height: 8),
              // 第二層：選択肢（手段の継承）
              _buildAssetRow(
                context,
                theme,
                '制度',
                'ランク${institution.consultationOfficeRank} / 契約枠${institution.contractSlots} / 行動${assets.choices.unlockedBondActions.length}個',
                Colors.blue,
                Icons.business,
              ),
              const SizedBox(height: 8),
              // 第三層：系譜資産（配合の継承）
              _buildAssetRow(
                context,
                theme,
                '系譜コア',
                '継承枠${lineageCore.inheritanceSlots} / 記録${lineageCore.lineageRecords.length}件 / 特性${assets.lineageAssets.unlockedTraitSlots.length}個',
                Colors.purple,
                Icons.account_tree,
              ),
            ],
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

class _EventItem {
  final _EventType type;
  final Monster monster;
  final dynamic data;
  final DateTime timestamp;

  _EventItem({
    required this.type,
    required this.monster,
    required this.data,
    required this.timestamp,
  });
}

enum _EventType {
  collaboration,
  production,
}
