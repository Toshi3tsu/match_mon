// 永続資産の3カテゴリモデル（継承の三層）

// 知識（情報の継承）
class Knowledge {
  final List<BreedingRecipe> breedingRecipes;
  final Map<String, CandidateProbability> candidateProbabilities;
  final List<AccidentCondition> accidentConditions;
  final List<DiscoveredPattern> discoveredPatterns;
  // 設計書2.1.4で追加：敵図鑑、遭遇の分岐条件、相談所の噂
  final List<EnemyInfo> enemyEncyclopedia;
  final List<EncounterBranchCondition> encounterBranchConditions;
  final List<ConsultationOfficeRumor> consultationOfficeRumors;

  Knowledge({
    required this.breedingRecipes,
    required this.candidateProbabilities,
    required this.accidentConditions,
    required this.discoveredPatterns,
    required this.enemyEncyclopedia,
    required this.encounterBranchConditions,
    required this.consultationOfficeRumors,
  });

  Knowledge copyWith({
    List<BreedingRecipe>? breedingRecipes,
    Map<String, CandidateProbability>? candidateProbabilities,
    List<AccidentCondition>? accidentConditions,
    List<DiscoveredPattern>? discoveredPatterns,
    List<EnemyInfo>? enemyEncyclopedia,
    List<EncounterBranchCondition>? encounterBranchConditions,
    List<ConsultationOfficeRumor>? consultationOfficeRumors,
  }) {
    return Knowledge(
      breedingRecipes: breedingRecipes ?? this.breedingRecipes,
      candidateProbabilities: candidateProbabilities ?? this.candidateProbabilities,
      accidentConditions: accidentConditions ?? this.accidentConditions,
      discoveredPatterns: discoveredPatterns ?? this.discoveredPatterns,
      enemyEncyclopedia: enemyEncyclopedia ?? this.enemyEncyclopedia,
      encounterBranchConditions: encounterBranchConditions ?? this.encounterBranchConditions,
      consultationOfficeRumors: consultationOfficeRumors ?? this.consultationOfficeRumors,
    );
  }
}

class BreedingRecipe {
  final String parentASpecies;
  final String parentBSpecies;
  final String resultSpecies;
  final double probability;
  final Map<String, dynamic> conditions;

  BreedingRecipe({
    required this.parentASpecies,
    required this.parentBSpecies,
    required this.resultSpecies,
    required this.probability,
    required this.conditions,
  });
}

class CandidateProbability {
  final String speciesId;
  final double baseProbability;
  final Map<String, double> conditionalProbabilities;

  CandidateProbability({
    required this.speciesId,
    required this.baseProbability,
    required this.conditionalProbabilities,
  });
}

class AccidentCondition {
  final String condition;
  final String description;
  final String? avoidanceMethod;

  AccidentCondition({
    required this.condition,
    required this.description,
    this.avoidanceMethod,
  });
}

class DiscoveredPattern {
  final String patternType;
  final String description;
  final String effect;

  DiscoveredPattern({
    required this.patternType,
    required this.description,
    required this.effect,
  });
}

// 設計書2.1.4で追加：知識の拡張
class EnemyInfo {
  final String enemyId;
  final String name;
  final List<String> weaknesses;
  final String behaviorPattern;
  final Map<String, dynamic> encounterConditions;

  EnemyInfo({
    required this.enemyId,
    required this.name,
    required this.weaknesses,
    required this.behaviorPattern,
    required this.encounterConditions,
  });
}

class EncounterBranchCondition {
  final String eventId;
  final Map<String, dynamic> conditions;
  final String description;

  EncounterBranchCondition({
    required this.eventId,
    required this.conditions,
    required this.description,
  });
}

class ConsultationOfficeRumor {
  final String rumorType;
  final String description;
  final String effect;

  ConsultationOfficeRumor({
    required this.rumorType,
    required this.description,
    required this.effect,
  });
}

// 選択肢（手段の継承）- 設計書2.1.4で追加
// 制度（相談所・契約枠・推薦枠）を含む
class Choices {
  // 制度（メタ進行の施設強化）
  final Institution institution;
  // 契約条項の追加
  final List<CovenantClause> availableCovenantClauses;
  // 解禁されたボンド行動
  final List<BondAction> unlockedBondActions;
  // 解禁された遭遇プロトコル
  final List<EncounterProtocol> unlockedEncounterProtocols;

