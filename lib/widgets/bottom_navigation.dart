import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final String currentPath;

  const BottomNavigation({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(currentPath),
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/consultation-office');
            break;
          case 2:
            context.go('/dungeon');
            break;
          case 3:
            context.go('/inventory');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: '相談所',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: '探索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: '所持',
        ),
      ],
    );
  }

  int _getCurrentIndex(String path) {
    // ホーム
    if (path == '/' || path.startsWith('/player-character')) {
      return 0;
    }
    // 相談所または相談所から遷移した画面（探す、マッチ、配合）
    if (path == '/consultation-office' ||
        path.startsWith('/discover') ||
        path.startsWith('/collaborations') ||
        path.startsWith('/production')) {
      return 1;
    }
    // 探索
    if (path.startsWith('/dungeon')) {
      return 2;
    }
    // 所持一覧
    if (path.startsWith('/inventory')) {
      return 3;
    }
    // デフォルトはホーム
    return 0;
  }
}

