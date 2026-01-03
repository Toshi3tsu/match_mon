import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../services/production_service.dart';
import '../models/production.dart';
import '../models/monster.dart';

class ProductionScreen extends ConsumerStatefulWidget {
  const ProductionScreen({super.key});

  @override
  ConsumerState<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends ConsumerState<ProductionScreen> {
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    var productionPlan = state.productionPlan;

    // parentAを自キャラクターで固定
    if (state.playerCharacter != null) {
      if (productionPlan.parentA?.id != state.playerCharacter!.id) {
        productionPlan = productionPlan.copyWith(parentA: state.playerCharacter);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appStateProvider.notifier).setProductionPlan(productionPlan);
        });
      }
    }

    Compatibility? compatibility;
    if (productionPlan.parentA != null && productionPlan.parentB != null) {
      compatibility = ProductionService.calculateCompatibility(
        productionPlan.parentA!,
        productionPlan.parentB!,
      );
    }

    // ボンド値を取得
    int bond = 0;
    if (productionPlan.parentA != null && productionPlan.parentB != null && state.collaborations.isNotEmpty) {
      try {
        final collaboration = state.collaborations.firstWhere(
          (c) =>
              (c.partnerId == productionPlan.parentA?.id ||
                  c.partnerId == productionPlan.parentB?.id) &&
              (state.inventory.any((inv) => inv.id == productionPlan.parentA?.id) ||
                  state.inventory.any((inv) => inv.id == productionPlan.parentB?.id)),
          orElse: () => state.collaborations.first,
        );
        bond = collaboration.bond;
      } catch (e) {
        bond = 0;
      }
    }

    // プレビューを生成
    ProductionPreview? preview;
    if (productionPlan.parentA != null && productionPlan.parentB != null) {
      preview = ProductionService.generateProductionPreview(
        productionPlan.parentA!,
        productionPlan.parentB!,
        bond: bond,
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(
            title: '交配プランナー',
            fallbackRoute: '/consultation-office',
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
                    maxWidth: isDesktop ? 1400 : double.infinity,
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout(
                          context,
                          state,
                          theme,
                          productionPlan,
                          compatibility,
                          preview,
                          isMobile,
                          isTablet,
                        )
                      : _buildMobileLayout(
                          context,
                          state,
                          theme,
                          productionPlan,
                          compatibility,
                          preview,
                          isMobile,
                          isTablet,
                        ),
                ),
              );
            },
          ),
        ),
        // 確認ダイアログ
        if (_showConfirm && productionPlan.parentA != null && productionPlan.parentB != null)
          _ConfirmDialog(
            parentA: productionPlan.parentA!,
            parentB: productionPlan.parentB!,
            preview: preview,
            onCancel: () => setState(() => _showConfirm = false),
            onConfirm: () {
              setState(() => _showConfirm = false);
              _executeProduction(context, ref, productionPlan, preview, bond);
            },
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    dynamic state,
    ThemeData theme,
    ProductionPlan productionPlan,
    Compatibility? compatibility,
    ProductionPreview? preview,
    bool isMobile,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左カラム：親選択と相性
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 親A・親B選択（縦並び）
              _ParentSelector(
                label: '親A（自キャラクター）',
                selected: productionPlan.parentA,
                inventory: state.inventory,
                excludeId: productionPlan.parentB?.id,
                readOnly: true, // 自キャラクターで固定
                onSelect: (user) {
                  // 読み取り専用のため何もしない
                },
                onClear: () {
                  // 読み取り専用のため何もしない
                },
              ),
              const SizedBox(height: 12),
              _ParentSelector(
                label: '親B',
                selected: productionPlan.parentB,
                inventory: state.inventory,
                excludeId: productionPlan.parentA?.id,
                onSelect: (user) {
                  if (user.locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ロックされた個体は交配に使用できません'),
                      ),
                    );
                    return;
                  }
                  ref.read(appStateProvider.notifier).setProductionPlan(
                        productionPlan.copyWith(parentB: user),
                      );
                },
                onClear: () {
                  ref.read(appStateProvider.notifier).setProductionPlan(
                        productionPlan.copyWith(parentB: null),
                      );
                },
              ),
              const SizedBox(height: 12),
              // 相性表示
              if (compatibility != null)
                _buildCompatibilityCard(theme, compatibility),
              const SizedBox(height: 12),
              // 実行ボタン
              if (productionPlan.parentA != null && productionPlan.parentB != null)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '交配を実行',
                    onPressed: () => setState(() => _showConfirm = true),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    icon: const Icon(Icons.science, size: 20),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 右カラム：プレビュー情報
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preview != null) ...[
                _buildPreviewCard(theme, preview),
                const SizedBox(height: 12),
                _buildInheritanceCard(theme, preview),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        '親Aと親Bを選択すると、\n子の情報がプレビューされます',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
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
    ProductionPlan productionPlan,
    Compatibility? compatibility,
    ProductionPreview? preview,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 親A・親B選択
        if (isMobile)
          // モバイル：縦並び
          Column(
            children: [
              _ParentSelector(
                label: '親A（自キャラクター）',
                selected: productionPlan.parentA,
                inventory: state.inventory,
                excludeId: productionPlan.parentB?.id,
                readOnly: true, // 自キャラクターで固定
                onSelect: (user) {
                  // 読み取り専用のため何もしない
                },
                onClear: () {
                  // 読み取り専用のため何もしない
                },
              ),
              const SizedBox(height: 12),
              _ParentSelector(
                label: '親B',
                selected: productionPlan.parentB,
                inventory: state.inventory,
                excludeId: productionPlan.parentA?.id,
                onSelect: (user) {
                  if (user.locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ロックされた個体は交配に使用できません'),
                      ),
                    );
                    return;
                  }
                  ref.read(appStateProvider.notifier).setProductionPlan(
                        productionPlan.copyWith(parentB: user),
                      );
                },
                onClear: () {
                  ref.read(appStateProvider.notifier).setProductionPlan(
                        productionPlan.copyWith(parentB: null),
                      );
                },
              ),
            ],
          )
        else
          // タブレット：横並び
          Row(
            children: [
              Expanded(
                child: _ParentSelector(
                  label: '親A（自キャラクター）',
                  selected: productionPlan.parentA,
                  inventory: state.inventory,
                  excludeId: productionPlan.parentB?.id,
                  readOnly: true, // 自キャラクターで固定
                  onSelect: (user) {
                    // 読み取り専用のため何もしない
                  },
                  onClear: () {
                    // 読み取り専用のため何もしない
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ParentSelector(
                  label: '親B',
                  selected: productionPlan.parentB,
                  inventory: state.inventory,
                  excludeId: productionPlan.parentA?.id,
                  onSelect: (user) {
                    if (user.locked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ロックされた個体は交配に使用できません'),
                        ),
                      );
                      return;
                    }
                    ref.read(appStateProvider.notifier).setProductionPlan(
                          productionPlan.copyWith(parentB: user),
                        );
                  },
                  onClear: () {
                    ref.read(appStateProvider.notifier).setProductionPlan(
                          productionPlan.copyWith(parentB: null),
                        );
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        // 相性表示
        if (compatibility != null) ...[
          _buildCompatibilityCard(theme, compatibility),
          const SizedBox(height: 12),
        ],
        // プレビュー情報
        if (preview != null) ...[
          _buildPreviewCard(theme, preview),
          const SizedBox(height: 12),
          _buildInheritanceCard(theme, preview),
          const SizedBox(height: 12),
        ],
        // 実行ボタン
        if (productionPlan.parentA != null && productionPlan.parentB != null)
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: '交配を実行',
              onPressed: () => setState(() => _showConfirm = true),
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              icon: const Icon(Icons.science, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildCompatibilityCard(ThemeData theme, Compatibility compatibility) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '相性: ${compatibility.level == CompatibilityLevel.high ? "高い" : compatibility.level == CompatibilityLevel.medium ? "普通" : "低い"}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            compatibility.reason,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, ProductionPreview preview) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 20),
                const SizedBox(width: 8),
                Text(
                  '子の種族プレビュー',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildInfoRow(theme, '種族', preview.childSpecies, isLarge: true),
            const SizedBox(height: 12),
            _buildInfoRow(theme, '位階', preview.childRank),
            const SizedBox(height: 12),
            Text(
              '予想タグ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: preview.childTags
                  .map((tag) => TagWidget(label: tag))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInheritanceCard(ThemeData theme, ProductionPreview preview) {
    return Card(
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '継承プレビュー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoRow(theme, '継承枠数', '${preview.inheritanceSlots}個'),
            const SizedBox(height: 12),
            Text(
              '候補スキル',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: preview.candidateSkills.map((skill) {
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
            if (preview.accidentRate > 0) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                theme,
                '事故率',
                '${preview.accidentRate}%',
                valueColor: Colors.yellow.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    bool isLarge = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (isLarge
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _executeProduction(
    BuildContext context,
    WidgetRef ref,
    ProductionPlan plan,
    ProductionPreview? preview,
    int bond,
  ) {
    if (plan.parentA == null || plan.parentB == null) return;

    final child = ProductionService.executeProduction(
      plan.parentA!,
      plan.parentB!,
      bond,
    );

    final result = ProductionResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      parentA: plan.parentA!,
      parentB: plan.parentB!,
      child: child,
      bond: bond,
      createdAt: DateTime.now(),
      reason:
          '種族結果は${plan.parentA!.species}×${plan.parentB!.species}の法則により固定。${bond >= 50 ? "ボンドが高かったため継承枠が${bond >= 80 ? 2 : 1}増加。" : ""}',
      inheritance: Inheritance(
        slots: preview?.inheritanceSlots ?? 2,
        skills: child.skills,
      ),
    );

    ref.read(appStateProvider.notifier).addProductionResult(result);
    ref.read(appStateProvider.notifier).setPlayerCharacter(child);
    // parentAは自キャラクターなので削除しない
    // parentBのみ削除
    ref.read(appStateProvider.notifier).removeFromInventory(plan.parentB!.id);
    
    // プランをリセット（parentAは自キャラクターで固定のため、次回も自動設定される）
    ref.read(appStateProvider.notifier).setProductionPlan(ProductionPlan());

    context.go('/production/result?id=${result.id}');
  }
}

class _ParentSelector extends StatelessWidget {
  final String label;
  final Monster? selected;
  final List<Monster> inventory;
  final String? excludeId;
  final Function(Monster) onSelect;
  final VoidCallback onClear;
  final bool readOnly; // 読み取り専用フラグ

  const _ParentSelector({
    required this.label,
    required this.selected,
    required this.inventory,
    this.excludeId,
    required this.onSelect,
    required this.onClear,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (selected != null)
          Stack(
            children: [
              MonsterCard(
                monster: selected!,
                onTap: readOnly ? null : onClear, // 読み取り専用の場合は無効化
              ),
              if (!readOnly) // 読み取り専用の場合はクリアボタンを非表示
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onClear,
                  ),
                ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: readOnly ? theme.colorScheme.surfaceContainerHighest : null,
            ),
            child: Column(
              children: [
                Text(
                  readOnly ? '$label（固定）' : '$labelを選択してください',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (!readOnly) ...[
                  const SizedBox(height: 12),
                  DropdownButton<Monster>(
                    hint: const Text('選択...'),
                    isExpanded: true,
                    items: inventory
                        .where((u) => !u.locked && u.id != excludeId)
                        .map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          '${user.name} (${user.species})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (user) {
                      if (user != null) onSelect(user);
                    },
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '自キャラクターが設定されていません',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final Monster parentA;
  final Monster parentB;
  final ProductionPreview? preview;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.parentA,
    required this.parentB,
    required this.preview,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交配の確認',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '消費される親',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${parentA.name} × ${parentB.name}',
              style: theme.textTheme.bodyMedium,
            ),
            if (preview != null) ...[
              const SizedBox(height: 12),
              Text(
                '得られる子',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${preview!.childSpecies} (${preview!.childRank})',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border.all(color: Colors.yellow.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.yellow.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'この操作は取り消せません',
                      style: TextStyle(
                        color: Colors.yellow.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'キャンセル',
                    onPressed: onCancel,
                    variant: ButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: '実行',
                    onPressed: onConfirm,
                    variant: ButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
