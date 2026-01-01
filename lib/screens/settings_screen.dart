import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _targetSpeciesController;
  late TextEditingController _targetTagsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appStateProvider);
    _targetSpeciesController = TextEditingController(
      text: state.userState.targetSpecies ?? '',
    );
    _targetTagsController = TextEditingController(
      text: state.userState.targetTags?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _targetSpeciesController.dispose();
    _targetTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '設定',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目標設定',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _targetSpeciesController,
                  decoration: const InputDecoration(
                    labelText: '目標種族',
                    hintText: '例: ドラゴンフェニックス',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _targetTagsController,
                  decoration: const InputDecoration(
                    labelText: '目標タグ（カンマ区切り）',
                    hintText: '例: 火属性, 攻撃特化',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '現在の状態',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _StatRow(
                  label: 'いいね残量:',
                  value: state.userState.likesRemaining.toString(),
                ),
                _StatRow(
                  label: '所持枠:',
                  value: state.userState.inventorySlots.toString(),
                ),
                _StatRow(
                  label: '交配回数:',
                  value: state.userState.breedingCount.toString(),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: '保存',
                  onPressed: () {
                    final targetTags = _targetTagsController.text
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();

                    ref.read(appStateProvider.notifier).setUserState(
                          state.userState.copyWith(
                            targetSpecies: _targetSpeciesController.text.isEmpty
                                ? null
                                : _targetSpeciesController.text,
                            targetTags:
                                targetTags.isEmpty ? null : targetTags,
                          ),
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('設定を保存しました'),
                      ),
                    );
                  },
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

