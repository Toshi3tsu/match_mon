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
            context.go('/discover');
            break;
          case 2:
            context.go('/collaborations');
            break;
          case 3:
            context.go('/production');
            break;
          case 4:
            context.go('/dungeon');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '探す',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'マッチング',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.science),
          label: '交配',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: '探索',
        ),
      ],
    );
  }

  int _getCurrentIndex(String path) {
    if (path == '/' || path.startsWith('/player-character')) return 0;
    if (path.startsWith('/discover')) return 1;
    if (path.startsWith('/collaborations')) return 2;
    if (path.startsWith('/production')) return 3;
    if (path.startsWith('/dungeon')) return 4;
    return 0;
  }
}

