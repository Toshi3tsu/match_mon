// 遠征リザルト（持ち帰り・消失・継承の内訳）
// 設計書7.1.2、7.1.3に基づく

// 永続資産の型をインポート
import 'persistent_assets.dart' show BreedingRecipe, EnemyInfo, EncounterBranchCondition, ConsultationOfficeRumor, CovenantClause, BondAction, EncounterProtocol, LineageRecord;
import 'world_goals.dart' show ExpeditionGoal;

// 遠征リザルト
class ExpeditionResult {
  // 遠征ID
  final String id;
  // 遠征開始日時
  final DateTime startedAt;
  // 遠征終了日時
  final DateTime endedAt;
  // 終了理由
  final ExpeditionEndReason endReason;
  // 到達階層
  final int reachedFloor;
  // 目標達成状況
  final ExpeditionGoal? goal;
  final bool goalAchieved;

  // 持ち帰り資産
  final CarriedAssets carriedAssets;
  // 消失した資産
  final LostAssets lostAssets;
  // 継承された資産（永続資産に追加される）
  final InheritedAssets inheritedAssets;

  ExpeditionResult({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.endReason,
    required this.reachedFloor,
    this.goal,
    required this.goalAchieved,
    required this.carriedAssets,
    required this.lostAssets,
    required this.inheritedAssets,
  });
}

enum ExpeditionEndReason {
  retreat, // 撤退
  defeat, // 全滅
  goalAchieved, // 目標達成
  sealRepaired, // 楔修復完了
}

// 持ち帰り資産（次世代に引き継がれる）
class CarriedAssets {
  // 持ち帰った個体（素材として使える）
  final List<String> monsters; // Monster ID
  // 持ち帰った資源
  final Map<String, int> resources;
  // 持ち帰った知識（永続資産に追加される）
  final List<String> knowledge;
  // 持ち帰った選択肢（永続資産に追加される）
  final List<String> choices;
  // 持ち帰った系譜資産（永続資産に追加される）
  final List<String> lineageAssets;

  CarriedAssets({
    required this.monsters,
    required this.resources,
    required this.knowledge,
    required this.choices,
    required this.lineageAssets,
  });
}

// 消失した資産（今回の遠征で失われたもの）
class LostAssets {
  // 失われた個体（自キャラクター含む）
  final List<String> monsters; // Monster ID
  // 失われた資源
  final Map<String, int> resources;
  // 失われた一時的な強化
  final List<String> temporaryBuffs;

  LostAssets({
    required this.monsters,
    required this.resources,
    required this.temporaryBuffs,
  });
}

// 継承された資産（永続資産に追加される）
class InheritedAssets {
  // 知識（情報の継承）
  final List<BreedingRecipe> breedingRecipes;
  final List<EnemyInfo> enemyEncyclopedia;
  final List<EncounterBranchCondition> encounterBranchConditions;
  final List<ConsultationOfficeRumor> consultationOfficeRumors;

  // 選択肢（手段の継承）
  final List<CovenantClause> covenantClauses;
  final List<BondAction> bondActions;
  final List<EncounterProtocol> encounterProtocols;

  // 系譜資産（配合の継承）
  final List<LineageRecord> lineageRecords;
  final Map<String, double> lineageBonuses; // 種族ID -> 出現率ボーナス

  InheritedAssets({
    required this.breedingRecipes,
    required this.enemyEncyclopedia,
    required this.encounterBranchConditions,
    required this.consultationOfficeRumors,
    required this.covenantClauses,
    required this.bondActions,
    required this.encounterProtocols,
    required this.lineageRecords,
    required this.lineageBonuses,
  });
}

