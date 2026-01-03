import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/monster.dart';
import '../models/collaboration.dart';
import '../models/production.dart';
import '../models/breeding.dart';
import '../models/match.dart';
import '../models/user_state.dart';
import '../models/dungeon.dart';
import '../models/match_session.dart';
import '../models/persistent_assets.dart';
import '../models/world_goals.dart';
import '../data/mock_data.dart';
import '../services/dungeon_service.dart';

class AppState {
  // ユーザー状態
  final UserState userState;
  
  // 自キャラクター（一体のみ）
  final Monster? playerCharacter;
  
  // 所持個体（素材用、自キャラクターは含まない）
  final List<Monster> inventory;
  
  // マッチング
  final List<Collaboration> collaborations;
  
  // 交配プラン
  final ProductionPlan productionPlan;
  
  // 交配履歴
  final List<ProductionResult> productionHistory;
  
  // 配合プラン
  final BreedingPlan breedingPlan;
  
  // 配合履歴
  final List<BreedingResult> breedingHistory;
  
  // マッチ（配合用）
  final List<Match> matches;
  
  // ディスカバー（候補）
  final List<Monster> discoverQueue;
  final int currentDiscoverIndex;
  
  // ブックマーク
  final List<Monster> bookmarks;

  // 現在の日付
  final DateTime currentDate;

  // 深層ダンジョン探索の状態
  final DungeonExplorationState dungeonExplorationState;

  // 永続資産（知識/制度/系譜コア）
  final PersistentAssets persistentAssets;

  // 世界の目的と評価指標（公共指標）
  final PublicMetrics publicMetrics;

  // 今回の遠征（周回）の状態
  final ExpeditionState expeditionState;

  AppState({
    required this.userState,
    this.playerCharacter,
    required this.inventory,
    required this.collaborations,
    required this.productionPlan,
    required this.productionHistory,
    required this.breedingPlan,
    required this.breedingHistory,
    required this.matches,
    required this.discoverQueue,
    required this.currentDiscoverIndex,
    required this.bookmarks,
    required this.currentDate,
    required this.dungeonExplorationState,
    required this.persistentAssets,
    required this.publicMetrics,
    required this.expeditionState,
  });

