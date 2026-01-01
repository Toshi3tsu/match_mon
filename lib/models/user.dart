class User {
  final String id;
  final String name;
  final String species; // 種族
  final String rank; // 位階
  final List<String> tags; // タグ（最大3つ）
  final String profile; // プロフィール文
  final bool locked; // ロック状態
  final List<String> skills; // 所持スキル候補
  final String geneSeed; // 遺伝子シード
  final String? image; // 画像URL（オプション）
  final List<String> items; // アイテム（大卒資格、留学経験など）
  final Map<String, int> parameters; // パラメータ（数理、言語、英語、エンジニアリング、コミュニケーション、モンスター）

  User({
    required this.id,
    required this.name,
    required this.species,
    required this.rank,
    required this.tags,
    required this.profile,
    required this.locked,
    required this.skills,
    required this.geneSeed,
    this.image,
    List<String>? items,
    Map<String, int>? parameters,
  })  : items = items ?? [],
        parameters = parameters ?? {};

  User copyWith({
    String? id,
    String? name,
    String? species,
    String? rank,
    List<String>? tags,
    String? profile,
    bool? locked,
    List<String>? skills,
    String? geneSeed,
    String? image,
    List<String>? items,
    Map<String, int>? parameters,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      rank: rank ?? this.rank,
      tags: tags ?? this.tags,
      profile: profile ?? this.profile,
      locked: locked ?? this.locked,
      skills: skills ?? this.skills,
      geneSeed: geneSeed ?? this.geneSeed,
      image: image ?? this.image,
      items: items ?? this.items,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'rank': rank,
      'tags': tags,
      'profile': profile,
      'locked': locked,
      'skills': skills,
      'geneSeed': geneSeed,
      'image': image,
      'items': items,
      'parameters': parameters,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      rank: json['rank'] as String,
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
          case '大卒資格':
            adjusted['数理'] = (adjusted['数理'] ?? 0) + 5;
            adjusted['言語'] = (adjusted['言語'] ?? 0) + 15;
            break;
          case '留学経験':
            adjusted['英語'] = (adjusted['英語'] ?? 0) + 15;
            adjusted['コミュニケーション'] = (adjusted['コミュニケーション'] ?? 0) + 10;
            break;
        }
      }
    }

    return adjusted;
  }
}

