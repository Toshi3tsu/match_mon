// 世界の目的と評価指標（公共指標）
// 設計書2.1.1に基づく

// 公共指標（第一層：世界の存続に効く評価）
class PublicMetrics {
  // 封印の安定度（0.0〜1.0）
  final double sealStability;
  // 最深部への到達度（0.0〜1.0）
  final double deepestReach;
  // 瘴気（汚染）の後退率（0.0〜1.0、値が大きいほど浄化が進んでいる）
  final double miasmaRetreatRate;
  // 救助できた住民数
  final int rescuedResidents;
  // 復旧した拠点数
  final int restoredOutposts;
  // 地図の復元率（0.0〜1.0）
  final double mapRestorationRate;

  PublicMetrics({
    required this.sealStability,
    required this.deepestReach,
    required this.miasmaRetreatRate,
    required this.rescuedResidents,
    required this.restoredOutposts,
    required this.mapRestorationRate,
  });

  PublicMetrics copyWith({
    double? sealStability,
    double? deepestReach,
    double? miasmaRetreatRate,
    int? rescuedResidents,
    int? restoredOutposts,
    double? mapRestorationRate,
  }) {
    return PublicMetrics(
      sealStability: sealStability ?? this.sealStability,
      deepestReach: deepestReach ?? this.deepestReach,
      miasmaRetreatRate: miasmaRetreatRate ?? this.miasmaRetreatRate,
      rescuedResidents: rescuedResidents ?? this.rescuedResidents,
      restoredOutposts: restoredOutposts ?? this.restoredOutposts,
      mapRestorationRate: mapRestorationRate ?? this.mapRestorationRate,
    );
  }

  static PublicMetrics initial() {
    return PublicMetrics(
      sealStability: 0.3, // 初期値：30%
      deepestReach: 0.0,
      miasmaRetreatRate: 0.0,
      rescuedResidents: 0,
      restoredOutposts: 0,
      mapRestorationRate: 0.0,
    );
  }
}

// 今回の遠征（周回）の目標
class ExpeditionGoal {
  // 目標タイプ
  final ExpeditionGoalType type;
  // 目標の説明
  final String description;
  // 目標値
  final int? targetValue;
  // 現在の進捗
  final int currentProgress;
  // 達成済みかどうか
  final bool isAchieved;

  ExpeditionGoal({
    required this.type,
    required this.description,
    this.targetValue,
    required this.currentProgress,
    this.isAchieved = false,
  });

  ExpeditionGoal copyWith({
    ExpeditionGoalType? type,
    String? description,
    int? targetValue,
    int? currentProgress,
    bool? isAchieved,
  }) {
    return ExpeditionGoal(
      type: type ?? this.type,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }

  // 進捗率を取得（0.0〜1.0）
  double get progressRate {
    if (targetValue == null || targetValue == 0) return 0.0;
    return (currentProgress / targetValue!).clamp(0.0, 1.0);
  }
}

enum ExpeditionGoalType {
  reachFloor, // 階層到達
  sealRepair, // 楔の修復進捗
  rescue, // 救助数
  purify, // 浄化
  explore, // 探索
  defeatBoss, // ボス撃破
}

// 遠征の状態
class ExpeditionState {
  // 現在の遠征の目標
  final ExpeditionGoal? currentGoal;
  // 現在の階層
  final int currentFloor;
  // 最大到達階層
  final int maxFloorReached;
  // 今回の遠征で獲得した知識
  final List<String> gainedKnowledge;
  // 今回の遠征で獲得した選択肢
  final List<String> gainedChoices;
  // 今回の遠征で獲得した系譜資産
  final List<String> gainedLineageAssets;

  ExpeditionState({
    this.currentGoal,
    required this.currentFloor,
    required this.maxFloorReached,
    required this.gainedKnowledge,
    required this.gainedChoices,
    required this.gainedLineageAssets,
  });

  ExpeditionState copyWith({
    ExpeditionGoal? currentGoal,
    int? currentFloor,
    int? maxFloorReached,
    List<String>? gainedKnowledge,
    List<String>? gainedChoices,
    List<String>? gainedLineageAssets,
  }) {
    return ExpeditionState(
      currentGoal: currentGoal ?? this.currentGoal,
      currentFloor: currentFloor ?? this.currentFloor,
      maxFloorReached: maxFloorReached ?? this.maxFloorReached,
      gainedKnowledge: gainedKnowledge ?? this.gainedKnowledge,
      gainedChoices: gainedChoices ?? this.gainedChoices,
      gainedLineageAssets: gainedLineageAssets ?? this.gainedLineageAssets,
    );
  }

  static ExpeditionState initial() {
    return ExpeditionState(
      currentFloor: 0,
      maxFloorReached: 0,
      gainedKnowledge: [],
      gainedChoices: [],
      gainedLineageAssets: [],
    );
  }
}