  AppState copyWith({
    UserState? userState,
    Monster? playerCharacter,
    List<Monster>? inventory,
    List<Collaboration>? collaborations,
    ProductionPlan? productionPlan,
    List<ProductionResult>? productionHistory,
    BreedingPlan? breedingPlan,
    List<BreedingResult>? breedingHistory,
    List<Match>? matches,
    List<Monster>? discoverQueue,
    int? currentDiscoverIndex,
    List<Monster>? bookmarks,
    DateTime? currentDate,
    DungeonExplorationState? dungeonExplorationState,
    PersistentAssets? persistentAssets,
    PublicMetrics? publicMetrics,
    ExpeditionState? expeditionState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
      playerCharacter: playerCharacter ?? this.playerCharacter,
      inventory: inventory ?? this.inventory,
      collaborations: collaborations ?? this.collaborations,
      productionPlan: productionPlan ?? this.productionPlan,
      productionHistory: productionHistory ?? this.productionHistory,
      breedingPlan: breedingPlan ?? this.breedingPlan,
      breedingHistory: breedingHistory ?? this.breedingHistory,
      matches: matches ?? this.matches,
      discoverQueue: discoverQueue ?? this.discoverQueue,
      currentDiscoverIndex: currentDiscoverIndex ?? this.currentDiscoverIndex,
      bookmarks: bookmarks ?? this.bookmarks,
      currentDate: currentDate ?? this.currentDate,
      dungeonExplorationState: dungeonExplorationState ?? this.dungeonExplorationState,
      persistentAssets: persistentAssets ?? this.persistentAssets,
      publicMetrics: publicMetrics ?? this.publicMetrics,
      expeditionState: expeditionState ?? this.expeditionState,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(
          AppState(
            userState: UserState(
              likesRemaining: 10,
              inventorySlots: 20,
              breedingCount: 0,
            ),
            playerCharacter: mockMonsters.isNotEmpty ? mockMonsters.first : null, // 初期自キャラクター
            inventory: mockMonsters.skip(1).take(4).toList(), // 初期所持（自キャラクター以外）
            collaborations: [],
            productionPlan: ProductionPlan(),
            productionHistory: [],
            breedingPlan: BreedingPlan(),
            breedingHistory: [],
            matches: [],
            discoverQueue: mockMonsters.isNotEmpty 
                ? mockMonsters.where((monster) {
                    // 自キャラクターを除外
                    if (monster.id == mockMonsters.first.id) {
                      return false;
                    }
                    // 自キャラクターの性別と異なる性別のモンスターのみを表示
                    if (monster.gender == mockMonsters.first.gender) {
                      return false;
                    }
                    return true;
                  }).toList()
                : List.from(mockMonsters), // 自キャラクターを除外
            currentDiscoverIndex: 0,
            bookmarks: [],
            currentDate: DateTime.now(),
            dungeonExplorationState: initialDungeonExplorationState,
            persistentAssets: PersistentAssets.initial(),
            publicMetrics: PublicMetrics.initial(),
            expeditionState: ExpeditionState.initial(),
          ),
        );

  // ユーザー状態を更新
  void setUserState(UserState userState) {
    state = state.copyWith(userState: userState);
  }

  // 所持個体を追加
  void addToInventory(Monster monster) {
    state = state.copyWith(
      inventory: [...state.inventory, monster],
    );
  }

  // 所持個体を削除
  void removeFromInventory(String id) {
    state = state.copyWith(
      inventory: state.inventory.where((m) => m.id != id).toList(),
    );
  }

  // ロック状態を切り替え
  void toggleLock(String id) {
    state = state.copyWith(
      inventory: state.inventory.map((u) {
        if (u.id == id) {
          return u.copyWith(locked: !u.locked);
        }
        return u;
      }).toList(),
    );
  }

  // マッチングを追加
  void addCollaboration(Collaboration collaboration) {
    state = state.copyWith(
      collaborations: [...state.collaborations, collaboration],
    );
  }

  // ボンドを更新
  void updateBond(String collaborationId, int bond) {
    state = state.copyWith(
      collaborations: state.collaborations.map((c) {
        if (c.id == collaborationId) {
          return c.copyWith(bond: bond);
        }
        return c;
      }).toList(),
    );
  }

  // マッチ後セッションを更新
  void updateSession(String collaborationId, MatchSession session) {
    state = state.copyWith(
      collaborations: state.collaborations.map((c) {
        if (c.id == collaborationId) {
          return c.copyWith(
            session: session,
            bond: session.currentFavorability,
          );
        }
        return c;
      }).toList(),
    );
  }

  // 交配プランを設定
  void setProductionPlan(ProductionPlan plan) {
    state = state.copyWith(productionPlan: plan);
  }

  // 交配結果を追加
  void addProductionResult(ProductionResult result) {
    state = state.copyWith(
      productionHistory: [result, ...state.productionHistory],
      userState: state.userState.copyWith(
        breedingCount: state.userState.breedingCount + 1,
      ),
    );
  }

  // ディスカバーキューを設定
  void setDiscoverQueue(List<Monster> monsters) {
    // 自キャラクターといいね済みのキャラクターを除外
    // 自キャラクターの性別と異なる性別のモンスターのみを表示
    final filteredMonsters = monsters.where((monster) {
      // 自キャラクターを除外
      if (state.playerCharacter != null && monster.id == state.playerCharacter!.id) {
        return false;
      }
      // 自キャラクターの性別と異なる性別のモンスターのみを表示
      if (state.playerCharacter != null) {
        if (monster.gender == state.playerCharacter!.gender) {
          return false;
        }
      }
      // いいね済みのキャラクターを除外
      if (state.collaborations.any((c) => c.partnerId == monster.id)) {
        return false;
      }
      return true;
    }).toList();
    
    state = state.copyWith(
      discoverQueue: filteredMonsters,
      currentDiscoverIndex: 0,
    );
  }

  // 次の候補へ
  void nextDiscover() {
    state = state.copyWith(
      currentDiscoverIndex: (state.currentDiscoverIndex + 1)
          .clamp(0, state.discoverQueue.length - 1),
    );
  }

  // 現在の候補にいいね
  void likeCurrent() {
    if (state.currentDiscoverIndex >= state.discoverQueue.length) return;
    if (state.userState.likesRemaining <= 0) return;

    final current = state.discoverQueue[state.currentDiscoverIndex];
    
    // 自キャラクターでないことを確認
    if (state.playerCharacter != null && current.id == state.playerCharacter!.id) {
      return; // 自キャラクターにはいいねできない
    }
    
    // 既にいいね済みかチェック
    if (state.collaborations.any((c) => c.partnerId == current.id)) {
      return; // 既にいいね済み
    }
    
    // マッチングを作成（好感度は20でスタート）
    final collaboration = Collaboration(
      id: "collaboration_${DateTime.now().millisecondsSinceEpoch}",
      partnerId: current.id,
      partner: current,
      createdAt: DateTime.now(),
      bond: 20,
      status: "active",
    );

    state = state.copyWith(
      collaborations: [...state.collaborations, collaboration],
      userState: state.userState.copyWith(
        likesRemaining: state.userState.likesRemaining - 1,
      ),
      currentDiscoverIndex: state.currentDiscoverIndex + 1,
    );
  }

  // 特定のモンスターにいいね（一覧から直接いいねする場合）
  void likeMonster(Monster monster) {
    if (state.userState.likesRemaining <= 0) return;
    
    // 自キャラクターでないことを確認
    if (state.playerCharacter != null && monster.id == state.playerCharacter!.id) {
      return; // 自キャラクターにはいいねできない
    }
    
    // 既にいいね済みかチェック
    if (state.collaborations.any((c) => c.partnerId == monster.id)) {
      return; // 既にいいね済み
    }
    
    // マッチングを作成（好感度は20でスタート）
    final collaboration = Collaboration(
      id: "collaboration_${DateTime.now().millisecondsSinceEpoch}",
      partnerId: monster.id,
      partner: monster,
      createdAt: DateTime.now(),
      bond: 20,
      status: "active",
    );

    state = state.copyWith(
      collaborations: [...state.collaborations, collaboration],
      userState: state.userState.copyWith(
        likesRemaining: state.userState.likesRemaining - 1,
      ),
    );
  }

  // 現在の候補をスキップ
  void skipCurrent() {
    state = state.copyWith(
      currentDiscoverIndex: state.currentDiscoverIndex + 1,
    );
  }

  // 現在の候補をブックマーク
  void bookmarkCurrent() {
    if (state.currentDiscoverIndex >= state.discoverQueue.length) return;
    
    final current = state.discoverQueue[state.currentDiscoverIndex];
    
    if (state.bookmarks.any((b) => b.id == current.id)) return;

    state = state.copyWith(
      bookmarks: [...state.bookmarks, current],
      currentDiscoverIndex: state.currentDiscoverIndex + 1,
    );
  }

  // ブックマークを追加
  void addBookmark(Monster monster) {
    if (state.bookmarks.any((b) => b.id == monster.id)) return;
    
    state = state.copyWith(
      bookmarks: [...state.bookmarks, monster],
    );
  }

  // ブックマークを削除
  void removeBookmark(String id) {
    state = state.copyWith(
      bookmarks: state.bookmarks.where((b) => b.id != id).toList(),
    );
  }

  // 自キャラクターを設定（置き換え）
  void setPlayerCharacter(Monster monster) {
    state = state.copyWith(playerCharacter: monster);
  }

  // 自キャラクターを削除（転生時など）
  void clearPlayerCharacter() {
    state = state.copyWith(playerCharacter: null);
  }

  // 配合プランを設定
  void setBreedingPlan(BreedingPlan plan) {
    state = state.copyWith(breedingPlan: plan);
  }

  // 配合結果を追加
  void addBreedingResult(BreedingResult result) {
    state = state.copyWith(
      breedingHistory: [result, ...state.breedingHistory],
      userState: state.userState.copyWith(
        breedingCount: state.userState.breedingCount + 1,
      ),
    );
  }

  // 日付を更新
  void updateDate(DateTime date) {
    state = state.copyWith(currentDate: date);
  }

  // 深層ダンジョン探索の状態を更新
  void updateDungeonExplorationState(DungeonExplorationState explorationState) {
    state = state.copyWith(dungeonExplorationState: explorationState);
  }

  // ノードに入る
  void enterDungeonNode(String nodeId) {
    final currentState = state.dungeonExplorationState;
    final node = currentState.nodes[nodeId];
    if (node != null) {
      state = state.copyWith(
        dungeonExplorationState: currentState.copyWith(
          currentNodeId: nodeId,
          isInRoom: true,
          currentRoomNodeId: nodeId,
          visitedNodeIds: [...currentState.visitedNodeIds, nodeId],
        ),
      );

      // 契約設定がある場合は自動的に処理を実行
      if (currentState.contractSettings != null) {
        // 少し遅延させてから自動処理を実行（UI更新のため）
        Future.delayed(const Duration(milliseconds: 500), () {
          proceedAutoExploration();
        });
      }
    }
  }

  // 部屋から出る
  void exitRoom() {
    final currentState = state.dungeonExplorationState;
    state = state.copyWith(
      dungeonExplorationState: currentState.copyWith(
        isInRoom: false,
        currentRoomNodeId: null,
        currentNodeId: null, // ノードマップに戻る
      ),
    );
  }

  // HUDを更新
  void updateExplorationHUD(ExplorationHUD hud) {
    final currentState = state.dungeonExplorationState;
    state = state.copyWith(
      dungeonExplorationState: currentState.copyWith(hud: hud),
    );
  }

  // 持ち帰り資産を追加
  void addSecuredAsset(String assetType, int amount) {
    final currentState = state.dungeonExplorationState;
    final currentAssets = Map<String, int>.from(currentState.hud.securedAssets);
    currentAssets[assetType] = (currentAssets[assetType] ?? 0) + amount;
    state = state.copyWith(
      dungeonExplorationState: currentState.copyWith(
        hud: currentState.hud.copyWith(securedAssets: currentAssets),
      ),
    );
  }

  // 探索をリセット（転生時など）
  void resetDungeonExploration() {
    state = state.copyWith(
      dungeonExplorationState: initialDungeonExplorationState,
    );
  }

  // 探索を開始（「はじまりのダンジョン」を生成）
  void startDungeonExploration({String dungeonId = 'beginning'}) {
    final explorationState = DungeonService.generateBeginningDungeon(
      playerCharacter: state.playerCharacter,
    );
    state = state.copyWith(
      dungeonExplorationState: explorationState,
    );
  }

  // 契約設定を保存
  void setContractSettings(ContractSettings settings) {
    final currentState = state.dungeonExplorationState;
    state = state.copyWith(
      dungeonExplorationState: currentState.copyWith(contractSettings: settings),
    );
  }

  // 契約設定に基づいて自動的に次のノードを選択
  String? selectNextNodeAutomatically(String currentNodeId) {
    final currentState = state.dungeonExplorationState;
    final currentNode = currentState.nodes[currentNodeId];
    if (currentNode == null) return null;

    final contractSettings = currentState.contractSettings;
    if (contractSettings == null) return null;

    final nextNodes = currentNode.nextNodeIds
        .map((id) => currentState.nodes[id])
        .where((node) => node != null)
        .cast<DungeonNode>()
        .toList();

    if (nextNodes.isEmpty) return null;

    // 契約設定に基づいて最適なノードを選択
    DungeonNode? selectedNode;

    // 優先目的に基づいてノードを評価
    switch (contractSettings.priorityObjective) {
      case PriorityObjective.wedge:
        // 楔の確保：ボスや最深部に向かうノードを優先
        selectedNode = nextNodes.firstWhere(
          (node) => node.id.contains('boss') || node.id.contains('floor5'),
          orElse: () => nextNodes.first,
        );
        break;
      case PriorityObjective.resource:
        // 資源回収：資源報酬のノードを優先
        selectedNode = nextNodes.firstWhere(
          (node) => node.rewardCategory == RewardCategory.resource,
          orElse: () => nextNodes.first,
        );
        break;
      case PriorityObjective.lineageMaterial:
        // 系譜素材の獲得：系譜素材報酬のノードを優先
        selectedNode = nextNodes.firstWhere(
          (node) => node.rewardCategory == RewardCategory.lineageMaterial,
          orElse: () => nextNodes.first,
        );
        break;
    }

    // 危険許容度に基づいて調整
    if (contractSettings.riskTolerance == RiskTolerance.cautious) {
      // 慎重：危険度が低いノードを優先
      final safeNodes = nextNodes.where((node) => node.dangerLevel == DangerLevel.low).toList();
      if (safeNodes.isNotEmpty) {
        selectedNode = safeNodes.first;
      }
    } else if (contractSettings.riskTolerance == RiskTolerance.aggressive) {
      // 積極的：危険度が高いノードを優先（報酬が多い）
      final riskyNodes = nextNodes.where((node) => node.dangerLevel == DangerLevel.high).toList();
      if (riskyNodes.isNotEmpty) {
        selectedNode = riskyNodes.first;
      }
    }

    // 目標到達層に基づいて調整
    final currentFloor = _estimateFloorFromNodeId(currentNodeId);
    if (contractSettings.targetFloor == TargetFloor.middle && currentFloor >= 2) {
      // 中層到達後は撤退を促す（休息ノードを優先）
      final restNodes = nextNodes.where((node) => node.type == NodeType.rest).toList();
      if (restNodes.isNotEmpty) {
        selectedNode = restNodes.first;
      }
    } else if (contractSettings.targetFloor == TargetFloor.deep && currentFloor >= 3) {
      // 深層到達後は撤退を促す
      final restNodes = nextNodes.where((node) => node.type == NodeType.rest).toList();
      if (restNodes.isNotEmpty) {
        selectedNode = restNodes.first;
      }
    }

    return selectedNode.id;
  }

  // 契約設定に基づいて自動的にイベントの選択肢を選択
  Map<String, int> selectEventChoiceAutomatically(DungeonNode node) {
    final currentState = state.dungeonExplorationState;
    final contractSettings = currentState.contractSettings;
    if (contractSettings == null) return {};

    // 優先目的に基づいて選択肢を決定
    switch (contractSettings.priorityObjective) {
      case PriorityObjective.wedge:
        // 楔の確保：情報を優先（楔の手がかり）
        return {'information': 1};
      case PriorityObjective.resource:
        // 資源回収：資源を優先
        return {'resource': 1};
      case PriorityObjective.lineageMaterial:
        // 系譜素材の獲得：情報を優先（系譜の手がかり）
        return {'information': 1};
    }
  }

  // 自動探索を1ステップ進める
  void proceedAutoExploration() {
    final currentState = state.dungeonExplorationState;
    final contractSettings = currentState.contractSettings;
    if (contractSettings == null) return;

    // 現在のノードを取得
    final currentNode = currentState.getCurrentNode();
    if (currentNode == null) {
      // 開始ノードに入る
      if (currentState.nodes.containsKey('start')) {
        enterDungeonNode('start');
      }
      return;
    }

    // ノードタイプに応じて処理
    switch (currentNode.type) {
      case NodeType.combat:
        // 戦闘：自動実行
        executeAutoCombat(currentNode.id);
        // 次のノードを自動選択
        final nextNodeId = selectNextNodeAutomatically(currentNode.id);
        if (nextNodeId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            exitRoom();
            Future.delayed(const Duration(milliseconds: 300), () {
              enterDungeonNode(nextNodeId);
            });
          });
        } else {
          // 次のノードがない場合は探索終了
          exitRoom();
        }
        break;
      case NodeType.event:
        // イベント：自動選択
        final rewards = selectEventChoiceAutomatically(currentNode);
        _completeEventNodeAutomatically(currentNode.id, rewards);
        // 次のノードを自動選択
        final nextNodeId = selectNextNodeAutomatically(currentNode.id);
        if (nextNodeId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            exitRoom();
            Future.delayed(const Duration(milliseconds: 300), () {
              enterDungeonNode(nextNodeId);
            });
          });
        } else {
          exitRoom();
        }
        break;
      case NodeType.rest:
        // 休息：自動処理（HP回復を優先）
        _completeRestNodeAutomatically(currentNode.id);
        // 次のノードを自動選択
        final nextNodeId = selectNextNodeAutomatically(currentNode.id);
        if (nextNodeId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            exitRoom();
            Future.delayed(const Duration(milliseconds: 300), () {
              enterDungeonNode(nextNodeId);
            });
          });
        } else {
          exitRoom();
        }
        break;
      case NodeType.contract:
        // 契約：自動処理（交渉を優先）
        _completeContractNodeAutomatically(currentNode.id);
        // 次のノードを自動選択
        final nextNodeId = selectNextNodeAutomatically(currentNode.id);
        if (nextNodeId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            exitRoom();
            Future.delayed(const Duration(milliseconds: 300), () {
              enterDungeonNode(nextNodeId);
            });
          });
        } else {
          exitRoom();
        }
        break;
      case NodeType.refinement:
        // 精錬：自動処理（精錬を優先）
        _completeRefinementNodeAutomatically(currentNode.id);
        // 次のノードを自動選択
        final nextNodeId = selectNextNodeAutomatically(currentNode.id);
        if (nextNodeId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            exitRoom();
            Future.delayed(const Duration(milliseconds: 300), () {
              enterDungeonNode(nextNodeId);
            });
          });
        } else {
          exitRoom();
        }
        break;
    }
  }

  // イベントノードを自動完了
  void _completeEventNodeAutomatically(String nodeId, Map<String, int> rewards) {
    final currentState = state.dungeonExplorationState;
    final hud = currentState.hud;
    
    // HUDを更新
    var newHud = hud;
    if (rewards.containsKey('stress')) {
      newHud = newHud.copyWith(
        stress: (hud.stress + rewards['stress']!).clamp(0, hud.maxStress),
      );
    }
    
    // 資産を追加
    rewards.forEach((type, amount) {
      if (type != 'stress') {
        addSecuredAsset(type, amount);
      }
    });
    
    if (newHud != hud) {
      updateExplorationHUD(newHud);
    }

    // イベント履歴を追加
    final node = currentState.nodes[nodeId];
    if (node != null) {
      final newEventEntries = [...currentState.history.eventEntries, 
        '${node.name}: ${rewards.entries.map((e) => '${_getRewardTypeLabel(e.key)} ${e.value > 0 ? "+" : ""}${e.value}').join(", ")}'];
      final newHistory = currentState.history.copyWith(eventEntries: newEventEntries);
      state = state.copyWith(
        dungeonExplorationState: currentState.copyWith(history: newHistory),
      );
    }
  }

  // 休息ノードを自動完了
  void _completeRestNodeAutomatically(String nodeId) {
    final currentState = state.dungeonExplorationState;
    final hud = currentState.hud;
    
    // HP回復を優先（回復回数がある場合）
    var newHp = hud.hp;
    var newRecoveryCount = hud.recoveryCount;
    
    if (newRecoveryCount > 0 && hud.hp < hud.maxHp * 0.7) {
      // HPが70%未満の場合は回復
      newHp = (hud.hp + 30).clamp(0, hud.maxHp);
      newRecoveryCount = hud.recoveryCount - 1;
    } else {
      // ストレスを減らす
      final newStress = (hud.stress - 20).clamp(0, hud.maxStress);
      final newHud = hud.copyWith(stress: newStress);
      updateExplorationHUD(newHud);
    }
    
    if (newHp != hud.hp || newRecoveryCount != hud.recoveryCount) {
      final newHud = hud.copyWith(
        hp: newHp,
        recoveryCount: newRecoveryCount,
      );
      updateExplorationHUD(newHud);
    }

    // イベント履歴を追加
    final node = currentState.nodes[nodeId];
    if (node != null) {
      final newEventEntries = [...currentState.history.eventEntries, 
        '${node.name}: 休息を取った（HP: ${hud.hp} → ${newHp}, 回復回数: ${hud.recoveryCount} → ${newRecoveryCount}）'];
      final newHistory = currentState.history.copyWith(eventEntries: newEventEntries);
      state = state.copyWith(
        dungeonExplorationState: currentState.copyWith(history: newHistory),
      );
    }
  }

  // 契約ノードを自動完了
  void _completeContractNodeAutomatically(String nodeId) {
    addSecuredAsset('contractClause', 1);

    // イベント履歴を追加
    final currentState = state.dungeonExplorationState;
    final node = currentState.nodes[nodeId];
    if (node != null) {
      final newEventEntries = [...currentState.history.eventEntries, 
        '${node.name}: 契約条項を獲得'];
      final newHistory = currentState.history.copyWith(eventEntries: newEventEntries);
      state = state.copyWith(
        dungeonExplorationState: currentState.copyWith(history: newHistory),
      );
    }
  }

  // 精錬ノードを自動完了
  void _completeRefinementNodeAutomatically(String nodeId) {
    addSecuredAsset('resource', 2);

    // イベント履歴を追加
    final currentState = state.dungeonExplorationState;
    final node = currentState.nodes[nodeId];
    if (node != null) {
      final newEventEntries = [...currentState.history.eventEntries, 
        '${node.name}: 資源 +2 を獲得'];
      final newHistory = currentState.history.copyWith(eventEntries: newEventEntries);
      state = state.copyWith(
        dungeonExplorationState: currentState.copyWith(history: newHistory),
      );
    }
  }

  String _getRewardTypeLabel(String type) {
    switch (type) {
      case 'information':
        return '情報';
      case 'resource':
        return '資源';
      case 'lineageMaterial':
        return '系譜素材';
      case 'contractClause':
        return '契約条項';
      default:
        return type;
    }
  }

  // 自動戦闘を実行（契約設定に基づいて戦闘結果を決定）
  void executeAutoCombat(String nodeId) {
    final currentState = state.dungeonExplorationState;
    final node = currentState.nodes[nodeId];
    if (node == null || node.type != NodeType.combat) return;

    final contractSettings = currentState.contractSettings;
    final hud = currentState.hud;

    // 契約設定に基づいて戦闘結果を決定
    bool victory = true;
    int damageTaken = 0;
    Map<String, int> rewards = {};

    // 危険許容度に基づいてダメージを調整
    final baseDamage = node.dangerLevel == DangerLevel.high ? 30 :
                      node.dangerLevel == DangerLevel.medium ? 20 : 10;
    
    if (contractSettings != null) {
      switch (contractSettings.riskTolerance) {
        case RiskTolerance.aggressive:
          damageTaken = (baseDamage * 1.3).round(); // 積極的：ダメージ+30%
          break;
        case RiskTolerance.standard:
          damageTaken = baseDamage;
          break;
        case RiskTolerance.cautious:
          damageTaken = (baseDamage * 0.7).round(); // 慎重：ダメージ-30%
          break;
      }
    } else {
      damageTaken = baseDamage;
    }

    // HPが足りない場合は敗北
    if (hud.hp <= damageTaken) {
      victory = false;
      damageTaken = hud.hp;
    }

    // 勝利時の報酬
    if (victory) {
      final rewardType = _getRewardCategoryAssetType(node.rewardCategory);
      rewards[rewardType] = 1;

      // 優先目的に応じて報酬を追加
      if (contractSettings != null) {
        switch (contractSettings.priorityObjective) {
          case PriorityObjective.wedge:
            // 楔の確保：特定のノードで楔を獲得
            if (node.id.contains('boss') || node.id.contains('floor5')) {
              rewards['wedge'] = 1;
            }
            break;
          case PriorityObjective.resource:
            // 資源回収：資源報酬を追加
            if (node.rewardCategory == RewardCategory.resource) {
              rewards['resource'] = (rewards['resource'] ?? 0) + 1;
            }
            break;
          case PriorityObjective.lineageMaterial:
            // 系譜素材の獲得：系譜素材報酬を追加
            if (node.rewardCategory == RewardCategory.lineageMaterial) {
              rewards['lineageMaterial'] = (rewards['lineageMaterial'] ?? 0) + 1;
            }
            break;
        }
      }
    }

    // HUDを更新
    final newHp = (hud.hp - damageTaken).clamp(0, hud.maxHp);
    final newHud = hud.copyWith(hp: newHp);

    // 報酬を資産に追加
    final newSecuredAssets = Map<String, int>.from(hud.securedAssets);
    rewards.forEach((type, amount) {
      newSecuredAssets[type] = (newSecuredAssets[type] ?? 0) + amount;
    });
    final finalHud = newHud.copyWith(securedAssets: newSecuredAssets);

    // 戦闘履歴を追加
    final combatEntry = CombatHistoryEntry(
      timestamp: DateTime.now(),
      nodeId: nodeId,
      nodeName: node.name,
      victory: victory,
      damageTaken: damageTaken,
      rewards: rewards,
      bossName: node.boss?.name,
      description: victory
          ? '${node.name}での戦闘に勝利。${node.boss != null ? "ボス" : "敵"}を撃破した。'
          : '${node.name}での戦闘に敗北。撤退した。',
    );

    final newCombatEntries = [...currentState.history.combatEntries, combatEntry];
    final newHistory = currentState.history.copyWith(
      combatEntries: newCombatEntries,
      currentFloor: _estimateFloorFromNodeId(nodeId),
      wedgesSecured: newSecuredAssets['wedge'] ?? 0,
    );

    // 状態を更新
    state = state.copyWith(
      dungeonExplorationState: currentState.copyWith(
        hud: finalHud,
        history: newHistory,
      ),
    );
  }

  // ノードIDから階層を推定
  int _estimateFloorFromNodeId(String nodeId) {
    if (nodeId.contains('floor5')) return 5;
    if (nodeId.contains('floor4')) return 4;
    if (nodeId.contains('floor3')) return 3;
    if (nodeId.contains('floor2')) return 2;
    if (nodeId.contains('floor1')) return 1;
    return 0;
  }

  String _getRewardCategoryAssetType(RewardCategory category) {
    switch (category) {
      case RewardCategory.resource:
        return 'resource';
      case RewardCategory.information:
        return 'information';
      case RewardCategory.lineageMaterial:
        return 'lineageMaterial';
      case RewardCategory.contractClause:
        return 'contractClause';
    }
  }

  // 永続資産を更新
  void updatePersistentAssets(PersistentAssets assets) {
    state = state.copyWith(persistentAssets: assets);
  }

  // 知識を追加
  void addBreedingRecipe(BreedingRecipe recipe) {
    final newRecipes = [...state.persistentAssets.knowledge.breedingRecipes, recipe];
    state = state.copyWith(
      persistentAssets: state.persistentAssets.copyWith(
        knowledge: state.persistentAssets.knowledge.copyWith(
          breedingRecipes: newRecipes,
        ),
      ),
    );
  }

  // 系譜記録を追加
  void addLineageRecord(LineageRecord record) {
    final newRecords = [...state.persistentAssets.lineageAssets.lineageRecords, record];
    final speciesId = record.resultSpecies;
    final currentBonus = state.persistentAssets.lineageAssets.lineageBonuses[speciesId] ?? 0.0;
    final newBonuses = Map<String, double>.from(state.persistentAssets.lineageAssets.lineageBonuses);
    newBonuses[speciesId] = (currentBonus + 0.1).clamp(0.0, 1.0); // +10%まで

    state = state.copyWith(
      persistentAssets: state.persistentAssets.copyWith(
        lineageAssets: state.persistentAssets.lineageAssets.copyWith(
          lineageRecords: newRecords,
          lineageBonuses: newBonuses,
        ),
      ),
    );
  }

  // 相談所ランクを上げる
  void upgradeConsultationOffice() {
    final currentRank = state.persistentAssets.choices.institution.consultationOfficeRank;
    state = state.copyWith(
      persistentAssets: state.persistentAssets.copyWith(
        choices: state.persistentAssets.choices.copyWith(
          institution: state.persistentAssets.choices.institution.copyWith(
            consultationOfficeRank: currentRank + 1,
            candidateQualityBonus: (state.persistentAssets.choices.institution.candidateQualityBonus + 0.05).clamp(0.0, 1.0),
            rareEncounterRate: (state.persistentAssets.choices.institution.rareEncounterRate + 0.02).clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }

  // 遠征の目標を設定
  void setExpeditionGoal(ExpeditionGoal goal) {
    state = state.copyWith(
      expeditionState: state.expeditionState.copyWith(currentGoal: goal),
    );
  }

  // 遠征の階層を更新
  void updateExpeditionFloor(int floor) {
    final currentMaxFloor = state.expeditionState.maxFloorReached;
    state = state.copyWith(
      expeditionState: state.expeditionState.copyWith(
        currentFloor: floor,
        maxFloorReached: floor > currentMaxFloor ? floor : currentMaxFloor,
      ),
    );
  }

  // 公共指標を更新
  void updatePublicMetrics(PublicMetrics metrics) {
    state = state.copyWith(publicMetrics: metrics);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

