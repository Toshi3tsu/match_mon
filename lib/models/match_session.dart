/// マッチ後セッション（ミニゲームによる好感度とパラメータ開示）
/// 設計書 5.5, 8.3 参照

/// セッション全体の状態
enum SessionState {
  notStarted, // 未開始
  inProgress, // 進行中
  completed, // 完了
  onHold, // 契約保留中
}

/// ミニゲームの種類
enum MiniGameType {
  negotiation, // 契約交渉（会話カード）型
  resonanceTuning, // 共鳴調律（パズル）型
  ritualSequence, // 儀式手順（記憶・順序）型
  offering, // 贈与/供物の調合（選択）型
  trial, // 同行試練（短い判断）型
}

/// 開示された情報
class RevealedInfo {
  final String type; // "resistance", "weakness", "tag"など
  final String value; // 値
  final int layer; // 2, 3, 4

  RevealedInfo({
    required this.type,
    required this.value,
    required this.layer,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'layer': layer,
    };
  }

  factory RevealedInfo.fromJson(Map<String, dynamic> json) {
    return RevealedInfo(
      type: json['type'] as String,
      value: json['value'] as String,
      layer: json['layer'] as int,
    );
  }
}

/// ミニゲームの結果（基底クラス）
abstract class MiniGameResult {
  final MiniGameType gameType;
  final int favorabilityChange; // 好感度の変化
  final List<RevealedInfo> revealedInfo; // 開示された情報

  MiniGameResult({
    required this.gameType,
    required this.favorabilityChange,
    required this.revealedInfo,
  });

  Map<String, dynamic> toJson();
}

/// 契約交渉（会話カード）型の結果
class NegotiationGameResult extends MiniGameResult {
  final String selectedCard; // "condition", "benefit", "concession", "question"

  NegotiationGameResult({
    required this.selectedCard,
    required super.favorabilityChange,
    required super.revealedInfo,
  }) : super(gameType: MiniGameType.negotiation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'selectedCard': selectedCard,
      'favorabilityChange': favorabilityChange,
      'revealedInfo': revealedInfo.map((e) => e.toJson()).toList(),
    };
  }
}

/// 共鳴調律（パズル）型の結果
class ResonanceTuningGameResult extends MiniGameResult {
  final String successLevel; // "perfect", "good", "normal", "failure"

  ResonanceTuningGameResult({
    required this.successLevel,
    required super.favorabilityChange,
    required super.revealedInfo,
  }) : super(gameType: MiniGameType.resonanceTuning);

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'successLevel': successLevel,
      'favorabilityChange': favorabilityChange,
      'revealedInfo': revealedInfo.map((e) => e.toJson()).toList(),
    };
  }
}

/// 儀式手順（記憶・順序）型の結果
class RitualSequenceGameResult extends MiniGameResult {
  final bool success; // 成功したか
  final String? trueNameFragment; // 獲得した真名の断片（成功時のみ）
  final String? hintForNext; // 次回のヒント（失敗時のみ）

  RitualSequenceGameResult({
    required this.success,
    this.trueNameFragment,
    this.hintForNext,
    required super.favorabilityChange,
    required super.revealedInfo,
  }) : super(gameType: MiniGameType.ritualSequence);

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'success': success,
      'trueNameFragment': trueNameFragment,
      'hintForNext': hintForNext,
      'favorabilityChange': favorabilityChange,
      'revealedInfo': revealedInfo.map((e) => e.toJson()).toList(),
    };
  }
}

/// 贈与/供物の調合（選択）型の結果
class OfferingGameResult extends MiniGameResult {
  final List<String> selectedOfferings; // 選択した供物のID（2つ）
  final bool preferenceMatch; // 嗜好に合致したか

  OfferingGameResult({
    required this.selectedOfferings,
    required this.preferenceMatch,
    required super.favorabilityChange,
    required super.revealedInfo,
  }) : super(gameType: MiniGameType.offering);

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'selectedOfferings': selectedOfferings,
      'preferenceMatch': preferenceMatch,
      'favorabilityChange': favorabilityChange,
      'revealedInfo': revealedInfo.map((e) => e.toJson()).toList(),
    };
  }
}

/// 同行試練（短い判断）型の結果
class TrialGameResult extends MiniGameResult {
  final String situation; // 状況説明
  final String selectedJudgment; // 選択した判断
  final bool valueMatch; // 価値観に合致したか

  TrialGameResult({
    required this.situation,
    required this.selectedJudgment,
    required this.valueMatch,
    required super.favorabilityChange,
    required super.revealedInfo,
  }) : super(gameType: MiniGameType.trial);

  @override
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'situation': situation,
      'selectedJudgment': selectedJudgment,
      'valueMatch': valueMatch,
      'favorabilityChange': favorabilityChange,
      'revealedInfo': revealedInfo.map((e) => e.toJson()).toList(),
    };
  }
}

/// 盟約条項
class CovenantClause {
  final String id;
  final String name;
  final String benefit; // メリット
  final String cost; // デメリット
  final Map<String, dynamic> effects; // プランナーへの影響

  CovenantClause({
    required this.id,
    required this.name,
    required this.benefit,
    required this.cost,
    required this.effects,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'benefit': benefit,
      'cost': cost,
      'effects': effects,
    };
  }

  factory CovenantClause.fromJson(Map<String, dynamic> json) {
    return CovenantClause(
      id: json['id'] as String,
      name: json['name'] as String,
      benefit: json['benefit'] as String,
      cost: json['cost'] as String,
      effects: json['effects'] as Map<String, dynamic>,
    );
  }
}

/// 盟約（コミット）の状態
class CovenantState {
  final List<CovenantClause> availableClauses; // 利用可能な条項
  final CovenantClause? selectedClause; // 選択した条項

