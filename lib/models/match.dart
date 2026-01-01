import 'monster.dart';

class Match {
  final String id;
  final String partnerId;
  final Monster partner;
  final DateTime createdAt;
  final int bond; // ボンド値（0-100）
  final String status; // "active" | "used"

  Match({
    required this.id,
    required this.partnerId,
    required this.partner,
    required this.createdAt,
    required this.bond,
    required this.status,
  });

  Match copyWith({
    String? id,
    String? partnerId,
    Monster? partner,
    DateTime? createdAt,
    int? bond,
    String? status,
  }) {
    return Match(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partner: partner ?? this.partner,
      createdAt: createdAt ?? this.createdAt,
      bond: bond ?? this.bond,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'partner': partner.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'bond': bond,
      'status': status,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String,
      partner: Monster.fromJson(json['partner'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      bond: json['bond'] as int,
      status: json['status'] as String,
    );
  }
}