  Choices({
    required this.institution,
    required this.availableCovenantClauses,
    required this.unlockedBondActions,
    required this.unlockedEncounterProtocols,
  });

  Choices copyWith({
    Institution? institution,
    List<CovenantClause>? availableCovenantClauses,
    List<BondAction>? unlockedBondActions,
    List<EncounterProtocol>? unlockedEncounterProtocols,
  }) {
    return Choices(
      institution: institution ?? this.institution,
      availableCovenantClauses: availableCovenantClauses ?? this.availableCovenantClauses,
      unlockedBondActions: unlockedBondActions ?? this.unlockedBondActions,
      unlockedEncounterProtocols: unlockedEncounterProtocols ?? this.unlockedEncounterProtocols,
    );
  }
}

// 制度（相談所・契約枠・推薦枠）
class Institution {
  final int consultationOfficeRank;
  final int contractSlots;
  final int recommendationSlots;
  final double candidateQualityBonus; // 0.0〜1.0
  final double rareEncounterRate; // 0.0〜1.0
  final int fixedSlotBonus;

  Institution({
    required this.consultationOfficeRank,
    required this.contractSlots,
    required this.recommendationSlots,
    required this.candidateQualityBonus,
    required this.rareEncounterRate,
    required this.fixedSlotBonus,
  });

  Institution copyWith({
    int? consultationOfficeRank,
    int? contractSlots,
    int? recommendationSlots,
    double? candidateQualityBonus,
    double? rareEncounterRate,
    int? fixedSlotBonus,
  }) {
    return Institution(
      consultationOfficeRank: consultationOfficeRank ?? this.consultationOfficeRank,
      contractSlots: contractSlots ?? this.contractSlots,
      recommendationSlots: recommendationSlots ?? this.recommendationSlots,
      candidateQualityBonus: candidateQualityBonus ?? this.candidateQualityBonus,
      rareEncounterRate: rareEncounterRate ?? this.rareEncounterRate,
      fixedSlotBonus: fixedSlotBonus ?? this.fixedSlotBonus,
    );
  }
}

// 契約条項
class CovenantClause {
  final String clauseId;
  final String name;
  final String description;
  final Map<String, dynamic> effects;

  CovenantClause({
    required this.clauseId,
    required this.name,
    required this.description,
    required this.effects,
  });
}

// ボンド行動
class BondAction {
  final String actionId;
  final String name;
  final String description;
  final Map<String, dynamic> unlockConditions;

  BondAction({
    required this.actionId,
    required this.name,
    required this.description,
    required this.unlockConditions,
  });
}

// 遭遇プロトコル
class EncounterProtocol {
  final String protocolId;
  final String name;
  final String description;
  final Map<String, dynamic> unlockConditions;

  EncounterProtocol({
    required this.protocolId,
    required this.name,
    required this.description,
    required this.unlockConditions,
  });
}

// 系譜資産（配合の継承）- 設計書2.1.4で更新
class LineageAssets {
  // 継承枠の期待値（基本値 + ボーナス）
  final int inheritanceSlotExpectation;
  // スキルスロット（基本値 + ボーナス）
  final int skillSlots;
  // 解放された特性スロット
  final List<TraitSlot> unlockedTraitSlots;
  // 事故率の改善（0.0〜1.0、値が大きいほど事故率が下がる）
  final double accidentRateImprovement;
  // 候補スキル幅の拡大（基本値 + ボーナス）
  final int candidateSkillWidth;
  // 初期タグの確定
  final List<InitialTag> initialTags;
  // 系譜記録
  final List<LineageRecord> lineageRecords;
  // 系譜による出現率ボーナス
  final Map<String, double> lineageBonuses; // 種族ID -> 出現率ボーナス

  LineageAssets({
    required this.inheritanceSlotExpectation,
    required this.skillSlots,
    required this.unlockedTraitSlots,
    required this.accidentRateImprovement,
    required this.candidateSkillWidth,
    required this.initialTags,
    required this.lineageRecords,
    required this.lineageBonuses,
  });

