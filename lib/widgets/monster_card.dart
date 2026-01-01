import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/monster.dart';
import 'tag_widget.dart';

class MonsterCard extends StatelessWidget {
  final Monster monster;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool imageFirst; // 画像を最初に表示するか
  final bool showParameters; // パラメータを表示するか（タグの代わり）

  const MonsterCard({
    super.key,
    required this.monster,
    this.onTap,
    this.showDetails = false,
    this.imageFirst = false,
    this.showParameters = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 画像を最初に表示する場合（グリッド表示用）
    if (imageFirst) {
      return Card(
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 画像エリア（正方形）
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    width: double.infinity,
                    color: theme.colorScheme.surfaceVariant,
                    child: monster.image != null
                        ? _buildImage(monster.image!, theme, isSquare: true)
                        : _buildPlaceholderImage(theme),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(kIsWeb ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monster.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${monster.species} / ${monster.rank}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (showParameters && monster.parameters.isNotEmpty) ...[
                      ...monster.getAdjustedParameters().entries.take(2).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  entry.key,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (entry.value / 100).clamp(0.0, 1.0),
                                  backgroundColor: theme.colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getParameterColor(entry.value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  "${entry.value}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: monster.tags.take(2).map((tag) => TagWidget(label: tag)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 通常のカード表示
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 画像がある場合は表示
              if (monster.image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceVariant,
                    child: _buildImage(monster.image!, theme, isSquare: false),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monster.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${monster.species} / ${monster.rank}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (monster.locked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "ロック",
                        style: TextStyle(
                          color: Colors.yellow.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                monster.profile,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monster.tags
                    .map((tag) => TagWidget(label: tag))
                    .toList(),
              ),
              if (showDetails) ...[
                const Divider(height: 24),
                Text(
                  "スキル候補:",
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
                if (monster.parameters.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    "パラメータ:",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...monster.getAdjustedParameters().entries.map((entry) {
                    final baseValue = monster.parameters[entry.key] ?? 0;
                    final adjustedValue = entry.value;
                    final hasAdjustment = adjustedValue != baseValue;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    entry.key,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasAdjustment)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '(+${adjustedValue - baseValue})',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (adjustedValue / 100).clamp(0.0, 1.0),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getParameterColor(adjustedValue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text(
                              "${adjustedValue}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath, ThemeData theme, {bool isSquare = false}) {
    // ローカルアセットかネットワーク画像かを判定
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: isSquare ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(theme);
        },
      );
    } else {
      // ローカルアセット（assets/... で始まる）
      // Flutter Webでは、パスが正しく解決されるように調整
      String assetPath = imagePath;
      if (kIsWeb) {
        // Webでは、pubspec.yamlでassets/と指定しているため、
        // コード内のパス（assets/...）からassets/プレフィックスを削除
        if (imagePath.startsWith('assets/')) {
          // assets/を削除して、残りのパスを使用
          assetPath = imagePath.substring(7); // "assets/" の7文字を削除
        }
      }
      return Image.asset(
        assetPath,
        fit: isSquare ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // エラー時はプレースホルダーを表示
          return _buildPlaceholderImage(theme);
        },
      );
    }
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Color _getParameterColor(int value) {
    if (value >= 80) {
      return Colors.green;
    } else if (value >= 60) {
      return Colors.blue;
    } else if (value >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

