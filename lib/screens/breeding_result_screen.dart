import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';

class BreedingResultScreen extends ConsumerWidget {
  final String? resultId;

  const BreedingResultScreen({
    super.key,
    this.resultId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    final result = state.breedingHistory.firstWhere(
      (r) => r.id == resultId,
      orElse: () => state.breedingHistory.first,
    );

    if (resultId == null || !state.breedingHistory.any((r) => r.id == resultId)) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: '配合結果',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '結果が見つかりません',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '配合プランナーへ戻る',
                onPressed: () => context.go('/breeding'),
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: '配合結果',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Center(
              child: Column(
                children: [
                  Text(
                    '配合完了！',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '新しい個体が誕生しました',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 自キャラクター置き換えの通知
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '新しい自キャラクターになりました',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 結果カード
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: MonsterCard(
                monster: result.child,
                showDetails: true,
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // 結果の説明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今回の配合がこうなった理由',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.reason,
                      style: theme.textTheme.bodyMedium,
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
                      '${result.inheritance.slots}個',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '継承スキル',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.inheritance.skills.map((skill) {
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
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 親の情報
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '親A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MonsterCard(
                        monster: result.parentA,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '親B',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MonsterCard(
                        monster: result.parentB,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 次のおすすめ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '次のおすすめ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'この子を目標に設定',
                    onPressed: () {
                      ref.read(appStateProvider.notifier).setUserState(
                            state.userState.copyWith(
                              targetSpecies: result.child.species,
                              targetTags: result.child.tags,
                            ),
                          );
                      context.go('/settings');
                    },
                    variant: ButtonVariant.primary,
                    icon: const Icon(Icons.track_changes, size: 20),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'この子でさらに配合',
                    onPressed: () => context.go('/breeding'),
                    variant: ButtonVariant.secondary,
                    icon: const Icon(Icons.science, size: 20),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: '履歴を見る',
                    onPressed: () => context.go('/history'),
                    variant: ButtonVariant.ghost,
                    icon: const Icon(Icons.history, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

