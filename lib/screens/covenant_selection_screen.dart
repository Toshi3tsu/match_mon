import 'package:flutter/material.dart';
import '../models/collaboration.dart';
import '../models/match_session.dart';
import '../widgets/custom_app_bar.dart';

/// 盟約（コミット）の選択画面
/// 設計書 5.5.3 参照
class CovenantSelectionScreen extends StatelessWidget {
  final Collaboration collaboration;
  final MatchSession session;
  final Function(CovenantClause) onClauseSelected;

  const CovenantSelectionScreen({
    super.key,
    required this.collaboration,
    required this.session,
    required this.onClauseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableClauses = session.covenantState?.availableClauses ?? [];

    return Scaffold(
      appBar: const CustomAppBar(
        title: '盟約の選択',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '盟約の選択',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'トレードオフ付きの条項を選択してください。選択した条項は配合プランナーに反映されます。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 条項一覧
            Text(
              '利用可能な条項',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...availableClauses.map((clause) => _buildClauseCard(clause, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildClauseCard(CovenantClause clause, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onClauseSelected(clause),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clause.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      clause.benefit,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      clause.cost,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