  CovenantState({
    required this.availableClauses,
    this.selectedClause,
  });

  CovenantState copyWith({
    List<CovenantClause>? availableClauses,
    CovenantClause? selectedClause,
  }) {
    return CovenantState(
      availableClauses: availableClauses ?? this.availableClauses,
      selectedClause: selectedClause ?? this.selectedClause,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableClauses': availableClauses.map((e) => e.toJson()).toList(),
      'selectedClause': selectedClause?.toJson(),
    };
  }

  factory CovenantState.fromJson(Map<String, dynamic> json) {
    return CovenantState(
      availableClauses: (json['availableClauses'] as List)
          .map((e) => CovenantClause.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedClause: json['selectedClause'] != null
          ? CovenantClause.fromJson(
              json['selectedClause'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 契約保留の状態
class SessionOnHold {
  final bool isOnHold; // 契約保留中か
  final DateTime? holdUntil; // 再交渉可能になる日時
  final int renegotiationCost; // 再交渉に必要な好感度の閾値増加

  SessionOnHold({
    required this.isOnHold,
    this.holdUntil,
    required this.renegotiationCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'isOnHold': isOnHold,
      'holdUntil': holdUntil?.toIso8601String(),
      'renegotiationCost': renegotiationCost,
    };
  }

  factory SessionOnHold.fromJson(Map<String, dynamic> json) {
    return SessionOnHold(
      isOnHold: json['isOnHold'] as bool,
      holdUntil: json['holdUntil'] != null
          ? DateTime.parse(json['holdUntil'] as String)
          : null,
      renegotiationCost: json['renegotiationCost'] as int,
    );
  }
}

/// マッチ後セッション全体
class MatchSession {
  final String matchId; // マッチID
  final int currentFavorability; // 現在の好感度
  final SessionState sessionState; // セッション状態
  final List<MiniGameResult> completedGames; // 完了したミニゲームの記録
  final Map<int, List<RevealedInfo>> revealedParameters; // 開示されたパラメータ（layer2, layer3, layer4）
  final CovenantState? covenantState; // 盟約の状態
  final SessionOnHold? onHold; // 契約保留の状態

  MatchSession({
    required this.matchId,
    required this.currentFavorability,
    required this.sessionState,
    required this.completedGames,
    required this.revealedParameters,
    this.covenantState,
    this.onHold,
  });

  MatchSession copyWith({
    String? matchId,
    int? currentFavorability,
    SessionState? sessionState,
    List<MiniGameResult>? completedGames,
    Map<int, List<RevealedInfo>>? revealedParameters,
    CovenantState? covenantState,
    SessionOnHold? onHold,
  }) {
    return MatchSession(
      matchId: matchId ?? this.matchId,
      currentFavorability: currentFavorability ?? this.currentFavorability,
      sessionState: sessionState ?? this.sessionState,
      completedGames: completedGames ?? this.completedGames,
      revealedParameters: revealedParameters ?? this.revealedParameters,
      covenantState: covenantState ?? this.covenantState,
      onHold: onHold ?? this.onHold,
    );
  }

  /// 好感度が下がり過ぎたかチェック（閾値: 20）
  bool get isFavorabilityTooLow => currentFavorability < 20;

  /// 次のミニゲームを実行可能かチェック
  bool get canPlayNextGame {
    // セッション未開始の場合は開始可能
    if (sessionState == SessionState.notStarted) return true;
    // 進行中で好感度が低すぎる場合は不可
    if (sessionState == SessionState.inProgress && isFavorabilityTooLow) return false;
    // 進行中で好感度が十分な場合は可能
    if (sessionState == SessionState.inProgress) return true;
    // その他の状態は不可
    return false;
  }

  /// セッションを開始可能かチェック
  bool get canStartSession {
    // 契約保留中で再交渉可能な場合は開始可能
    if (sessionState == SessionState.onHold) {
      if (onHold != null && onHold!.isOnHold) {
        if (onHold!.holdUntil != null && DateTime.now().isAfter(onHold!.holdUntil!)) {
          return true; // 再交渉可能
        }
        return false; // まだ保留中
      }
    }
    // 未開始の場合は開始可能
    if (sessionState == SessionState.notStarted) return true;
    // その他の状態は開始不可
    return false;
  }

  /// 盟約を選択可能かチェック（好感度が50以上）
  bool get canSelectCovenant => currentFavorability >= 50;

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'currentFavorability': currentFavorability,
      'sessionState': sessionState.toString(),
      'completedGames': completedGames.map((e) => e.toJson()).toList(),
      'revealedParameters': revealedParameters.map((key, value) => MapEntry(
          key.toString(), value.map((e) => e.toJson()).toList())),
      'covenantState': covenantState?.toJson(),
      'onHold': onHold?.toJson(),
    };
  }

  factory MatchSession.fromJson(Map<String, dynamic> json) {
    // MiniGameResultの復元は簡略化（実際の実装では型に応じて適切に復元）
    return MatchSession(
      matchId: json['matchId'] as String,
      currentFavorability: json['currentFavorability'] as int,
      sessionState: SessionState.values.firstWhere(
        (e) => e.toString() == json['sessionState'],
        orElse: () => SessionState.notStarted,
      ),
      completedGames: [], // 簡略化
      revealedParameters: (json['revealedParameters'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(
                  int.parse(key),
                  (value as List)
                      .map((e) => RevealedInfo.fromJson(e as Map<String, dynamic>))
                      .toList())) ??
          {},
      covenantState: json['covenantState'] != null
          ? CovenantState.fromJson(json['covenantState'] as Map<String, dynamic>)
          : null,
      onHold: json['onHold'] != null
          ? SessionOnHold.fromJson(json['onHold'] as Map<String, dynamic>)
          : null,
    );
  }
}

