import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool automaticallyImplyLeading;
  final String? fallbackRoute;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    
    // 日付をフォーマット
    final dateFormat = DateFormat('yyyy年MM月dd日', 'ja_JP');
    final formattedDate = dateFormat.format(state.currentDate);

    // 既存のactionsと日付を結合
    final allActions = <Widget>[
      // 日付表示
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            formattedDate,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      // 既存のactionsがあれば追加
      if (actions != null) ...actions!,
    ];

    return AppBar(
      title: Text(title),
      actions: allActions,
      bottom: bottom != null ? PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: bottom!,
      ) : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(fallbackRoute ?? '/');
                }
              },
            )
          : null,
    );
  }

  @override
  Size get preferredSize {
    if (bottom != null) {
      return const Size.fromHeight(kToolbarHeight + 48);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

