import 'monster.dart';

class ProductionPlan {
  final Monster? parentA;
  final Monster? parentB;
  final ProductionPreview? preview;

  ProductionPlan({
    this.parentA,
    this.parentB,
    this.preview,
  });

  ProductionPlan copyWith({
    Monster? parentA,
    Monster? parentB,
    ProductionPreview? preview,
  }) {
    return ProductionPlan(
      parentA: parentA ?? this.parentA,
      parentB: parentB ?? this.parentB,
      preview: preview ?? this.preview,
    );
  }
}

class ProductionPreview {
  final String childSpecies;
  final String childRank;
  final List<String> childTags;
  final int inheritanceSlots;
  final List<String> candidateSkills;
  final int accidentRate;
  final List<String>? conditions; // 確定させる条件
  final double? probability; // 確率（複数候補がある場合）

  ProductionPreview({
    required this.childSpecies,
    required this.childRank,
    required this.childTags,
    required this.inheritanceSlots,
    required this.candidateSkills,
    required this.accidentRate,
    this.conditions,
    this.probability,
  });
}

class ProductionResult {
  final String id;
  final Monster parentA;
  final Monster parentB;
  final Monster child;
  final int bond;
  final DateTime createdAt;
  final String reason; // 結果の説明
  final Inheritance inheritance;

  ProductionResult({
    required this.id,
    required this.parentA,
    required this.parentB,
    required this.child,
    required this.bond,
    required this.createdAt,
    required this.reason,
    required this.inheritance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentA': parentA.toJson(),
      'parentB': parentB.toJson(),
      'child': child.toJson(),
      'bond': bond,
      'createdAt': createdAt.toIso8601String(),
      'reason': reason,
      'inheritance': {
        'slots': inheritance.slots,
        'skills': inheritance.skills,
      },
    };
  }

  factory ProductionResult.fromJson(Map<String, dynamic> json) {
    return ProductionResult(
      id: json['id'] as String,
      parentA: Monster.fromJson(json['parentA'] as Map<String, dynamic>),
      parentB: Monster.fromJson(json['parentB'] as Map<String, dynamic>),
      child: Monster.fromJson(json['child'] as Map<String, dynamic>),
      bond: json['bond'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reason: json['reason'] as String,
      inheritance: Inheritance(
        slots: (json['inheritance'] as Map)['slots'] as int,
        skills: ((json['inheritance'] as Map)['skills'] as List)
            .map((e) => e.toString())
            .toList(),
      ),
    );
  }
}

class Inheritance {
  final int slots;
  final List<String> skills;

  Inheritance({
    required this.slots,
    required this.skills,
  });
}

class Compatibility {
  final CompatibilityLevel level;
  final String reason;
  final List<String> matchingTags;
  final List<String> complementaryTags;
  final List<String> conflictingTags;

  Compatibility({
    required this.level,
    required this.reason,
    required this.matchingTags,
    required this.complementaryTags,
    required this.conflictingTags,
  });
}

enum CompatibilityLevel {
  high,
  medium,
  low,
}

