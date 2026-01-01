import 'package:flutter/material.dart';
import '../../models/collaboration.dart';
import '../../models/match_session.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'dart:math';

/// 贈与/供物の調合（選択）型ミニゲーム
/// 設計書 5.5.1.4 参照
class OfferingGameScreen extends StatefulWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(MiniGameResult) onResult;

  const OfferingGameScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onResult,
  });

  @override
  State<OfferingGameScreen> createState() => _OfferingGameScreenState();
}

class _OfferingGameScreenState extends State<OfferingGameScreen> {
  final List<String> _selectedOfferings = [];
  final _random = Random();

  final List<Map<String, dynamic>> _offerings = [
    {'id': 'crystal', 'name': '魔力の結晶', 'tags': ['魔力', '精霊']},
    {'id': 'herb', 'name': '癒しの薬草', 'tags': ['回復', '自然']},
    {'id': 'metal', 'name': '鍛造の金属', 'tags': ['攻撃', '堅牢']},
    {'id': 'scroll', 'name': '古の書物', 'tags': ['知識', '魔法']},
    {'id': 'flower', 'name': '祝福の花', 'tags': ['祝福', '生命']},
    {'id': 'stone', 'name': '守護の石', 'tags': ['防御', '安定']},
  ];

  // 相手の嗜好タグ（ランダムで決定）
  late final List<String> _preferenceTags;

  @override
  void initState() {
    super.initState();
    // 相手のタグから嗜好を推定（簡易版）
    _preferenceTags = widget.collaboration.partner.tags.take(2).toList();
    // ランダムに1つ追加
    final allTags = _offerings.expand((o) => o['tags'] as List<String>).toSet().toList();
    _preferenceTags.add(allTags[_random.nextInt(allTags.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '贈与/供物の調合',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '贈与/供物の調合',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '候補から4〜6個の供物/触媒/素材を提示し、2つを選択して相手に提示します。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 供物選択
            Text(
              '供物を2つ選択してください',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _offerings.map((offering) {
                final isSelected = _selectedOfferings.contains(offering['id']);
                return FilterChip(
                  label: Text(offering['name'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedOfferings.length < 2) {
                          _selectedOfferings.add(offering['id'] as String);
                        }
                      } else {
                        _selectedOfferings.remove(offering['id'] as String);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '選択: ${_selectedOfferings.length} / 2',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // 決定ボタン
            CustomButton(
              text: '決定',
              onPressed: _selectedOfferings.length == 2 ? _submitResult : null,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _submitResult() {
    // 選択した供物のタグを取得
    final selectedTags = _selectedOfferings
        .map((id) => _offerings.firstWhere((o) => o['id'] == id))
        .expand((o) => o['tags'] as List<String>)
        .toList();

    // 嗜好タグとの一致度を計算
    int matchCount = 0;
    for (final tag in selectedTags) {
      if (_preferenceTags.contains(tag)) {
        matchCount++;
      }
    }

    final preferenceMatch = matchCount >= 2;
    int favorabilityChange;

    if (preferenceMatch) {
      favorabilityChange = 12 + _random.nextInt(9); // 12-20
    } else {
      favorabilityChange = 3 + _random.nextInt(3); // 3-5
    }

    final List<RevealedInfo> revealedInfo = [];

    // 第三層（深掘り情報）の一部（嗜好に合致した場合）
    if (preferenceMatch) {
      revealedInfo.add(RevealedInfo(
        type: 'preferenceTag',
        value: _preferenceTags.join(', '),
        layer: 3,
      ));
      revealedInfo.add(RevealedInfo(
        type: 'compatibilityTag',
        value: '相性が向上',
        layer: 3,
      ));
    } else {
      revealedInfo.add(RevealedInfo(
        type: 'preferenceHint',
        value: '嗜好の手がかりが得られた',
        layer: 3,
      ));
    }

    final result = OfferingGameResult(
      selectedOfferings: _selectedOfferings,
      preferenceMatch: preferenceMatch,
      favorabilityChange: favorabilityChange,
      revealedInfo: revealedInfo,
    );

    widget.onResult(result);
    Navigator.pop(context);
  }
}

