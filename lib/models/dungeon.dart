// 深層ダンジョン探索のデータモデル

enum NodeType {
  combat, // 戦闘ノード
  event, // イベントノード
  rest, // 休息ノード
  contract, // 契約ノード（ダンジョン内マッチング）
  refinement, // 精錬ノード
}

enum RewardCategory {
  resource, // 資源
  information, // 情報
  lineageMaterial, // 系譜素材
  contractClause, // 契約条項
}

enum DangerLevel {
  low, // 低
  medium, // 中
  high, // 高
}

// ダンジョンノード（部屋）
class DungeonNode {
  final String id;
  final NodeType type;
  final String name;
  final String description;
  final RewardCategory rewardCategory;
  final DangerLevel dangerLevel;
  final Boss? boss; // 戦闘ノードの場合のボス
  final List<String> recommendedTags;
  final List<String> recommendedResistances;
  final List<String> recommendedRoles;
  final List<String> nextNodeIds; // 次のノードへの接続

  DungeonNode({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.rewardCategory,
    required this.dangerLevel,
    this.boss,
    required this.recommendedTags,
    required this.recommendedResistances,
    required this.recommendedRoles,
    required this.nextNodeIds,
  });

  DungeonNode copyWith({
    String? id,
    NodeType? type,
    String? name,
    String? description,
    RewardCategory? rewardCategory,
    DangerLevel? dangerLevel,
    Boss? boss,
    List<String>? recommendedTags,
    List<String>? recommendedResistances,
    List<String>? recommendedRoles,
    List<String>? nextNodeIds,
  }) {
    return DungeonNode(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      rewardCategory: rewardCategory ?? this.rewardCategory,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      boss: boss ?? this.boss,
      recommendedTags: recommendedTags ?? this.recommendedTags,
      recommendedResistances: recommendedResistances ?? this.recommendedResistances,
      recommendedRoles: recommendedRoles ?? this.recommendedRoles,
      nextNodeIds: nextNodeIds ?? this.nextNodeIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'description': description,
      'rewardCategory': rewardCategory.toString(),
      'dangerLevel': dangerLevel.toString(),
      'boss': boss?.toJson(),
      'recommendedTags': recommendedTags,
      'recommendedResistances': recommendedResistances,
      'recommendedRoles': recommendedRoles,
      'nextNodeIds': nextNodeIds,
    };
  }

  factory DungeonNode.fromJson(Map<String, dynamic> json) {
    return DungeonNode(
      id: json['id'] as String,
      type: NodeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NodeType.combat,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      rewardCategory: RewardCategory.values.firstWhere(
        (e) => e.toString() == json['rewardCategory'],
        orElse: () => RewardCategory.resource,
      ),
      dangerLevel: DangerLevel.values.firstWhere(
        (e) => e.toString() == json['dangerLevel'],
        orElse: () => DangerLevel.medium,
      ),
      boss: json['boss'] != null
          ? Boss.fromJson(json['boss'] as Map<String, dynamic>)
          : null,
      recommendedTags: (json['recommendedTags'] as List).map((e) => e.toString()).toList(),
      recommendedResistances: (json['recommendedResistances'] as List).map((e) => e.toString()).toList(),
      recommendedRoles: (json['recommendedRoles'] as List).map((e) => e.toString()).toList(),
      nextNodeIds: (json['nextNodeIds'] as List).map((e) => e.toString()).toList(),
    );
  }
}

// 道中ボス
class Boss {
  final String id;
  final String name;
  final String species;
  final String rank;
  final List<String> tags;
  final String profile;
  final int level;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;
  final List<String> threatProfile; // 脅威プロファイル（例: ["状態異常", "単体高火力"]）
  final String? image;

  Boss({
    required this.id,
    required this.name,
    required this.species,
    required this.rank,
    required this.tags,
    required this.profile,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.threatProfile,
    this.image,
  });

