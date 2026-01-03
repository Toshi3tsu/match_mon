import 'package:flutter/material.dart';
import '../models/dungeon.dart';

/// 契約設定ダイアログ（探索前の指示設定）
class ContractSettingsDialog extends StatefulWidget {
  final ContractSettings? initialSettings;

  const ContractSettingsDialog({
    super.key,
    this.initialSettings,
  });

  @override
  State<ContractSettingsDialog> createState() => _ContractSettingsDialogState();
}

class _ContractSettingsDialogState extends State<ContractSettingsDialog> {
  late TargetFloor _targetFloor;
  late RiskTolerance _riskTolerance;
  late PriorityObjective _priorityObjective;

  @override
  void initState() {
    super.initState();
    _targetFloor = widget.initialSettings?.targetFloor ?? TargetFloor.middle;
    _riskTolerance = widget.initialSettings?.riskTolerance ?? RiskTolerance.standard;
    _priorityObjective = widget.initialSettings?.priorityObjective ?? PriorityObjective.wedge;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      child: Container(
        width: isMobile ? double.infinity : 600,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '契約設定',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '使役獣に指示を渡して代理遠征させます。設定した契約が使役獣の行動判断と戦闘結果に影響します。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // 目標到達層
              _buildSection(
                context,
                theme,
                '目標到達層',
                'どの階層まで到達を目指すか',
                [
                  _buildOption(
                    context,
                    theme,
                    '中層',
                    '中層まで到達を目指す。安全だが報酬は少なめ。',
                    _targetFloor == TargetFloor.middle,
                    () => setState(() => _targetFloor = TargetFloor.middle),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '深層',
                    '深層まで到達を目指す。バランスの取れた選択。',
                    _targetFloor == TargetFloor.deep,
                    () => setState(() => _targetFloor = TargetFloor.deep),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '最深部',
                    '最深部まで到達を目指す。高リスク・高リターン。',
                    _targetFloor == TargetFloor.deepest,
                    () => setState(() => _targetFloor = TargetFloor.deepest),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 危険許容度
              _buildSection(
                context,
                theme,
                '危険許容度',
                'リスクを取るか、安全重視か',
                [
                  _buildOption(
                    context,
                    theme,
                    '積極的',
                    'リスクを取って積極的に進む。報酬が増えるが、ダメージも大きい。',
                    _riskTolerance == RiskTolerance.aggressive,
                    () => setState(() => _riskTolerance = RiskTolerance.aggressive),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '標準',
                    'バランスの取れた判断。標準的なリスクと報酬。',
                    _riskTolerance == RiskTolerance.standard,
                    () => setState(() => _riskTolerance = RiskTolerance.standard),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '慎重',
                    '安全を重視して慎重に進む。ダメージは少ないが、報酬も少なめ。',
                    _riskTolerance == RiskTolerance.cautious,
                    () => setState(() => _riskTolerance = RiskTolerance.cautious),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 優先目的
              _buildSection(
                context,
                theme,
                '優先目的',
                '何を優先するか',
                [
                  _buildOption(
                    context,
                    theme,
                    '楔の確保',
                    '封印の楔を優先的に確保する。世界の状況改善に直結。',
                    _priorityObjective == PriorityObjective.wedge,
                    () => setState(() => _priorityObjective = PriorityObjective.wedge),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '資源回収',
                    '資源の回収を優先する。次回の探索に役立つ。',
                    _priorityObjective == PriorityObjective.resource,
                    () => setState(() => _priorityObjective = PriorityObjective.resource),
                  ),
                  const SizedBox(height: 8),
                  _buildOption(
                    context,
                    theme,
                    '系譜素材の獲得',
                    '系譜素材の獲得を優先する。配合に役立つ。',
                    _priorityObjective == PriorityObjective.lineageMaterial,
                    () => setState(() => _priorityObjective = PriorityObjective.lineageMaterial),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final settings = ContractSettings(
                        targetFloor: _targetFloor,
                        riskTolerance: _riskTolerance,
                        priorityObjective: _priorityObjective,
                      );
                      Navigator.of(context).pop(settings);
                    },
                    child: const Text('契約を設定して探索開始'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    String title,
    String description,
    List<Widget> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        ...options,
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    ThemeData theme,
    String title,
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

