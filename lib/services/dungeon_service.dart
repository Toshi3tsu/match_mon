import '../models/dungeon.dart';
import '../models/monster.dart';

/// ダンジョン生成サービス
/// 「はじまりのダンジョン」を5階層で生成する
class DungeonService {
  /// 「はじまりのダンジョン」を生成
  /// 5階層の分岐ノードマップを生成する
  static DungeonExplorationState generateBeginningDungeon({
    Monster? playerCharacter,
  }) {
    final nodes = <String, DungeonNode>{};
    
    // プレイヤーのHPを設定（自キャラクターがいる場合はそのHPを使用）
    final initialHp = playerCharacter != null ? 100 : 100;
    final maxHp = initialHp;
    
    // 第1階層：入口
    final startNode = DungeonNode(
      id: 'start',
      type: NodeType.event,
      name: 'はじまりの入口',
      description: '深層ダンジョンへの入口。瘴気が漂っている。',
      rewardCategory: RewardCategory.information,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor1_1', 'floor1_2'],
    );
    nodes['start'] = startNode;
    
    // 第1階層：2つの分岐
    final floor1_1 = DungeonNode(
      id: 'floor1_1',
      type: NodeType.combat,
      name: '瘴気の回廊',
      description: '弱い敵が徘徊している。戦闘が待ち構えている。',
      rewardCategory: RewardCategory.resource,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor2_1', 'floor2_2'],
    );
    nodes['floor1_1'] = floor1_1;
    
    final floor1_2 = DungeonNode(
      id: 'floor1_2',
      type: NodeType.event,
      name: '古い遺跡',
      description: '古代の遺跡が発見された。何かが隠されているかもしれない。',
      rewardCategory: RewardCategory.information,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor2_2', 'floor2_3'],
    );
    nodes['floor1_2'] = floor1_2;
    
    // 第2階層：3つの分岐
    final floor2_1 = DungeonNode(
      id: 'floor2_1',
      type: NodeType.combat,
      name: '戦闘の間',
      description: '強めの敵が待ち構えている。',
      rewardCategory: RewardCategory.resource,
      dangerLevel: DangerLevel.medium,
      recommendedTags: ['攻撃', '防御'],
      recommendedResistances: ['物理攻撃'],
      recommendedRoles: ['アタッカー'],
      nextNodeIds: ['floor3_1'],
    );
    nodes['floor2_1'] = floor2_1;
    
    final floor2_2 = DungeonNode(
      id: 'floor2_2',
      type: NodeType.rest,
      name: '休息の間',
      description: '安全な場所で休息を取れる。回復や調整が可能。',
      rewardCategory: RewardCategory.resource,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor3_1', 'floor3_2'],
    );
    nodes['floor2_2'] = floor2_2;
    
    final floor2_3 = DungeonNode(
      id: 'floor2_3',
      type: NodeType.contract,
      name: '契約遭遇',
      description: '希少な個体との偶然の出会い。交渉のチャンス。',
      rewardCategory: RewardCategory.contractClause,
      dangerLevel: DangerLevel.medium,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor3_2', 'floor3_3'],
    );
    nodes['floor2_3'] = floor2_3;
    
    // 第3階層：3つの分岐
    final floor3_1 = DungeonNode(
      id: 'floor3_1',
      type: NodeType.combat,
      name: '深層の戦場',
      description: '強力な敵が待ち構えている。',
      rewardCategory: RewardCategory.lineageMaterial,
      dangerLevel: DangerLevel.medium,
      recommendedTags: ['防御', 'HP回復'],
      recommendedResistances: ['状態異常'],
      recommendedRoles: ['タンク'],
      nextNodeIds: ['floor4_1'],
    );
    nodes['floor3_1'] = floor3_1;
    
    final floor3_2 = DungeonNode(
      id: 'floor3_2',
      type: NodeType.refinement,
      name: '精錬工房',
      description: '資源を変換・強化できる工房。',
      rewardCategory: RewardCategory.resource,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor4_1', 'floor4_2'],
    );
    nodes['floor3_2'] = floor3_2;
    
    final floor3_3 = DungeonNode(
      id: 'floor3_3',
      type: NodeType.event,
      name: '謎の部屋',
      description: '未知の部屋。何が待っているか分からない。',
      rewardCategory: RewardCategory.information,
      dangerLevel: DangerLevel.medium,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor4_2'],
    );
    nodes['floor3_3'] = floor3_3;
    
    // 第4階層：2つの分岐
    final floor4_1 = DungeonNode(
      id: 'floor4_1',
      type: NodeType.combat,
      name: 'ボス前の戦場',
      description: 'ボス戦前の最後の戦闘。強敵が待ち構えている。',
      rewardCategory: RewardCategory.lineageMaterial,
      dangerLevel: DangerLevel.high,
      recommendedTags: ['攻撃', '防御', 'HP回復'],
      recommendedResistances: ['状態異常', '物理攻撃'],
      recommendedRoles: ['アタッカー', 'タンク'],
      nextNodeIds: ['floor5_boss'],
    );
    nodes['floor4_1'] = floor4_1;
    
    final floor4_2 = DungeonNode(
      id: 'floor4_2',
      type: NodeType.rest,
      name: '最後の休息',
      description: 'ボス戦前の最後の休息。準備を整えよう。',
      rewardCategory: RewardCategory.resource,
      dangerLevel: DangerLevel.low,
      recommendedTags: [],
      recommendedResistances: [],
      recommendedRoles: [],
      nextNodeIds: ['floor5_boss'],
    );
    nodes['floor4_2'] = floor4_2;
    
    // 第5階層：ボス戦
    final floor5_boss = DungeonNode(
      id: 'floor5_boss',
      type: NodeType.combat,
      name: 'はじまりの守護者',
      description: '深層の守護者。強力なボスが待ち構えている。',
      rewardCategory: RewardCategory.lineageMaterial,
      dangerLevel: DangerLevel.high,
      boss: Boss(
        id: 'beginning_guardian',
        name: 'はじまりの守護者',
        species: '古代の守護者',
        rank: 'A',
        tags: ['防御', '状態異常', '範囲攻撃'],
        profile: '深層ダンジョンの入口を守る古代の守護者。長い年月を経て、強力な力を持つ。',
        level: 10,
        hp: 500,
        maxHp: 500,
        attack: 80,
        defense: 60,
        speed: 40,
        threatProfile: ['状態異常', '範囲攻撃', '高防御'],
      ),
      recommendedTags: ['状態異常耐性', '防御', 'HP回復'],
      recommendedResistances: ['状態異常', '物理攻撃', '魔法攻撃'],
      recommendedRoles: ['タンク', 'サポート'],
      nextNodeIds: [], // ボス戦が最後
    );
    nodes['floor5_boss'] = floor5_boss;
    
    // 初期HUDを生成
    final hud = ExplorationHUD(
      hp: initialHp,
      maxHp: maxHp,
      recoveryCount: 3,
      stress: 0,
      maxStress: 100,
      securedAssets: {},
      unsecuredAssets: {},
    );
    
    return DungeonExplorationState(
      currentNodeId: null, // 開始時はノードマップを表示
      nodes: nodes,
      visitedNodeIds: [],
      hud: hud,
      isInRoom: false,
      currentRoomNodeId: null,
    );
  }
  
  /// ダンジョン名を取得
  static String getDungeonName(String dungeonId) {
    switch (dungeonId) {
      case 'beginning':
        return 'はじまりのダンジョン';
      default:
        return '未知のダンジョン';
    }
  }
  
  /// ダンジョンの説明を取得
  static String getDungeonDescription(String dungeonId) {
    switch (dungeonId) {
      case 'beginning':
        return '深層ダンジョンへの入口。5階層の構造を持つ。最深部には守護者が待ち構えている。';
      default:
        return '未知のダンジョン';
    }
  }
}





