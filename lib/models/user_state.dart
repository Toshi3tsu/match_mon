class UserState {
  final int likesRemaining;
  final int inventorySlots;
  final int breedingCount;
  final String? targetSpecies;
  final List<String>? targetTags;
  // ホーム画面の折りたたみ状態
  final bool showWorldDetails;
  final bool showPersistentAssetsDetails;
  final bool showUserStateDetails;

  UserState({
    required this.likesRemaining,
    required this.inventorySlots,
    required this.breedingCount,
    this.targetSpecies,
    this.targetTags,
    this.showWorldDetails = false,
    this.showPersistentAssetsDetails = false,
    this.showUserStateDetails = false,
  });

  UserState copyWith({
    int? likesRemaining,
    int? inventorySlots,
    int? breedingCount,
    String? targetSpecies,
    List<String>? targetTags,
    bool? showWorldDetails,
    bool? showPersistentAssetsDetails,
    bool? showUserStateDetails,
  }) {
    return UserState(
      likesRemaining: likesRemaining ?? this.likesRemaining,
      inventorySlots: inventorySlots ?? this.inventorySlots,
      breedingCount: breedingCount ?? this.breedingCount,
      targetSpecies: targetSpecies ?? this.targetSpecies,
      targetTags: targetTags ?? this.targetTags,
      showWorldDetails: showWorldDetails ?? this.showWorldDetails,
      showPersistentAssetsDetails: showPersistentAssetsDetails ?? this.showPersistentAssetsDetails,
      showUserStateDetails: showUserStateDetails ?? this.showUserStateDetails,
    );
  }
}







