import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/collaboration.dart';
import '../models/match_session.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../providers/app_state_provider.dart';
import 'mini_games/negotiation_game_screen.dart';
import 'mini_games/resonance_tuning_game_screen.dart';
import 'mini_games/ritual_sequence_game_screen.dart';
import 'mini_games/offering_game_screen.dart';
import 'mini_games/trial_game_screen.dart';
import 'covenant_selection_screen.dart';

/// マッチ後セッション管理画面
/// 設計書 5.5 参照
class MatchSessionScreen extends ConsumerStatefulWidget {
  final Collaboration collaboration;

  const MatchSessionScreen({
    super.key,
    required this.collaboration,
  });

  @override
  ConsumerState<MatchSessionScreen> createState() =>
      _MatchSessionScreenState();
}

class _MatchSessionScreenState extends ConsumerState<MatchSessionScreen> {
  late MatchSession session;

  @override
  void initState() {
    super.initState();
    // セッションが存在しない場合は初期化（好感度は20でスタート）
    session = widget.collaboration.session ??
        MatchSession(
          matchId: widget.collaboration.id,
          currentFavorability: 20, // マッチ後の好感度は20でスタート
          sessionState: SessionState.notStarted,
          completedGames: [],
          revealedParameters: {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'マッチ後セッション',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // パートナー情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // モンスター画像の縮小版
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.surfaceVariant,
                        child: widget.collaboration.partner.image != null
                            ? _buildMonsterImage(
                                widget.collaboration.partner.image!,
                                theme,
                              )
                            : Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.collaboration.partner.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.collaboration.partner.species} / ${widget.collaboration.partner.rank}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 好感度表示
            _buildFavorabilitySection(theme),
            const SizedBox(height: 24),

            // セッション状態
            _buildSessionStateSection(theme),
            const SizedBox(height: 24),

            // 開示された情報
            if (session.revealedParameters.isNotEmpty)
              _buildRevealedInfoSection(theme),
            if (session.revealedParameters.isNotEmpty)
              const SizedBox(height: 24),

            // アクションボタン
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  /// モンスター画像を表示するウィジェット
  Widget _buildMonsterImage(String imagePath, ThemeData theme) {
    // ローカルアセットかネットワーク画像かを判定
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          );
        },
      );
    } else {
      // ローカルアセット（assets/... で始まる）
      String assetPath = imagePath;
      if (kIsWeb) {
        // Webでは、pubspec.yamlでassets/と指定しているため、
        // コード内のパス（assets/...）からassets/プレフィックスを削除
        if (imagePath.startsWith('assets/')) {
          assetPath = imagePath.substring(7); // "assets/" の7文字を削除
        }
      }
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          );
        },
      );
    }
  }

  Widget _buildFavorabilitySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '好感度',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: session.currentFavorability / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getFavorabilityColor(session.currentFavorability),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.currentFavorability} / 100',
              style: theme.textTheme.bodyMedium,
            ),
            if (session.isFavorabilityTooLow) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '好感度が低すぎます。再交渉が必要です。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStateSection(ThemeData theme) {
    String stateText;
    IconData stateIcon;
    Color stateColor;

    switch (session.sessionState) {
      case SessionState.notStarted:
        stateText = '未開始';
        stateIcon = Icons.play_circle_outline;
        stateColor = Colors.grey;
        break;
      case SessionState.inProgress:
        stateText = '進行中';
        stateIcon = Icons.sync;
        stateColor = Colors.blue;
        break;
      case SessionState.completed:
        stateText = '完了';
        stateIcon = Icons.check_circle;
        stateColor = Colors.green;
        break;
      case SessionState.onHold:
        stateText = '契約保留中';
        stateIcon = Icons.pause_circle;
        stateColor = Colors.orange;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(stateIcon, color: stateColor),
            const SizedBox(width: 12),
            Text(
              'セッション状態: $stateText',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealedInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '開示された情報',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...session.revealedParameters.entries.map((entry) {
              final layer = entry.key;
              final infos = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第${layer}層:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...infos.map((info) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text(
                          '• ${info.type}: ${info.value}',
                          style: theme.textTheme.bodySmall,
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // セッション開始ボタン
        if (session.sessionState == SessionState.notStarted ||
            (session.sessionState == SessionState.onHold &&
                session.onHold != null &&
                session.onHold!.holdUntil != null &&
                DateTime.now().isAfter(session.onHold!.holdUntil!)))
          CustomButton(
            text: session.sessionState == SessionState.onHold
                ? '再交渉を開始'
                : 'セッションを開始',
            onPressed: () => _startSession(),
            variant: ButtonVariant.primary,
            icon: const Icon(Icons.play_arrow, size: 20),
          ),

        // 契約保留中のメッセージ
        if (session.sessionState == SessionState.onHold &&
            session.onHold != null &&
            session.onHold!.isOnHold &&
            session.onHold!.holdUntil != null &&
            DateTime.now().isBefore(session.onHold!.holdUntil!))
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pause_circle, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '契約保留中',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '好感度が低すぎるため、契約が保留されています。',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '再交渉可能: ${_formatDateTime(session.onHold!.holdUntil!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ミニゲーム実行ボタン（進行中の場合）
        if (session.sessionState == SessionState.inProgress)
          CustomButton(
            text: 'ミニゲームを実行',
            onPressed: session.canPlayNextGame
                ? () => _showMiniGameSelection()
                : null,
            variant: ButtonVariant.primary,
            icon: const Icon(Icons.play_arrow, size: 20),
          ),

        // 盟約選択ボタン
        if (session.canSelectCovenant &&
            (session.covenantState == null ||
                session.covenantState!.selectedClause == null))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CustomButton(
              text: '盟約を選択',
              onPressed: () => _showCovenantSelection(),
              variant: ButtonVariant.secondary,
              icon: const Icon(Icons.description, size: 20),
            ),
          ),

        // セッション完了ボタン
        if (session.sessionState == SessionState.inProgress &&
            session.completedGames.length >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CustomButton(
              text: 'セッションを完了',
              onPressed: () => _completeSession(),
              variant: ButtonVariant.primary,
              icon: const Icon(Icons.check, size: 20),
            ),
          ),
      ],
    );
  }

  void _startSession() {
    setState(() {
      // セッション状態を進行中に変更
      session = session.copyWith(
        sessionState: SessionState.inProgress,
        onHold: null, // 保留状態を解除
      );

      // セッションを保存
      ref.read(appStateProvider.notifier).updateSession(
            widget.collaboration.id,
            session,
          );
    });

    // ミニゲーム選択を表示
    _showMiniGameSelection();
  }

  void _showMiniGameSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MiniGameSelectionSheet(
        onGameSelected: (gameType) {
          Navigator.pop(context);
          _navigateToMiniGame(gameType);
        },
      ),
    );
  }

  void _navigateToMiniGame(MiniGameType gameType) {
    Widget screen;
    switch (gameType) {
      case MiniGameType.negotiation:
        screen = NegotiationGameScreen(
          collaboration: widget.collaboration,
          session: session,
          onResult: (result) => _handleGameResult(result),
        );
        break;
      case MiniGameType.resonanceTuning:
        screen = ResonanceTuningGameScreen(
          collaboration: widget.collaboration,
          session: session,
          onResult: (result) => _handleGameResult(result),
        );
        break;
      case MiniGameType.ritualSequence:
        screen = RitualSequenceGameScreen(
          collaboration: widget.collaboration,
          session: session,
          onResult: (result) => _handleGameResult(result),
        );
        break;
      case MiniGameType.offering:
        screen = OfferingGameScreen(
          collaboration: widget.collaboration,
          session: session,
          onResult: (result) => _handleGameResult(result),
        );
        break;
      case MiniGameType.trial:
        screen = TrialGameScreen(
          collaboration: widget.collaboration,
          session: session,
          onResult: (result) => _handleGameResult(result),
        );
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleGameResult(MiniGameResult result) {
    setState(() {
      final newFavorability =
          (session.currentFavorability + result.favorabilityChange).clamp(0, 100);

      // 開示された情報を追加
      final newRevealedParameters = Map<int, List<RevealedInfo>>.from(
          session.revealedParameters);
      for (final info in result.revealedInfo) {
        newRevealedParameters.putIfAbsent(info.layer, () => []);
        newRevealedParameters[info.layer]!.add(info);
      }

      session = session.copyWith(
        currentFavorability: newFavorability,
        sessionState: SessionState.inProgress,
        completedGames: [...session.completedGames, result],
        revealedParameters: newRevealedParameters,
      );

      // 好感度が下がり過ぎた場合
      if (session.isFavorabilityTooLow) {
        session = session.copyWith(
          sessionState: SessionState.onHold,
          onHold: SessionOnHold(
            isOnHold: true,
            holdUntil: DateTime.now().add(const Duration(hours: 24)),
            renegotiationCost: 10,
          ),
        );
      }

      // セッションを保存
      ref.read(appStateProvider.notifier).updateSession(
            widget.collaboration.id,
            session,
          );
    });

    // 結果を表示
    _showGameResultDialog(result);
  }

  void _showGameResultDialog(MiniGameResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ミニゲーム結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('好感度: ${result.favorabilityChange >= 0 ? '+' : ''}${result.favorabilityChange}'),
            if (result.revealedInfo.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('開示された情報:'),
              ...result.revealedInfo.map((info) => Text('• ${info.type}: ${info.value}')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCovenantSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CovenantSelectionScreen(
          collaboration: widget.collaboration,
          session: session,
          onClauseSelected: (clause) {
            setState(() {
              session = session.copyWith(
                covenantState: session.covenantState?.copyWith(
                  selectedClause: clause,
                ) ??
                    CovenantState(
                      availableClauses: _generateCovenantClauses(),
                      selectedClause: clause,
                    ),
              );

              // セッションを保存
              ref.read(appStateProvider.notifier).updateSession(
                    widget.collaboration.id,
                    session,
                  );
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  List<CovenantClause> _generateCovenantClauses() {
    // 好感度に応じて2〜4個の条項を生成
    final count = session.currentFavorability >= 80 ? 4 : session.currentFavorability >= 50 ? 3 : 2;
    return List.generate(count, (index) {
      final clauses = [
        CovenantClause(
          id: 'clause_${index}_1',
          name: '継承枠拡張',
          benefit: '継承枠が+1増加',
          cost: '事故率が+5%上昇',
          effects: {
            'inheritanceSlots': 1,
            'accidentRate': 0.05,
          },
        ),
        CovenantClause(
          id: 'clause_${index}_2',
          name: '確率調整',
          benefit: '狙い候補Aの確率が+20%',
          cost: '別候補Bの確率が-10%',
          effects: {
            'candidateProbabilities': {'A': 0.2, 'B': -0.1},
          },
        ),
        CovenantClause(
          id: 'clause_${index}_3',
          name: 'タグ継承安定化',
          benefit: 'タグ継承が安定',
          cost: 'スキル継承の幅が狭まる',
          effects: {
            'tagInheritanceStability': 1.0,
            'skillInheritanceRange': -0.2,
          },
        ),
        CovenantClause(
          id: 'clause_${index}_4',
          name: '事故テーブル改善',
          benefit: '事故テーブルが良化',
          cost: '継承枠が-1',
          effects: {
            'accidentTableImprovement': true,
            'inheritanceSlots': -1,
          },
        ),
      ];
      return clauses[index % clauses.length];
    });
  }

  void _completeSession() {
    setState(() {
      session = session.copyWith(
        sessionState: SessionState.completed,
      );
    });

    // セッション結果を保存（appStateProviderに反映）
    ref.read(appStateProvider.notifier).updateSession(
          widget.collaboration.id,
          session,
        );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('セッション完了'),
        content: const Text('マッチ後セッションが完了しました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getFavorabilityColor(int favorability) {
    if (favorability >= 80) return Colors.green;
    if (favorability >= 50) return Colors.blue;
    if (favorability >= 20) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MiniGameSelectionSheet extends StatelessWidget {
  final Function(MiniGameType) onGameSelected;

  const _MiniGameSelectionSheet({required this.onGameSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ミニゲームを選択',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildGameOption(
            context,
            '契約交渉',
            '会話カードで交渉',
            Icons.chat,
            MiniGameType.negotiation,
          ),
          _buildGameOption(
            context,
            '共鳴調律',
            '波形を合わせる',
            Icons.waves,
            MiniGameType.resonanceTuning,
          ),
          _buildGameOption(
            context,
            '儀式手順',
            '順序を記憶する',
            Icons.auto_awesome,
            MiniGameType.ritualSequence,
          ),
          _buildGameOption(
            context,
            '贈与/供物の調合',
            '供物を選択する',
            Icons.card_giftcard,
            MiniGameType.offering,
          ),
          _buildGameOption(
            context,
            '同行試練',
            '判断を選択する',
            Icons.psychology,
            MiniGameType.trial,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    MiniGameType gameType,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      onTap: () => onGameSelected(gameType),
    );
  }
}

