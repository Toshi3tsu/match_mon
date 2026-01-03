import 'dart:math' show Random, sqrt, log, cos, pi;
import '../models/parameter_growth_curve.dart';

/// モンスター種族ごとの個体値（パラメータ成長の係数）
/// 設計書 4.8.3 参照
/// 個体の偏差値 × モンスターの個体値 = その個体のパラメータ成長の特性

class SpeciesIndividualValue {
  final Map<String, double> parameterGrowthCoefficients; // パラメータごとの成長係数

  SpeciesIndividualValue({
    required this.parameterGrowthCoefficients,
  });
}

/// 種族ごとの個体値マスターデータ
final Map<String, SpeciesIndividualValue> speciesIndividualValues = {
  'ドラゴン': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 1.2,
      '防御力': 0.9,
      '魔力': 1.1,
      '敏捷性': 0.8,
      'HP': 1.0,
    },
  ),
  'フェニックス': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 0.9,
      '防御力': 1.0,
      '魔力': 1.3,
      '敏捷性': 1.1,
      'HP': 1.1,
    },
  ),
  'ビースト': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 1.1,
      '防御力': 1.0,
      '魔力': 0.8,
      '敏捷性': 1.3,
      'HP': 1.2,
    },
  ),
  'ゴーレム': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 1.0,
      '防御力': 1.4,
      '魔力': 0.7,
      '敏捷性': 0.6,
      'HP': 1.3,
    },
  ),
  'スピリット': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 0.8,
      '防御力': 0.9,
      '魔力': 1.2,
      '敏捷性': 1.1,
      'HP': 0.9,
    },
  ),
  'ヒューマノイド': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 1.0,
      '防御力': 1.0,
      '魔力': 1.1,
      '敏捷性': 1.0,
      'HP': 1.0,
    },
  ),
  'スライム': SpeciesIndividualValue(
    parameterGrowthCoefficients: {
      '攻撃力': 0.9,
      '防御力': 0.8,
      '魔力': 1.0,
      '敏捷性': 1.0,
      'HP': 1.1,
    },
  ),
};

/// 性別による正規分布のパラメータ
/// 設計書 4.8.3 参照
const double maleDistributionMean = 1.0; // オス用の正規分布の平均
const double maleDistributionStdDev = 0.3; // オス用の正規分布の標準偏差
const double femaleDistributionMean = 1.0; // メス用の正規分布の平均
const double femaleDistributionStdDev = 0.1; // メス用の正規分布の標準偏差

/// 個体の偏差値をサンプリング
/// 性別に応じた正規分布から偏差値を決定
double sampleIndividualDeviationValue(String gender) {
  final random = Random();
  
  if (gender == 'male') {
    // オス用の正規分布N(μ_オス, σ_オス²)からサンプリング
    // Box-Muller変換を使用
    final u1 = random.nextDouble();
    final u2 = random.nextDouble();
    final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return maleDistributionMean + maleDistributionStdDev * z;
  } else {
    // メス用の正規分布N(μ_メス, σ_メス²)からサンプリング
    final u1 = random.nextDouble();
    final u2 = random.nextDouble();
    final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return femaleDistributionMean + femaleDistributionStdDev * z;
  }
}

/// パラメータごとのデフォルト成長カーブ設定
/// 設計書 4.8.3 参照
Map<String, ParameterGrowthCurve> getDefaultParameterGrowthCurves() {
  return {
    '攻撃力': ParameterGrowthCurve(
      growthPeakAge: 12, // 攻撃力は早めに成長
      growthSpread: 4.0,
      agingStartAge: 25,
      agingDecayRate: 0.15,
    ),
    '防御力': ParameterGrowthCurve(
      growthPeakAge: 18, // 防御力は遅めに成長
      growthSpread: 5.0,
      agingStartAge: 28,
      agingDecayRate: 0.1,
    ),
    '魔力': ParameterGrowthCurve(
      growthPeakAge: 15,
      growthSpread: 5.0,
      agingStartAge: 25,
      agingDecayRate: 0.12,
    ),
    '敏捷性': ParameterGrowthCurve(
      growthPeakAge: 10, // 敏捷性は最も早く成長
      growthSpread: 3.0,
      agingStartAge: 22,
      agingDecayRate: 0.2,
    ),
    'HP': ParameterGrowthCurve(
      growthPeakAge: 16,
      growthSpread: 5.0,
      agingStartAge: 30,
      agingDecayRate: 0.08,
    ),
  };
}