  LineageAssets copyWith({
    int? inheritanceSlotExpectation,
    int? skillSlots,
    List<TraitSlot>? unlockedTraitSlots,
    double? accidentRateImprovement,
    int? candidateSkillWidth,
    List<InitialTag>? initialTags,
    List<LineageRecord>? lineageRecords,
    Map<String, double>? lineageBonuses,
  }) {
    return LineageAssets(
      inheritanceSlotExpectation: inheritanceSlotExpectation ?? this.inheritanceSlotExpectation,
      skillSlots: skillSlots ?? this.skillSlots,
      unlockedTraitSlots: unlockedTraitSlots ?? this.unlockedTraitSlots,
      accidentRateImprovement: accidentRateImprovement ?? this.accidentRateImprovement,
      candidateSkillWidth: candidateSkillWidth ?? this.candidateSkillWidth,
      initialTags: initialTags ?? this.initialTags,
      lineageRecords: lineageRecords ?? this.lineageRecords,
      lineageBonuses: lineageBonuses ?? this.lineageBonuses,
    );
  }
}

// 特性スロット
class TraitSlot {
  final String slotId;
  final String name;
  final String description;

  TraitSlot({
    required this.slotId,
    required this.name,
    required this.description,
  });
}

class InitialTag {
  final String tag;
  final bool confirmed;

  InitialTag({
    required this.tag,
    required this.confirmed,
  });
}

class LineageRecord {
  final String parentAId;
  final String parentBId;
  final String resultSpecies;
  final DateTime establishedAt;
  final List<String> tags;

  LineageRecord({
    required this.parentAId,
    required this.parentBId,
    required this.resultSpecies,
    required this.establishedAt,
    required this.tags,
  });
}

// 永続資産全体（継承の三層）
class PersistentAssets {
  final Knowledge knowledge; // 知識（情報の継承）
  final Choices choices; // 選択肢（手段の継承）
  final LineageAssets lineageAssets; // 系譜資産（配合の継承）

  PersistentAssets({
    required this.knowledge,
    required this.choices,
    required this.lineageAssets,
  });

  PersistentAssets copyWith({
    Knowledge? knowledge,
    Choices? choices,
    LineageAssets? lineageAssets,
  }) {
    return PersistentAssets(
      knowledge: knowledge ?? this.knowledge,
      choices: choices ?? this.choices,
      lineageAssets: lineageAssets ?? this.lineageAssets,
    );
  }

  // 後方互換性のためのゲッター（既存コードとの互換性を保つ）
  Institution get institution => choices.institution;
  LineageCore get lineageCore => LineageCore(
    inheritanceSlots: lineageAssets.inheritanceSlotExpectation,
    skillSlots: lineageAssets.skillSlots,
    initialTags: lineageAssets.initialTags,
    lineageRecords: lineageAssets.lineageRecords,
    lineageBonuses: lineageAssets.lineageBonuses,
  );

  // 初期値
  static PersistentAssets initial() {
    return PersistentAssets(
      knowledge: Knowledge(
        breedingRecipes: [],
        candidateProbabilities: {},
        accidentConditions: [],
        discoveredPatterns: [],
        enemyEncyclopedia: [],
        encounterBranchConditions: [],
        consultationOfficeRumors: [],
      ),
      choices: Choices(
        institution: Institution(
          consultationOfficeRank: 1,
          contractSlots: 2,
          recommendationSlots: 1,
          candidateQualityBonus: 0.0,
          rareEncounterRate: 0.0,
          fixedSlotBonus: 0,
        ),
        availableCovenantClauses: [],
        unlockedBondActions: [],
        unlockedEncounterProtocols: [],
      ),
      lineageAssets: LineageAssets(
        inheritanceSlotExpectation: 3, // 基本値
        skillSlots: 2, // 基本値
        unlockedTraitSlots: [],
        accidentRateImprovement: 0.0,
        candidateSkillWidth: 2, // 基本値
        initialTags: [],
        lineageRecords: [],
        lineageBonuses: {},
      ),
    );
  }
}

// 後方互換性のためのLineageCoreクラス（既存コードとの互換性を保つ）
class LineageCore {
  final int inheritanceSlots;
  final int skillSlots;
  final List<InitialTag> initialTags;
  final List<LineageRecord> lineageRecords;
  final Map<String, double> lineageBonuses;

  LineageCore({
    required this.inheritanceSlots,
    required this.skillSlots,
    required this.initialTags,
    required this.lineageRecords,
    required this.lineageBonuses,
  });
}

