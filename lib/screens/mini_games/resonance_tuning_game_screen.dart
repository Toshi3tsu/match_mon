import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/collaboration.dart';
import '../../models/match_session.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

/// 共鳴調律（パズル）型ミニゲーム
/// 設計書 5.5.1.2 参照
/// 波形の重ね合わせで再現するミニゲーム
class ResonanceTuningGameScreen extends StatefulWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(MiniGameResult) onResult;

  const ResonanceTuningGameScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onResult,
  });

  @override
  State<ResonanceTuningGameScreen> createState() =>
      _ResonanceTuningGameScreenState();
}

class _ResonanceTuningGameScreenState
    extends State<ResonanceTuningGameScreen> {
  // 目標波形（ランダムで生成）
  late final List<WaveComponent> _targetWaves;
  
  // プレイヤーが作成した波形コンポーネント
  final List<WaveComponent> _playerWaves = [];
  
  // 現在選択中の強度（1～3）
  int _selectedIntensity = 1;
  
  // 現在選択中のテンポ（秒）
  double _selectedTempo = 1.0;
  
  // テンポの範囲（秒）
  static const double _minTempo = 0.5;
  static const double _maxTempo = 3.0;
  
  // ゲーム開始フラグ
  bool _gameStarted = false;
  
  // 回答提出フラグ
  bool _submitted = false;
  
  final _random = Random();

  @override
  void initState() {
    super.initState();
    // 相手キャラクターの位階に応じて波形数を決定
    final waveCount = _getWaveCountFromRank(widget.collaboration.partner.rank);
    _targetWaves = List.generate(waveCount, (index) {
      // テンポを0.5刻みで生成
      final tempoValue = 0.5 + _random.nextDouble() * 2.5;
      final roundedTempo = ((tempoValue / 0.5).round() * 0.5).clamp(0.5, 3.0);
      return WaveComponent(
        intensity: 1 + _random.nextInt(3), // 強度1～3
        tempo: roundedTempo, // テンポ0.5～3.0秒（0.5刻み）
      );
    });
  }

  /// 位階に応じて波形数を決定
  int _getWaveCountFromRank(String rank) {
    // 位階に応じて波形数を決定（位階が高いほど波形数が増える）
    // 例：初級=2、中級=3、上級=4、最上級=5
    switch (rank.toLowerCase()) {
      case '初級':
      case 'd':
      case 'e':
        return 2;
      case '中級':
      case 'c':
        return 3;
      case '上級':
      case 'b':
        return 4;
      case '最上級':
      case 'a':
        return 5;
      case 's':
      case 'ss':
        return 6;
      default:
        // デフォルトは3
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final combinedWave = _calculateCombinedWave(_playerWaves);
    final targetCombinedWave = _calculateCombinedWave(_targetWaves);
    final difference = _calculateDifference(combinedWave, targetCombinedWave);
    final successLevel = _calculateSuccessLevel(difference);

    return Scaffold(
      appBar: const CustomAppBar(
        title: '共鳴調律',
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
                      '共鳴調律',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '目標波形（合成波）を再現するため、複数の波形コンポーネントを作成して合成します。各波形コンポーネントは強度（1～3）とテンポ（ボタン押下間隔）で構成されます。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 目標波形と合成波形の比較表示（ゲーム開始後）
            if (_gameStarted) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '波形比較',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildWaveVisualization(
                        targetCombinedWave,
                        theme,
                        isTarget: true,
                        componentWaves: _targetWaves,
                        playerWave: combinedWave,
                        playerComponentWaves: _playerWaves,
                        showGrid: true,
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      // 成功度表示
                      Text(
                        '成功度',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSuccessLevelText(successLevel),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _getSuccessLevelColor(successLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '差: ${(difference * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      // 波形コンポーネント一覧
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '波形コンポーネント一覧',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '目標: ${_targetWaves.length} / あなた: ${_playerWaves.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_playerWaves.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '波形コンポーネントがありません。強度とテンポを選択して「波形を追加」ボタンを押してください。',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ..._playerWaves.asMap().entries.map((entry) {
                          final index = entry.key;
                          final wave = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Text(
                                    '波形${index + 1}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '強度: ${wave.intensity}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'テンポ: ${wave.tempo.toStringAsFixed(1)}秒',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    color: Colors.red,
                                    onPressed: () => _removeWaveAt(index),
                                    tooltip: 'この波形を削除',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 強度とテンポの選択
            if (_gameStarted && !_submitted) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '強度を選択',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [1, 2, 3].map((intensity) {
                          final isSelected = _selectedIntensity == intensity;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                label: Text('強度$intensity'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedIntensity = intensity;
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'テンポを調整',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _selectedTempo,
                        onChanged: (value) {
                          setState(() {
                            // 0.5区切りに丸める
                            _selectedTempo = (value / 0.5).round() * 0.5;
                          });
                        },
                        min: _minTempo,
                        max: _maxTempo,
                        divisions: ((_maxTempo - _minTempo) / 0.5).round(), // 0.5秒刻み
                        label: '${_selectedTempo.toStringAsFixed(1)}秒',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_minTempo.toStringAsFixed(1)}秒',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${_selectedTempo.toStringAsFixed(1)}秒',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_maxTempo.toStringAsFixed(1)}秒',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: '波形を追加',
                        onPressed: _addWave,
                        variant: ButtonVariant.primary,
                        icon: const Icon(Icons.add, size: 20),
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
                onPressed: () {
                  setState(() {
                    _gameStarted = true;
                  });
                },
                variant: ButtonVariant.primary,
              )
            else if (!_submitted)
              CustomButton(
                text: '回答を提出',
                onPressed: _playerWaves.isNotEmpty
                    ? () => _submitResult(successLevel, difference)
                    : null,
                variant: ButtonVariant.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveVisualization(
      List<double> waveData, ThemeData theme, {
      bool isTarget = false,
      List<WaveComponent>? componentWaves,
      bool showGrid = false,
      List<double>? playerWave,
      List<WaveComponent>? playerComponentWaves,
    }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: CustomPaint(
        painter: _WavePainter(
          waveData,
          isTarget,
          componentWaves: componentWaves,
          showGrid: showGrid,
          playerWave: playerWave,
          playerComponentWaves: playerComponentWaves,
        ),
        size: const Size(double.infinity, 150),
      ),
    );
  }

  void _addWave() {
    setState(() {
      _playerWaves.add(WaveComponent(
        intensity: _selectedIntensity,
        tempo: _selectedTempo, // 選択されたテンポを使用
      ));
    });
  }


  void _removeWaveAt(int index) {
    setState(() {
      if (index >= 0 && index < _playerWaves.length) {
        _playerWaves.removeAt(index);
      }
    });
  }

  /// 波形コンポーネントのリストから合成波形を計算
  List<double> _calculateCombinedWave(List<WaveComponent> waves) {
    if (waves.isEmpty) {
      return List.filled(200, 0.5); // デフォルト値（中央）
    }

    final result = List<double>.filled(200, 0.0);
    final centerY = 0.5;

    for (int i = 0; i < 200; i++) {
      double sum = 0.0;
      for (final wave in waves) {
        final x = i / 200.0;
        // 各波形コンポーネントを合成
        final amplitude = wave.intensity / 3.0 * 0.3; // 強度を振幅に変換
        sum += centerY + amplitude * sin(x * 2 * pi / wave.tempo);
      }
      // 平均を取る（複数波形の合成）
      result[i] = (sum / waves.length).clamp(0.0, 1.0);
    }

    return result;
  }

  /// 2つの波形の差を計算（0.0～1.0）
  double _calculateDifference(List<double> wave1, List<double> wave2) {
    if (wave1.length != wave2.length) return 1.0;

    double sum = 0.0;
    for (int i = 0; i < wave1.length; i++) {
      sum += (wave1[i] - wave2[i]).abs();
    }
    return sum / wave1.length;
  }

  String _calculateSuccessLevel(double difference) {
    if (difference < 0.05) return 'perfect';
    if (difference < 0.15) return 'good';
    if (difference < 0.3) return 'normal';
    return 'failure';
  }

  String _getSuccessLevelText(String level) {
    switch (level) {
      case 'perfect':
        return '完璧';
      case 'good':
        return '良好';
      case 'normal':
        return '普通';
      case 'failure':
        return '失敗';
      default:
        return '不明';
    }
  }

  Color _getSuccessLevelColor(String level) {
    switch (level) {
      case 'perfect':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'normal':
        return Colors.orange;
      case 'failure':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _submitResult(String successLevel, double difference) {
    setState(() {
      _submitted = true;
    });

    int favorabilityChange;
    switch (successLevel) {
      case 'perfect':
        favorabilityChange = 15;
        break;
      case 'good':
        favorabilityChange = 10;
        break;
      case 'normal':
        favorabilityChange = 5;
        break;
      case 'failure':
        favorabilityChange = 0;
        break;
      default:
        favorabilityChange = 0;
    }

    final List<RevealedInfo> revealedInfo = [];

    // 第二層（準公開情報）の確定
    if (successLevel != 'failure') {
      revealedInfo.add(RevealedInfo(
        type: 'resistance',
        value: '確定',
        layer: 2,
      ));
    }

    // 第三層（深掘り情報）の一部（成功度が高い場合）
    if (successLevel == 'perfect' || successLevel == 'good') {
      if (_random.nextDouble() < 0.5) {
        revealedInfo.add(RevealedInfo(
          type: 'inheritanceAptitude',
          value: '判明',
          layer: 3,
        ));
      }
    }

    final result = ResonanceTuningGameResult(
      successLevel: successLevel,
      favorabilityChange: favorabilityChange,
      revealedInfo: revealedInfo,
    );

    widget.onResult(result);
    Navigator.pop(context);
  }
}

/// 波形コンポーネント（強度とテンポを持つ）
class WaveComponent {
  final int intensity; // 強度（1～3）
  final double tempo; // テンポ（周期、秒単位）

  WaveComponent({
    required this.intensity,
    required this.tempo,
  });
}

/// 波形を描画するCustomPainter
class _WavePainter extends CustomPainter {
  final List<double> waveData;
  final bool isTarget;
  final List<WaveComponent>? componentWaves;
  final bool showGrid;
  final List<double>? playerWave;
  final List<WaveComponent>? playerComponentWaves;

  _WavePainter(
    this.waveData,
    this.isTarget, {
    this.componentWaves,
    this.showGrid = false,
    this.playerWave,
    this.playerComponentWaves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final stepX = size.width / waveData.length;

    // グリッド線を描画（背景）
    if (showGrid) {
      // 強度の横線を描画（1, 2, 3、必要に応じて4以上）
      final maxIntensity = componentWaves != null && componentWaves!.isNotEmpty
          ? componentWaves!.map((w) => w.intensity).reduce((a, b) => a > b ? a : b)
          : 3;
      
      for (int intensity = 1; intensity <= maxIntensity; intensity++) {
        final amplitude = intensity / 3.0 * size.height * 0.3;
        final yUpper = centerY - amplitude;
        final yLower = centerY + amplitude;
        
        final gridPaint = Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        
        // 上側の横線
        canvas.drawLine(
          Offset(0, yUpper),
          Offset(size.width, yUpper),
          gridPaint,
        );
        
        // 下側の横線
        canvas.drawLine(
          Offset(0, yLower),
          Offset(size.width, yLower),
          gridPaint,
        );
        
        // 強度ラベル（左側）
        final textPainter = TextPainter(
          text: TextSpan(
            text: '強度$intensity',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(4, yUpper - textPainter.height / 2));
      }
      
      // 中央線（強度0）
      final centerLinePaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        centerLinePaint,
      );
      
      // 時間軸の縦線（1秒ごとに実線、0.5秒ごとに破線）
      // waveDataは0.0-1.0の範囲を表現しているので、これを時間軸に変換
      // waveDataの1.0が5秒に相当すると仮定（十分な範囲を確保）
      const timeRange = 5.0; // 5秒
      final pixelsPerSecond = size.width / timeRange;
      
      // 0.5秒ごとに破線、1秒ごとに実線
      final halfSecondPaint = Paint()
        ..color = Colors.grey.withOpacity(0.15)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      final oneSecondPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      // 0.5秒ごとの破線を描画
      double time = 0.0;
      while (time <= timeRange) {
        final x = time * pixelsPerSecond;
        if (x <= size.width) {
          // 破線を描画（短い線分を繰り返し）
          final dashLength = 4.0;
          final gapLength = 4.0;
          double y = 0;
          while (y < size.height) {
            canvas.drawLine(
              Offset(x, y),
              Offset(x, (y + dashLength).clamp(0.0, size.height)),
              halfSecondPaint,
            );
            y += dashLength + gapLength;
          }
        }
        time += 0.5;
      }
      
      // 1秒ごとの実線を描画（破線の上に重ねる）
      time = 0.0;
      while (time <= timeRange) {
        final x = time * pixelsPerSecond;
        if (x <= size.width) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.height),
            oneSecondPaint,
          );
        }
        time += 1.0;
      }
      
      // テンポの縦線を描画（各コンポーネントの周期に基づく）
      if (componentWaves != null && componentWaves!.isNotEmpty) {
        // 各コンポーネントのテンポに基づいて縦線を描画
        final tempoLinePaints = [
          Paint()
            ..color = Colors.orange.withOpacity(0.3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
          Paint()
            ..color = Colors.purple.withOpacity(0.3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
          Paint()
            ..color = Colors.teal.withOpacity(0.3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
          Paint()
            ..color = Colors.pink.withOpacity(0.3)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        ];
        
        int paintIndex = 0;
        for (final wave in componentWaves!) {
          final paint = tempoLinePaints[paintIndex % tempoLinePaints.length];
          paintIndex++;
          
          // テンポ（周期）をピクセルに変換
          // waveDataは0.0-1.0の範囲をwaveData.lengthサンプルで表現
          // 1周期はwave.tempo * waveData.lengthサンプル
          // これをピクセルに変換: wave.tempo * waveData.length * stepX
          final periodPixels = wave.tempo * waveData.length * stepX;
          
          // 画面幅内に収まる周期の数を計算
          int lineCount = (size.width / periodPixels).ceil() + 1;
          
          for (int i = 0; i <= lineCount; i++) {
            final x = i * periodPixels;
            if (x <= size.width) {
              canvas.drawLine(
                Offset(x, 0),
                Offset(x, size.height),
                paint,
              );
            }
          }
        }
      }
    }

    // プレイヤーの各コンポーネント波形を薄く表示
    if (playerComponentWaves != null && playerComponentWaves!.isNotEmpty) {
      for (final wave in playerComponentWaves!) {
        final componentPath = Path();
        final amplitude = wave.intensity / 3.0 * size.height * 0.3;
        
        for (int i = 0; i < waveData.length; i++) {
          final x = i * stepX;
          final phase = (i / waveData.length) * 2 * pi / wave.tempo;
          final y = centerY + amplitude * sin(phase);
          
          if (i == 0) {
            componentPath.moveTo(x, y);
          } else {
            componentPath.lineTo(x, y);
          }
        }
        
        // 薄く表示（透明度0.3）
        final componentPaint = Paint()
          ..color = Colors.green.withOpacity(0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        
        canvas.drawPath(componentPath, componentPaint);
      }
    }
    
    // 目標波形（合成波形）を太く表示（青色）
    final targetPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final targetPath = Path();

    for (int i = 0; i < waveData.length; i++) {
      final x = i * stepX;
      final y = waveData[i] * size.height;

      if (i == 0) {
        targetPath.moveTo(x, y);
      } else {
        targetPath.lineTo(x, y);
      }
    }

    canvas.drawPath(targetPath, targetPaint);
    
    // プレイヤーの合成波形を太く表示（緑色、目標波形の上に重ねる）
    if (playerWave != null && playerWave!.isNotEmpty) {
      final playerPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final playerPath = Path();

      for (int i = 0; i < playerWave!.length && i < waveData.length; i++) {
        final x = i * stepX;
        final y = playerWave![i] * size.height;

        if (i == 0) {
          playerPath.moveTo(x, y);
        } else {
          playerPath.lineTo(x, y);
        }
      }

      canvas.drawPath(playerPath, playerPaint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.waveData != waveData ||
      oldDelegate.isTarget != isTarget ||
      oldDelegate.componentWaves != componentWaves ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.playerWave != playerWave ||
      oldDelegate.playerComponentWaves != playerComponentWaves;
}
