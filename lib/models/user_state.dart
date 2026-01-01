class UserState {
  final int likesRemaining;
  final int inventorySlots;
  final int breedingCount;
  final String? targetSpecies;
  final List<String>? targetTags;

  UserState({
    required this.likesRemaining,
    required this.inventorySlots,
    required this.breedingCount,
    this.targetSpecies,
    this.targetTags,
  });

  UserState copyWith({
    int? likesRemaining,
    int? inventorySlots,
    int? breedingCount,
    String? targetSpecies,
    List<String>? targetTags,
  }) {
    return UserState(
      likesRemaining: likesRemaining ?? this.likesRemaining,
      inventorySlots: inventorySlots ?? this.inventorySlots,
      breedingCount: breedingCount ?? this.breedingCount,
      targetSpecies: targetSpecies ?? this.targetSpecies,
      targetTags: targetTags ?? this.targetTags,
    );
  }
}







