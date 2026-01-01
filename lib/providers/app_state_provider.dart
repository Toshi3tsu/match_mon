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
                ? mockMonsters.where((monster) => monster.id != mockMonsters.first.id).toList()
                : List.from(mockMonsters), // 自キャラクターを除外
            currentDiscoverIndex: 0,
            bookmarks: [],
            currentDate: DateTime.now(),
            dungeonExplorationState: initialDungeonExplorationState,
            persistentAssets: PersistentAssets.initial(),
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
    final filteredMonsters = monsters.where((monster) {
      // 自キャラクターを除外
      if (state.playerCharacter != null && monster.id == state.playerCharacter!.id) {
        return false;
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
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