  Boss copyWith({
    String? id,
    String? name,
    String? species,
    String? rank,
    List<String>? tags,
    String? profile,
    int? level,
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
    int? speed,
    List<String>? threatProfile,
    String? image,
  }) {
    return Boss(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      rank: rank ?? this.rank,
      tags: tags ?? this.tags,
      profile: profile ?? this.profile,
      level: level ?? this.level,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      threatProfile: threatProfile ?? this.threatProfile,
      image: image ?? this.image,
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
      'level': level,
      'hp': hp,
      'maxHp': maxHp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'threatProfile': threatProfile,
      'image': image,
    };
  }

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      rank: json['rank'] as String,
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      profile: json['profile'] as String,
      level: json['level'] as int,
      hp: json['hp'] as int,
      maxHp: json['maxHp'] as int,
      attack: json['attack'] as int,
      defense: json['defense'] as int,
      speed: json['speed'] as int,
      threatProfile: (json['threatProfile'] as List).map((e) => e.toString()).toList(),
      image: json['image'] as String?,
    );
  }
}

// 探索状態（HUD用）
class ExplorationHUD {
  final int hp; // 生存資源：HP
  final int maxHp;
  final int recoveryCount; // 回復回数
  final int stress; // 継続リスク：ストレス/汚染/崩壊度
  final int maxStress;
  final Map<String, int> securedAssets; // 持ち帰り資産："銀行に入った"分
  final Map<String, int> unsecuredAssets; // 持ち帰り資産："未精算で落とす"分

  ExplorationHUD({
    required this.hp,
    required this.maxHp,
    required this.recoveryCount,
    required this.stress,
    required this.maxStress,
    required this.securedAssets,
    required this.unsecuredAssets,
  });

  ExplorationHUD copyWith({
    int? hp,
    int? maxHp,
    int? recoveryCount,
    int? stress,
    int? maxStress,
    Map<String, int>? securedAssets,
    Map<String, int>? unsecuredAssets,
  }) {
    return ExplorationHUD(
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      recoveryCount: recoveryCount ?? this.recoveryCount,
      stress: stress ?? this.stress,
      maxStress: maxStress ?? this.maxStress,
      securedAssets: securedAssets ?? this.securedAssets,
      unsecuredAssets: unsecuredAssets ?? this.unsecuredAssets,
    );
  }
}

// 深層ダンジョン探索の状態
class DungeonExplorationState {
  final String? currentNodeId; // 現在のノードID
  final Map<String, DungeonNode> nodes; // 全ノードマップ
  final List<String> visitedNodeIds; // 訪問済みノードID
  final ExplorationHUD hud; // HUD情報
  final bool isInRoom; // 部屋に入っているか
  final String? currentRoomNodeId; // 現在の部屋のノードID

  DungeonExplorationState({
    this.currentNodeId,
    required this.nodes,
    required this.visitedNodeIds,
    required this.hud,
    this.isInRoom = false,
    this.currentRoomNodeId,
  });

  DungeonExplorationState copyWith({
    String? currentNodeId,
    Map<String, DungeonNode>? nodes,
    List<String>? visitedNodeIds,
    ExplorationHUD? hud,
    bool? isInRoom,
    String? currentRoomNodeId,
  }) {
    return DungeonExplorationState(
      currentNodeId: currentNodeId ?? this.currentNodeId,
      nodes: nodes ?? this.nodes,
      visitedNodeIds: visitedNodeIds ?? this.visitedNodeIds,
      hud: hud ?? this.hud,
      isInRoom: isInRoom ?? this.isInRoom,
      currentRoomNodeId: currentRoomNodeId ?? this.currentRoomNodeId,
    );
  }

  DungeonNode? getCurrentNode() {
    if (currentNodeId == null) return null;
    return nodes[currentNodeId];
  }

  List<DungeonNode> getNextNodes() {
    final currentNode = getCurrentNode();
    if (currentNode == null) return [];
    return currentNode.nextNodeIds
        .map((id) => nodes[id])
        .where((node) => node != null)
        .cast<DungeonNode>()
        .toList();
  }
}





