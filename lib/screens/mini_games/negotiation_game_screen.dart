import 'package:flutter/material.dart';
import '../../models/collaboration.dart';
import '../../models/match_session.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'dart:math';

/// 契約交渉（会話カード）型ミニゲーム
/// 設計書 5.5.1.1 参照
class NegotiationGameScreen extends StatefulWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(MiniGameResult) onResult;

  const NegotiationGameScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onResult,
  });

  @override
  State<NegotiationGameScreen> createState() => _NegotiationGameScreenState();
}

class _NegotiationGameScreenState extends State<NegotiationGameScreen> {
  String? _selectedCard;
  final _random = Random();

  final List<Map<String, dynamic>> _cards = [
    {
      'id': 'question',
      'name': '確認質問',
      'description': '耐性や継承制限の確定に強いが好感度が伸びにくい',
      'icon': Icons.help_outline,
      'favorabilityRange': [2, 5],
      'infoRevealChance': 0.8,
    },
    {
      'id': 'benefit',
      'name': '利益提示',
      'description': '好感度が伸びやすいが情報は開きにくい',
      'icon': Icons.trending_up,
      'favorabilityRange': [8, 12],
      'infoRevealChance': 0.3,
    },
    {
      'id': 'condition',
      'name': '条件提示',
      'description': '狙い候補の確率寄せが進むが失敗すると好感度が落ちやすい',
      'icon': Icons.rule,
      'favorabilityRange': [5, 10],
      'infoRevealChance': 0.6,
      'failureChance': 0.3,
      'failurePenalty': -3,
    },
    {
      'id': 'concession',
      'name': '譲歩',
      'description': '好感度が中程度伸び、情報開示も中程度',
      'icon': Icons.handshake,
      'favorabilityRange': [5, 8],
      'infoRevealChance': 0.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '契約交渉',
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
                      '契約交渉',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '相手個体との交渉を通じて、条件を詰めていきます。選択肢カードを1枚選んでください。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // カード選択
            Text(
              '選択肢カード',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._cards.map((card) => _buildCardOption(card, theme)),
            const SizedBox(height: 24),

            // 決定ボタン
            CustomButton(
              text: '決定',
              onPressed: _selectedCard != null ? _submitResult : null,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(Map<String, dynamic> card, ThemeData theme) {
    final isSelected = _selectedCard == card['id'];
    final icon = card['icon'] as IconData;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCard = card['id'] as String;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card['description'] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _submitResult() {
    if (_selectedCard == null) return;

    final card = _cards.firstWhere((c) => c['id'] == _selectedCard);
    final favorabilityRange = card['favorabilityRange'] as List<int>;
    final baseFavorability = favorabilityRange[0] +
        _random.nextInt(favorabilityRange[1] - favorabilityRange[0] + 1);

    int favorabilityChange = baseFavorability;

    // 条件提示の場合、失敗の可能性
    if (card['id'] == 'condition' && card['failureChance'] != null) {
      if (_random.nextDouble() < card['failureChance']) {
        favorabilityChange = card['failurePenalty'] as int;
      }
    }

    // 開示される情報を決定
    final infoRevealChance = card['infoRevealChance'] as double;
    final List<RevealedInfo> revealedInfo = [];

    if (_random.nextDouble() < infoRevealChance) {
      // 第二層（準公開情報）の確定
      final infoTypes = ['resistance', 'weakness', 'inheritanceAptitude'];
      final selectedType = infoTypes[_random.nextInt(infoTypes.length)];
      revealedInfo.add(RevealedInfo(
        type: selectedType,
        value: '確定',
        layer: 2,
      ));
    }

    // 第三層（深掘り情報）の一部（低確率）
    if (_random.nextDouble() < 0.2) {
      final deepInfoTypes = ['hiddenTag', 'accidentTrait', 'skillCandidate'];
      final selectedType = deepInfoTypes[_random.nextInt(deepInfoTypes.length)];
      revealedInfo.add(RevealedInfo(
        type: selectedType,
        value: '判明',
        layer: 3,
      ));
    }

    final result = NegotiationGameResult(
      selectedCard: _selectedCard!,
      favorabilityChange: favorabilityChange,
      revealedInfo: revealedInfo,
    );

    widget.onResult(result);
    Navigator.pop(context);
  }
}

