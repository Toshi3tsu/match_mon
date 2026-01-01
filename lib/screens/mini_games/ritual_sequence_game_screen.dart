import 'package:flutter/material.dart';
import '../../models/collaboration.dart';
import '../../models/match_session.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'dart:math';
import 'dart:async';

/// 儀式手順（記憶・順序）型ミニゲーム
/// 設計書 5.5.1.3 参照
class RitualSequenceGameScreen extends StatefulWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(MiniGameResult) onResult;

  const RitualSequenceGameScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onResult,
  });

  @override
  State<RitualSequenceGameScreen> createState() =>
      _RitualSequenceGameScreenState();
}

class _RitualSequenceGameScreenState extends State<RitualSequenceGameScreen> {
  final List<String> _ritualSteps = ['火', '水', '風', '土', '光'];
  List<String> _targetSequence = [];
  List<String> _playerSequence = [];
  bool _showingSequence = false;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _generateSequence();
  }

  void _generateSequence() {
    // 3〜5ステップのランダムな順序を生成
    final stepCount = 3 + _random.nextInt(3);
    _targetSequence = List.generate(
      stepCount,
      (index) => _ritualSteps[_random.nextInt(_ritualSteps.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '儀式手順',
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
                      '儀式手順',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '相手の好む儀式の段取りを記憶して再現します。順序を覚えてください。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 目標順序表示（ゲーム開始後、表示中のみ）
            if (_gameStarted && _showingSequence && !_gameCompleted)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '儀式の手順（${_targetSequence.length}ステップ）',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _targetSequence
                            .asMap()
                            .entries
                            .map((entry) => _buildStepChip(entry.value, entry.key, theme))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            if (_gameStarted && _showingSequence && !_gameCompleted)
              const SizedBox(height: 24),

            // プレイヤーの入力（表示が終わった後）
            if (_gameStarted && !_showingSequence && !_gameCompleted) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '同じ順序で再現してください',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _ritualSteps.map((step) {
                          return FilterChip(
                            label: Text(step),
                            selected: _playerSequence.contains(step),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _playerSequence.add(step);
                                } else {
                                  _playerSequence.remove(step);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      if (_playerSequence.isNotEmpty) ...[
                        Text(
                          '選択した順序:',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _playerSequence
                              .asMap()
                              .entries
                              .map((entry) => _buildStepChip(
                                  entry.value, entry.key, theme))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _playerSequence.clear();
                                });
                              },
                              child: const Text('リセット'),
                            ),
                            const Spacer(),
                            CustomButton(
                              text: '決定',
                              onPressed: () => _checkSequence(),
                              variant: ButtonVariant.primary,
                              size: ButtonSize.small,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 結果表示
            if (_gameCompleted) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect() ? '成功！' : '失敗',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: _isCorrect() ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!_isCorrect())
                        Text(
                          '次回のヒント: ${_getHint()}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ボタン
            if (!_gameStarted)
              CustomButton(
                text: 'ゲーム開始',
                onPressed: () => _startGame(),
                variant: ButtonVariant.primary,
              )
            else if (_gameCompleted)
              CustomButton(
                text: '完了',
                onPressed: () => _submitResult(),
                variant: ButtonVariant.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChip(String step, int index, ThemeData theme) {
    return Chip(
      label: Text('${index + 1}. $step'),
      backgroundColor: theme.colorScheme.primaryContainer,
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _showingSequence = true;
    });

    // 3秒後に順序を隠す
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showingSequence = false;
        });
      }
    });
  }

  void _checkSequence() {
    setState(() {
      _gameCompleted = true;
    });
  }

  bool _isCorrect() {
    if (_playerSequence.length != _targetSequence.length) return false;
    for (int i = 0; i < _playerSequence.length; i++) {
      if (_playerSequence[i] != _targetSequence[i]) return false;
    }
    return true;
  }

  String _getHint() {
    if (_targetSequence.isEmpty) return '';
    return '${_targetSequence[0]}から始まる';
  }

  void _submitResult() {
    final success = _isCorrect();
    int favorabilityChange;
    String? trueNameFragment;
    String? hintForNext;

    if (success) {
      favorabilityChange = 10 + _random.nextInt(6); // 10-15
      trueNameFragment = '真名の断片: ${_targetSequence.join('')}';
    } else {
      favorabilityChange = -2 - _random.nextInt(4); // -2 to -5
      hintForNext = _getHint();
    }

    final List<RevealedInfo> revealedInfo = [];

    // 第三層（深掘り情報）の一部（成功時）
    if (success) {
      revealedInfo.add(RevealedInfo(
        type: 'trueNameFragment',
        value: trueNameFragment!,
        layer: 3,
      ));
    }

    final result = RitualSequenceGameResult(
      success: success,
      trueNameFragment: trueNameFragment,
      hintForNext: hintForNext,
      favorabilityChange: favorabilityChange,
      revealedInfo: revealedInfo,
    );

    widget.onResult(result);
    Navigator.pop(context);
  }
}

