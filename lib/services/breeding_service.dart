import 'dart:math';
import '../models/monster.dart';
import '../models/breeding.dart';
import '../data/mock_data.dart';

class BreedingService {
  // 配合プレビューを生成
  static BreedingPreview generateBreedingPreview(
    Monster parentA,
    Monster parentB, {
    int bond = 0,
  }) {
    // 子の種族を決定（決定論的）
    final childSpecies = breedingTable[parentA.species]?[parentB.species] ??
        "${parentA.species}×${parentB.species}";

    // 位階は親の高い方に近づく
    const ranks = ["C", "B", "A", "S"];
    final parentARankIndex = ranks.indexOf(parentA.rank);
    final parentBRankIndex = ranks.indexOf(parentB.rank);
    final avgRankIndex = ((parentARankIndex + parentBRankIndex) / 2).floor();
    final childRank = ranks[min(avgRankIndex + 1, ranks.length - 1)];

    // タグは親から継承（簡易版）
    final childTags = [
      ...parentA.tags.take(2),
      ...parentB.tags.take(2),
    ].toSet().take(3).toList();

    // 継承枠数（ボンドが高いと増える）
    const baseSlots = 2;
    final bondBonus = bond >= 50 ? (bond >= 80 ? 2 : 1) : 0;
    final inheritanceSlots = baseSlots + bondBonus;

    // 候補スキル
    final candidateSkills = [
      ...parentA.skills,
      ...parentB.skills,
    ].toSet().take(5).toList();

    // 事故率（ボンドが高いと下がる）
    final accidentRate = max(0, 20 - (bond / 5).floor());

    return BreedingPreview(
      childSpecies: childSpecies,
      childRank: childRank,
      childTags: childTags,
      inheritanceSlots: inheritanceSlots,
      candidateSkills: candidateSkills,
      accidentRate: accidentRate,
    );
  }

  // 相性を計算
  static Compatibility calculateCompatibility(
    Monster parentA,
    Monster parentB,
  ) {
    final matchingTags = parentA.tags
        .where((tag) => parentB.tags.contains(tag))
        .toList();
    final allTags = [
      ...parentA.tags,
      ...parentB.tags,
    ].toSet().toList();
    final complementaryTags = allTags
        .where((tag) => !matchingTags.contains(tag))
        .toList();
    final conflictingTags = <String>[]; // 簡易版では空

    CompatibilityLevel level;
    if (matchingTags.length >= 2) {
      level = CompatibilityLevel.high;
    } else if (matchingTags.length == 1) {
      level = CompatibilityLevel.medium;
    } else {
      level = CompatibilityLevel.low;
    }

    String reason;
    if (matchingTags.isNotEmpty) {
      reason = "${matchingTags.length}個のタグが一致しています";
    } else if (complementaryTags.length >= 4) {
      reason = "相補的なタグの組み合わせです";
    } else {
      reason = "相性は普通です";
    }

    return Compatibility(
      level: level,
      reason: reason,
      matchingTags: matchingTags,
      complementaryTags: complementaryTags,
      conflictingTags: conflictingTags,
    );
  }

  // 実際の配合を実行
  static Monster executeBreeding(
    Monster parentA,
    Monster parentB,
    int bond,
  ) {
    final preview = generateBreedingPreview(parentA, parentB, bond: bond);

    // 実際の継承スキルを決定（簡易版：候補からランダムに選択）
    final random = Random();
    final inheritedSkills = (List<String>.from(preview.candidateSkills)
          ..shuffle(random))
        .take(preview.inheritanceSlots)
        .toList();

    return Monster(
      id: "child_${DateTime.now().millisecondsSinceEpoch}",
      name: preview.childSpecies,
      species: preview.childSpecies,
      rank: preview.childRank,
      tags: preview.childTags,
      profile: "${parentA.name}と${parentB.name}の子。",
      locked: false,
      skills: inheritedSkills,
      geneSeed: "${parentA.geneSeed}_${parentB.geneSeed}",
    );
  }
}

