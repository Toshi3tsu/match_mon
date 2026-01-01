/// パラメータの4層構造を定義
/// 設計書 5.2.0, 8.2 参照

import 'monster.dart';

/// 第一層：公開情報（最初から開示）
class PublicInfo {
  final String species; // 種族
  final String tier; // 位階
  final String role; // ロール
  final List<String> mainTags; // 主要タグ2〜3個
  final List<String> fatalRejections; // 致命的な拒否条件

  PublicInfo({
    required this.species,
    required this.tier,
    required this.role,
    required this.mainTags,
    required this.fatalRejections,
  });

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'tier': tier,
      'role': role,
      'mainTags': mainTags,
      'fatalRejections': fatalRejections,
    };
  }

  factory PublicInfo.fromJson(Map<String, dynamic> json) {
    return PublicInfo(
      species: json['species'] as String,
      tier: json['tier'] as String,
      role: json['role'] as String,
      mainTags: (json['mainTags'] as List).map((e) => e.toString()).toList(),
      fatalRejections: (json['fatalRejections'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// 第二層：準公開情報（推定表示）
class EstimatedInfo {
  final List<ResistanceEstimate> resistances; // 耐性の推定値
  final List<ResistanceEstimate> weaknesses; // 弱点の推定値
  final InheritanceAptitude inheritanceAptitude; // 継承の得意分野
  final String? passiveTendency; // パッシブ傾向

  EstimatedInfo({
    required this.resistances,
    required this.weaknesses,
    required this.inheritanceAptitude,
    this.passiveTendency,
  });

  Map<String, dynamic> toJson() {
    return {
      'resistances': resistances.map((e) => e.toJson()).toList(),
      'weaknesses': weaknesses.map((e) => e.toJson()).toList(),
      'inheritanceAptitude': inheritanceAptitude.toJson(),
      'passiveTendency': passiveTendency,
    };
  }

  factory EstimatedInfo.fromJson(Map<String, dynamic> json) {
    return EstimatedInfo(
      resistances: (json['resistances'] as List)
          .map((e) => ResistanceEstimate.fromJson(e as Map<String, dynamic>))
          .toList(),
      weaknesses: (json['weaknesses'] as List)
          .map((e) => ResistanceEstimate.fromJson(e as Map<String, dynamic>))
          .toList(),
      inheritanceAptitude: InheritanceAptitude.fromJson(
          json['inheritanceAptitude'] as Map<String, dynamic>),
      passiveTendency: json['passiveTendency'] as String?,
    );
  }
}

class ResistanceEstimate {
  final String type; // "ice", "fire"など
  final String value; // "likely", "possible", "unlikely"
  final bool confirmed; // 確定したか

  ResistanceEstimate({
    required this.type,
    required this.value,
    required this.confirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'confirmed': confirmed,
    };
  }

  factory ResistanceEstimate.fromJson(Map<String, dynamic> json) {
    return ResistanceEstimate(
      type: json['type'] as String,
      value: json['value'] as String,
      confirmed: json['confirmed'] as bool,
    );
  }
}

class InheritanceAptitude {
  final String support; // "high", "medium", "low"
  final String attack; // "high", "medium", "low"
  final bool confirmed; // 確定したか

  InheritanceAptitude({
    required this.support,
    required this.attack,
    required this.confirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'support': support,
      'attack': attack,
      'confirmed': confirmed,
    };
  }

  factory InheritanceAptitude.fromJson(Map<String, dynamic> json) {
    return InheritanceAptitude(
      support: json['support'] as String,
      attack: json['attack'] as String,
      confirmed: json['confirmed'] as bool,
    );
  }
}

/// 第三層：深掘り情報
class DeepInfo {
  final List<String> hiddenTags; // 隠しタグ
  final List<String> accidentAffectingTraits; // 事故率に影響する気質
  final List<String> highRareSkillCandidates; // 継承候補スキルの上位枠
  final List<String> specialBreedingHints; // 特殊配合のヒント
  final List<String> trueNameFragments; // 真名の断片

  DeepInfo({
    required this.hiddenTags,
    required this.accidentAffectingTraits,
    required this.highRareSkillCandidates,
    required this.specialBreedingHints,
    required this.trueNameFragments,
  });

  Map<String, dynamic> toJson() {
    return {
      'hiddenTags': hiddenTags,
      'accidentAffectingTraits': accidentAffectingTraits,
      'highRareSkillCandidates': highRareSkillCandidates,
      'specialBreedingHints': specialBreedingHints,
      'trueNameFragments': trueNameFragments,
    };
  }

  factory DeepInfo.fromJson(Map<String, dynamic> json) {
    return DeepInfo(
      hiddenTags: (json['hiddenTags'] as List).map((e) => e.toString()).toList(),
      accidentAffectingTraits: (json['accidentAffectingTraits'] as List)
          .map((e) => e.toString())
          .toList(),
      highRareSkillCandidates: (json['highRareSkillCandidates'] as List)
          .map((e) => e.toString())
          .toList(),
      specialBreedingHints: (json['specialBreedingHints'] as List)
          .map((e) => e.toString())
          .toList(),
      trueNameFragments: (json['trueNameFragments'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// 第四層：サプライズ情報
class SurpriseInfo {
  final int covenantBonus; // 盟約条項の追加数（0または1）
  final int inheritanceSlotBonus; // 継承枠の一時的増加（0または1）
  final bool accidentTableImprovement; // 事故テーブルが良化したか
  final String? specialInheritancePattern; // 特殊な継承パターンの解放

  SurpriseInfo({
    required this.covenantBonus,
    required this.inheritanceSlotBonus,
    required this.accidentTableImprovement,
    this.specialInheritancePattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'covenantBonus': covenantBonus,
      'inheritanceSlotBonus': inheritanceSlotBonus,
      'accidentTableImprovement': accidentTableImprovement,
      'specialInheritancePattern': specialInheritancePattern,
    };
  }

  factory SurpriseInfo.fromJson(Map<String, dynamic> json) {
    return SurpriseInfo(
      covenantBonus: json['covenantBonus'] as int,
      inheritanceSlotBonus: json['inheritanceSlotBonus'] as int,
      accidentTableImprovement: json['accidentTableImprovement'] as bool,
      specialInheritancePattern: json['specialInheritancePattern'] as String?,
    );
  }
}

/// モンスターのパラメータ情報（4層構造）
class MonsterParameters {
  final PublicInfo publicInfo;
  final EstimatedInfo estimatedInfo;
  final DeepInfo deepInfo;
  final SurpriseInfo surpriseInfo;

  MonsterParameters({
    required this.publicInfo,
    required this.estimatedInfo,
    required this.deepInfo,
    required this.surpriseInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'publicInfo': publicInfo.toJson(),
      'estimatedInfo': estimatedInfo.toJson(),
      'deepInfo': deepInfo.toJson(),
      'surpriseInfo': surpriseInfo.toJson(),
    };
  }

  factory MonsterParameters.fromJson(Map<String, dynamic> json) {
    return MonsterParameters(
      publicInfo: PublicInfo.fromJson(json['publicInfo'] as Map<String, dynamic>),
      estimatedInfo: EstimatedInfo.fromJson(
          json['estimatedInfo'] as Map<String, dynamic>),
      deepInfo: DeepInfo.fromJson(json['deepInfo'] as Map<String, dynamic>),
      surpriseInfo:
          SurpriseInfo.fromJson(json['surpriseInfo'] as Map<String, dynamic>),
    );
  }

  /// Monsterから初期パラメータを生成
  factory MonsterParameters.fromMonster(Monster monster) {
    return MonsterParameters(
      publicInfo: PublicInfo(
        species: monster.species,
        tier: monster.rank,
        role: _determineRole(monster),
        mainTags: monster.tags.take(3).toList(),
        fatalRejections: [], // 初期値は空、後で設定
      ),
      estimatedInfo: EstimatedInfo(
        resistances: [],
        weaknesses: [],
        inheritanceAptitude: InheritanceAptitude(
          support: 'medium',
          attack: 'medium',
          confirmed: false,
        ),
        passiveTendency: null,
      ),
      deepInfo: DeepInfo(
        hiddenTags: [],
        accidentAffectingTraits: [],
        highRareSkillCandidates: [],
        specialBreedingHints: [],
        trueNameFragments: [],
      ),
      surpriseInfo: SurpriseInfo(
        covenantBonus: 0,
        inheritanceSlotBonus: 0,
        accidentTableImprovement: false,
        specialInheritancePattern: null,
      ),
    );
  }

  static String _determineRole(Monster monster) {
    // タグからロールを推定
    if (monster.tags.any((tag) => tag.contains('攻撃') || tag.contains('アタッカー'))) {
      return 'アタッカー';
    }
    if (monster.tags.any((tag) => tag.contains('支援') || tag.contains('サポート'))) {
      return 'サポート';
    }
    if (monster.tags.any((tag) => tag.contains('防御') || tag.contains('タンク'))) {
      return 'タンク';
    }
    return 'バランス';
  }
}

