import 'package:flutter/material.dart';
import '../../models/collaboration.dart';
import '../../models/match_session.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'dart:math';

/// 同行試練（短い判断）型ミニゲーム
/// 設計書 5.5.1.5 参照
class TrialGameScreen extends StatefulWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(MiniGameResult) onResult;

  const TrialGameScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onResult,
  });

  @override
  State<TrialGameScreen> createState() => _TrialGameScreenState();
}

class _TrialGameScreenState extends State<TrialGameScreen> {
  String? _selectedJudgment;
  final _random = Random();

  final List<Map<String, dynamic>> _situations = [
    {
      'situation': '敵が迫っている。どうする？',
      'judgments': [
        {'text': '正面から迎え撃つ', 'valueTag': '勇敢'},
        {'text': '戦略的に撤退する', 'valueTag': '慎重'},
        {'text': '交渉を試みる', 'valueTag': '知恵'},
      ],
    },
    {
      'situation': '仲間が負傷した。どうする？',
      'judgments': [
        {'text': 'すぐに治療する', 'valueTag': '慈愛'},
        {'text': '戦闘を優先する', 'valueTag': '実利'},
        {'text': '状況を判断する', 'valueTag': '冷静'},
      ],
    },
    {
      'situation': '宝物を発見した。どうする？',
      'judgments': [
        {'text': '独り占めする', 'valueTag': '利己'},
        {'text': '仲間と分ける', 'valueTag': '協調'},
        {'text': '調査してから決める', 'valueTag': '慎重'},
      ],
    },
  ];

  late final Map<String, dynamic> _currentSituation;
  late final List<String> _valueTags; // 相手の価値観タグ

  @override
  void initState() {
    super.initState();
    _currentSituation = _situations[_random.nextInt(_situations.length)];
    // 相手のタグから価値観を推定（簡易版）
    _valueTags = widget.collaboration.partner.tags.take(2).toList();
    // ランダムに1つ追加
    final allValueTags = _currentSituation['judgments']
        .map((j) => j['valueTag'] as String)
        .toList();
    _valueTags.add(allValueTags[_random.nextInt(allValueTags.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '同行試練',
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
                      '同行試練',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'この状況でどう判断するか選択してください。相手の価値観タグに合うと好感度が伸びます。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 状況説明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '状況',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentSituation['situation'] as String,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 選択肢
            Text(
              '判断を選択',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...(_currentSituation['judgments'] as List).map((judgment) {
              final isSelected = _selectedJudgment == judgment['text'];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 1,
                color: isSelected ? theme.colorScheme.primaryContainer : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedJudgment = judgment['text'] as String;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            judgment['text'] as String,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // 決定ボタン
            CustomButton(
              text: '決定',
              onPressed: _selectedJudgment != null ? _submitResult : null,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _submitResult() {
    if (_selectedJudgment == null) return;

    final selectedJudgment = (_currentSituation['judgments'] as List)
        .firstWhere((j) => j['text'] == _selectedJudgment);
    final valueTag = selectedJudgment['valueTag'] as String;

    final valueMatch = _valueTags.contains(valueTag);
    int favorabilityChange;

    if (valueMatch) {
      favorabilityChange = 10 + _random.nextInt(6); // 10-15
    } else {
      favorabilityChange = 2 + _random.nextInt(4); // 2-5
    }

    final List<RevealedInfo> revealedInfo = [];

    // 第三層（深掘り情報）の一部
    if (valueMatch) {
      revealedInfo.add(RevealedInfo(
        type: 'valueTag',
        value: valueTag,
        layer: 3,
      ));
      revealedInfo.add(RevealedInfo(
        type: 'trust',
        value: '信頼が深まった',
        layer: 3,
      ));
    } else {
      revealedInfo.add(RevealedInfo(
        type: 'valueHint',
        value: '価値観の手がかりが得られた',
        layer: 3,
      ));
    }

    final result = TrialGameResult(
      situation: _currentSituation['situation'] as String,
      selectedJudgment: _selectedJudgment!,
      valueMatch: valueMatch,
      favorabilityChange: favorabilityChange,
      revealedInfo: revealedInfo,
    );

    widget.onResult(result);
    Navigator.pop(context);
  }
}

