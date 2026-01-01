import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/monster_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _filterSpecies = '';
  String _filterRank = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    final filteredInventory = state.inventory.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.species.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.tags.any((tag) =>
              tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSpecies =
          _filterSpecies.isEmpty || user.species == _filterSpecies;
      final matchesRank = _filterRank.isEmpty || user.rank == _filterRank;
      return matchesSearch && matchesSpecies && matchesRank;
    }).toList();

    final speciesList = state.inventory.map((u) => u.species).toSet().toList();
    final rankList = state.inventory.map((u) => u.rank).toSet().toList();

    return Scaffold(
      appBar: const CustomAppBar(
        title: '所持一覧',
      ),
      body: Column(
        children: [
          // 検索・フィルタ
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '検索...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '種族',
                            border: OutlineInputBorder(),
                          ),
                          value: _filterSpecies.isEmpty ? null : _filterSpecies,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('すべての種族'),
                            ),
                            ...speciesList.map<DropdownMenuItem<String>>((species) {
                              return DropdownMenuItem<String>(
                                value: species,
                                child: Text(species),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _filterSpecies = value ?? '');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '位階',
                            border: OutlineInputBorder(),
                          ),
                          value: _filterRank.isEmpty ? null : _filterRank,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('すべての位階'),
                            ),
                            ...rankList.map<DropdownMenuItem<String>>((rank) {
                              return DropdownMenuItem<String>(
                                value: rank,
                                child: Text(rank),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _filterRank = value ?? '');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 個体リスト
          Expanded(
            child: filteredInventory.isEmpty
                ? Center(
                    child: Text(
                      state.inventory.isEmpty
                          ? '所持個体がありません'
                          : '検索条件に一致する個体がありません',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // 画面幅に応じて列数を計算
                      final double screenWidth = constraints.maxWidth;
                      int crossAxisCount;
                      if (screenWidth < 600) {
                        crossAxisCount = 1; // モバイル
                      } else if (screenWidth < 900) {
                        crossAxisCount = 2; // タブレット
                      } else if (screenWidth < 1200) {
                        crossAxisCount = 3; // 小デスクトップ
                      } else if (screenWidth < 1800) {
                        crossAxisCount = 4; // デスクトップ
                      } else {
                        crossAxisCount = 5; // 大画面
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredInventory.length,
                        itemBuilder: (context, index) {
                          final monster = filteredInventory[index];
                          return Stack(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: MonsterCard(
                                      monster: monster,
                                      imageFirst: true,
                                      showDetails: false,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  CustomButton(
                                    text: '交配に使用',
                                    onPressed: () => context.go('/production'),
                                    variant: ButtonVariant.secondary,
                                    size: ButtonSize.small,
                                    icon: const Icon(Icons.science, size: 16),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    monster.locked
                                        ? Icons.lock
                                        : Icons.lock_open,
                                    color: monster.locked
                                        ? Colors.yellow.shade700
                                        : Colors.grey,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(appStateProvider.notifier)
                                        .toggleLock(monster.id);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

