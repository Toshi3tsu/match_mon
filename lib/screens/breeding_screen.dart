import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../services/breeding_service.dart';
import '../models/breeding.dart';
import '../models/monster.dart';

class BreedingScreen extends ConsumerStatefulWidget {
  const BreedingScreen({super.key});

  @override
  ConsumerState<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends ConsumerState<BreedingScreen> {
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final breedingPlan = state.breedingPlan;

    Compatibility? compatibility;
    if (breedingPlan.parentA != null && breedingPlan.parentB != null) {
      compatibility = BreedingService.calculateCompatibility(
        breedingPlan.parentA!,
        breedingPlan.parentB!,
      );
    }

    // ボンド値を取得
    int bond = 0;
    if (breedingPlan.parentA != null && breedingPlan.parentB != null && state.matches.isNotEmpty) {
      try {
        final match = state.matches.firstWhere(
          (m) =>
              (m.partnerId == breedingPlan.parentA?.id ||
                  m.partnerId == breedingPlan.parentB?.id) &&
              (state.inventory.any((inv) => inv.id == breedingPlan.parentA?.id) ||
                  state.inventory.any((inv) => inv.id == breedingPlan.parentB?.id)),
          orElse: () => state.matches.first,
        );
        bond = match.bond;
      } catch (e) {
        // マッチが見つからない場合はボンド値0を使用
        bond = 0;
      }
    }

    // プレビューを生成
    BreedingPreview? preview;
    if (breedingPlan.parentA != null && breedingPlan.parentB != null) {
      preview = BreedingService.generateBreedingPreview(
        breedingPlan.parentA!,
        breedingPlan.parentB!,
        bond: bond,
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(
            title: '配合プランナー',
          ),
          body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 親A・親B選択
            Row(
              children: [
                Expanded(
                  child: _ParentSelector(
                    label: '親A',
                    selected: breedingPlan.parentA,
                    inventory: state.inventory,
                    excludeId: breedingPlan.parentB?.id,
                    onSelect: (user) {
                      if (user.locked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ロックされた個体は配合に使用できません'),
                          ),
                        );
                        return;
                      }
                      ref.read(appStateProvider.notifier).setBreedingPlan(
                            breedingPlan.copyWith(parentA: user),
                          );
                    },
                    onClear: () {
                      ref.read(appStateProvider.notifier).setBreedingPlan(
                            breedingPlan.copyWith(parentA: null),
                          );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ParentSelector(
                    label: '親B',
                    selected: breedingPlan.parentB,
                    inventory: state.inventory,
                    excludeId: breedingPlan.parentA?.id,
                    onSelect: (user) {
                      if (user.locked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ロックされた個体は配合に使用できません'),
                          ),
                        );
                        return;
                      }
                      ref.read(appStateProvider.notifier).setBreedingPlan(
                            breedingPlan.copyWith(parentB: user),
                          );
                    },
                    onClear: () {
                      ref.read(appStateProvider.notifier).setBreedingPlan(
                            breedingPlan.copyWith(parentB: null),
                          );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 相性表示
            if (compatibility != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '相性: ${compatibility.level == CompatibilityLevel.high ? "高い" : compatibility.level == CompatibilityLevel.medium ? "普通" : "低い"}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      compatibility.reason,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

            // 子の種族プレビュー
            if (preview != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science),
                          const SizedBox(width: 8),
                          Text(
                            '子の種族プレビュー',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '種族',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview.childSpecies,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '位階',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview.childRank,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '予想タグ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: preview.childTags
                            .map((tag) => TagWidget(label: tag))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // 継承プレビュー
            if (preview != null)
              Card(
                color: theme.colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '継承プレビュー',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '継承枠数',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${preview.inheritanceSlots}個',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '候補スキル',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                        const SizedBox(height: 16),
                        Text(
                          '事故率',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${preview.accidentRate}%',
                          style: TextStyle(
                            color: Colors.yellow.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // 実行ボタン
            if (breedingPlan.parentA != null && breedingPlan.parentB != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomButton(
                  text: '配合を実行',
                  onPressed: () => setState(() => _showConfirm = true),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  icon: const Icon(Icons.science, size: 20),
                ),
              ),
          ],
        ),
      ),
        ),
        // 確認ダイアログ
        if (_showConfirm && breedingPlan.parentA != null && breedingPlan.parentB != null)
          _ConfirmDialog(
            parentA: breedingPlan.parentA!,
            parentB: breedingPlan.parentB!,
            preview: preview,
            onCancel: () => setState(() => _showConfirm = false),
            onConfirm: () {
              setState(() => _showConfirm = false);
              _executeBreeding(context, ref, breedingPlan, preview, bond);
            },
          ),
      ],
    );
  }

  void _executeBreeding(
    BuildContext context,
    WidgetRef ref,
    BreedingPlan plan,
    BreedingPreview? preview,
    int bond,
  ) {
    if (plan.parentA == null || plan.parentB == null) return;

    final child = BreedingService.executeBreeding(
      plan.parentA!,
      plan.parentB!,
      bond,
    );

    final result = BreedingResult(
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

    // 配合結果を追加
    ref.read(appStateProvider.notifier).addBreedingResult(result);
    
    // 自キャラクターを置き換え
    ref.read(appStateProvider.notifier).setPlayerCharacter(child);
    
    // 親をinventoryから削除
    ref.read(appStateProvider.notifier).removeFromInventory(plan.parentA!.id);
    ref.read(appStateProvider.notifier).removeFromInventory(plan.parentB!.id);
    
    // 配合プランをリセット
    ref.read(appStateProvider.notifier).setBreedingPlan(BreedingPlan());

    context.go('/breeding/result?id=${result.id}');
  }
}

class _ParentSelector extends StatelessWidget {
  final String label;
  final Monster? selected;
  final List<Monster> inventory;
  final String? excludeId;
  final Function(Monster) onSelect;
  final VoidCallback onClear;

  const _ParentSelector({
    required this.label,
    required this.selected,
    required this.inventory,
    this.excludeId,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (selected != null)
          Stack(
            children: [
              MonsterCard(
                monster: selected!,
                onTap: onClear,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: onClear,
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '$labelを選択してください',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButton<Monster>(
                  hint: const Text('選択...'),
                  isExpanded: true,
                  items: inventory
                      .where((u) => !u.locked && u.id != excludeId)
                      .map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text('${user.name} (${user.species})'),
                    );
                  }).toList(),
                  onChanged: (user) {
                    if (user != null) onSelect(user);
                  },
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
  final BreedingPreview? preview;
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '配合の確認',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '消費される親',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${parentA.name} × ${parentB.name}',
              style: theme.textTheme.bodyLarge,
            ),
            if (preview != null) ...[
              const SizedBox(height: 16),
              Text(
                '得られる子',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${preview!.childSpecies} (${preview!.childRank})',
                style: theme.textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border.all(color: Colors.yellow.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.yellow.shade700),
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
            const SizedBox(height: 24),
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

