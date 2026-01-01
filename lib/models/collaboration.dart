import 'monster.dart';
import 'match_session.dart';

class Collaboration {
  final String id;
  final String partnerId;
  final Monster partner;
  final DateTime createdAt;
  final int bond; // ボンド値（0-100）
  final String status; // "active" | "used"
  final MatchSession? session; // マッチ後セッション

  Collaboration({
    required this.id,
    required this.partnerId,
    required this.partner,
    required this.createdAt,
    required this.bond,
    required this.status,
    this.session,
  });

  Collaboration copyWith({
    String? id,
    String? partnerId,
    Monster? partner,
    DateTime? createdAt,
    int? bond,
    String? status,
    MatchSession? session,
  }) {
    return Collaboration(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partner: partner ?? this.partner,
      createdAt: createdAt ?? this.createdAt,
      bond: bond ?? this.bond,
      status: status ?? this.status,
      session: session ?? this.session,
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
      'session': session?.toJson(),
    };
  }

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String,
      partner: Monster.fromJson(json['partner'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      bond: json['bond'] as int,
      status: json['status'] as String,
      session: json['session'] != null
          ? MatchSession.fromJson(json['session'] as Map<String, dynamic>)
          : null,
    );
  }
}

