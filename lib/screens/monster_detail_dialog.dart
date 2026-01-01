import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../models/breeding.dart';
import '../widgets/tag_widget.dart';
import '../widgets/custom_button.dart';

class MonsterDetailDialog extends StatelessWidget {
  final Monster monster;
  final Compatibility? compatibility;
  final VoidCallback onLike;
  final VoidCallback onSkip;
  final VoidCallback onBookmark;
  final bool canLike;

  const MonsterDetailDialog({
    super.key,
    required this.monster,
    this.compatibility,
    required this.onLike,
    required this.onSkip,
    required this.onBookmark,
    required this.canLike,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monster.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 種族・位階
              Text(
                '種族・位階',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${monster.species} / ${monster.rank}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // タグ
              Text(
                'タグ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monster.tags
                    .map((tag) => TagWidget(label: tag))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // プロフィール
              Text(
                'プロフィール',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monster.profile,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // 相性
              if (compatibility != null) ...[
                Text(
                  '相性',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final compat = compatibility!;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compat.reason,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (compat.matchingTags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '一致タグ:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: compat.matchingTags
                                  .map((tag) => TagWidget(
                                        label: tag,
                                        variant: TagVariant.success,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // スキル候補
              Text(
                'スキル候補',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monster.skills.map((skill) {
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
              const SizedBox(height: 24),

              // 操作ボタン
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'スキップ',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSkip();
                      },
                      variant: ButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'ブックマーク',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onBookmark();
                      },
                      variant: ButtonVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'いいね',
                      onPressed: canLike
                          ? () {
                              Navigator.of(context).pop();
                              onLike();
                            }
                          : null,
                      variant: ButtonVariant.primary,
                      disabled: !canLike,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

