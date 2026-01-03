import 'parameter_growth_curve.dart';

class Monster {
  final String id;
  final String name;
  final String species; // 種族
  final String rank; // 位階
  final String gender; // 性別（"male"または"female"）
  final int age; // 年齢（ターン数、0が誕生時）
  final int lifespan; // 寿命（ターン数、おおむね40）
  final List<String> tags; // タグ（最大3つ）
  final String profile; // プロフィール文
  final bool locked; // ロック状態
  final List<String> skills; // 所持スキル候補
  final String geneSeed; // 遺伝子シード
  final String? image; // 画像URL（オプション）
  final List<String> items; // アイテム（知識の書、異国の記憶など）
  final Map<String, int> parameters; // パラメータ（魔力、敏捷性、魅力、攻撃力など）
  final double? individualDeviationValue; // 個体の偏差値（性別に応じた正規分布からサンプリングされた値）
  final int? charm; // 魅力値（推定または確定）
  final Map<String, ParameterGrowthCurve>? parameterGrowthCurves; // パラメータごとの成長カーブ設定

  Monster({
    required this.id,
    required this.name,
    required this.species,
    required this.rank,
    required this.gender,
    required this.age,
    required this.lifespan,
    required this.tags,
    required this.profile,
    required this.locked,
    required this.skills,
    required this.geneSeed,
    this.image,
    List<String>? items,
    Map<String, int>? parameters,
    this.individualDeviationValue,
    this.charm,
    Map<String, ParameterGrowthCurve>? parameterGrowthCurves,
  })  : items = items ?? [],
        parameters = parameters ?? {},
        parameterGrowthCurves = parameterGrowthCurves;

  // 残り寿命を計算
  int get remainingLifespan => lifespan - age;

  // 交配可能かどうか（10ターン目以降）
  bool get isBreedable => age >= 10;

  Monster copyWith({
    String? id,
    String? name,
    String? species,
    String? rank,
    String? gender,
    int? age,
    int? lifespan,
    List<String>? tags,
    String? profile,
    bool? locked,
    List<String>? skills,
    String? geneSeed,
    String? image,
    List<String>? items,
    Map<String, int>? parameters,
    double? individualDeviationValue,
    int? charm,
    Map<String, ParameterGrowthCurve>? parameterGrowthCurves,
  }) {
    return Monster(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      rank: rank ?? this.rank,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      lifespan: lifespan ?? this.lifespan,
      tags: tags ?? this.tags,
      profile: profile ?? this.profile,
      locked: locked ?? this.locked,
      skills: skills ?? this.skills,
      geneSeed: geneSeed ?? this.geneSeed,
      image: image ?? this.image,
      items: items ?? this.items,
      parameters: parameters ?? this.parameters,
      individualDeviationValue: individualDeviationValue ?? this.individualDeviationValue,
      charm: charm ?? this.charm,
      parameterGrowthCurves: parameterGrowthCurves ?? this.parameterGrowthCurves,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'rank': rank,
      'gender': gender,
      'age': age,
      'lifespan': lifespan,
      'tags': tags,
      'profile': profile,
      'locked': locked,
      'skills': skills,
      'geneSeed': geneSeed,
      'image': image,
      'items': items,
      'parameters': parameters,
      'individualDeviationValue': individualDeviationValue,
      'charm': charm,
      'parameterGrowthCurves': parameterGrowthCurves?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory Monster.fromJson(Map<String, dynamic> json) {
    Map<String, ParameterGrowthCurve>? growthCurves;
    if (json['parameterGrowthCurves'] != null) {
      growthCurves = (json['parameterGrowthCurves'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          ParameterGrowthCurve.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return Monster(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      rank: json['rank'] as String,
      gender: json['gender'] as String? ?? 'male', // デフォルト値
      age: json['age'] as int? ?? 0, // デフォルト値
      lifespan: json['lifespan'] as int? ?? 40, // デフォルト値
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      profile: json['profile'] as String,
      locked: json['locked'] as bool,
      skills: (json['skills'] as List).map((e) => e.toString()).toList(),
      geneSeed: json['geneSeed'] as String,
      image: json['image'] as String?,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => e.toString()).toList()
          : [],
      parameters: json['parameters'] != null
          ? Map<String, int>.from(json['parameters'] as Map)
          : {},
      individualDeviationValue: json['individualDeviationValue'] != null
          ? (json['individualDeviationValue'] as num).toDouble()
          : null,
      charm: json['charm'] as int?,
      parameterGrowthCurves: growthCurves,
    );
  }

  /// アイテムによるパラメータ補正を適用したパラメータを返す
  Map<String, int> getAdjustedParameters() {
    // パラメータが空の場合は空のマップを返す
    if (parameters.isEmpty) {
      return {};
    }

    final adjusted = Map<String, int>.from(parameters);

    // アイテムによる補正を適用
    if (items.isNotEmpty) {
      for (final item in items) {
        if (item.isEmpty) continue;
        
        switch (item) {
          case '知識の書':
            // 知識に関連するパラメータを強化
            adjusted['魔力'] = (adjusted['魔力'] ?? 0) + 5;
            adjusted['インテリジェンス'] = (adjusted['インテリジェンス'] ?? 0) + 10;
            adjusted['魅力'] = (adjusted['魅力'] ?? 0) + 15;
            break;
          case '異国の記憶':
            // 探索に関連するパラメータを強化
            adjusted['敏捷性'] = (adjusted['敏捷性'] ?? 0) + 15;
            adjusted['精神力'] = (adjusted['精神力'] ?? 0) + 5;
            adjusted['魅力'] = (adjusted['魅力'] ?? 0) + 10;
            break;
        }
      }
    }

    return adjusted;
  }
}

