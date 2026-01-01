import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    if (state.productionHistory.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: '交配履歴',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'まだ交配履歴がありません',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '交配を実行する',
                onPressed: () => context.go('/production'),
                variant: ButtonVariant.primary,
                icon: const Icon(Icons.science, size: 20),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('yyyy年M月d日 H:mm', 'ja_JP');

    return Scaffold(
      appBar: const CustomAppBar(
        title: '交配履歴',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.productionHistory.length,
        itemBuilder: (context, index) {
          final result = state.productionHistory[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(result.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.go('/production/result?id=${result.id}'),
                        child: const Text('詳細を見る'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      const Icon(Icons.science, size: 32),
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
                  const Divider(height: 32),
                  Text(
                    '結果',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    child: MonsterCard(
                      monster: result.child,
                      showDetails: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '理由: ${result.reason}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ボンド: ${result.bond} / 100',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: result.bond / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

