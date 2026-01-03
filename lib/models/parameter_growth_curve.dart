/// パラメータごとの成長カーブ設定
/// 設計書 4.8.3, 9.1 参照

import 'dart:math';

class ParameterGrowthCurve {
  final int growthPeakAge; // 成長期のピーク年齢（例：15）
  final double growthSpread; // 成長期の広がりσ（例：5.0）
  final int agingStartAge; // 老化の開始年齢（例：25）
  final double agingDecayRate; // 老化の減衰率D（例：0.1）

  ParameterGrowthCurve({
    required this.growthPeakAge,
    required this.growthSpread,
    required this.agingStartAge,
    required this.agingDecayRate,
  });

  /// 年齢tにおける成長量を計算
  /// ΔM(t) = A·exp(-(t-15)²/(2σ²)) - D·max(0, t-25)
  /// Aは個体の偏差値 × モンスターの個体値で決定される（外部から渡す）
  double calculateGrowth(double t, double growthAmplitude) {
    // 成長期の項: A·exp(-(t-growthPeakAge)²/(2·growthSpread²))
    final exponent = -((t - growthPeakAge) * (t - growthPeakAge)) /
        (2 * growthSpread * growthSpread);
    final growthTerm = growthAmplitude * exp(exponent);

    // 老化の項: D·max(0, t-agingStartAge)
    final agingTerm = agingDecayRate * (t > agingStartAge ? t - agingStartAge : 0);

    return growthTerm - agingTerm;
  }

  /// 現在が成長期のピークかどうか
  bool isInGrowthPeak(int age) {
    // ピーク年齢の前後2ターン以内をピーク期間とする
    return (age - growthPeakAge).abs() <= 2;
  }

  /// 現在が老化期かどうか
  bool isAging(int age) {
    return age >= agingStartAge;
  }

  Map<String, dynamic> toJson() {
    return {
      'growthPeakAge': growthPeakAge,
      'growthSpread': growthSpread,
      'agingStartAge': agingStartAge,
      'agingDecayRate': agingDecayRate,
    };
  }

  factory ParameterGrowthCurve.fromJson(Map<String, dynamic> json) {
    return ParameterGrowthCurve(
      growthPeakAge: json['growthPeakAge'] as int,
      growthSpread: (json['growthSpread'] as num).toDouble(),
      agingStartAge: json['agingStartAge'] as int,
      agingDecayRate: (json['agingDecayRate'] as num).toDouble(),
    );
  }

  ParameterGrowthCurve copyWith({
    int? growthPeakAge,
    double? growthSpread,
    int? agingStartAge,
    double? agingDecayRate,
  }) {
    return ParameterGrowthCurve(
      growthPeakAge: growthPeakAge ?? this.growthPeakAge,
      growthSpread: growthSpread ?? this.growthSpread,
      agingStartAge: agingStartAge ?? this.agingStartAge,
      agingDecayRate: agingDecayRate ?? this.agingDecayRate,
    );
  }
}

