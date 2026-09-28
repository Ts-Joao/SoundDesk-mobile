import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/import/import_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/player/full_player_screen.dart';
import '../../features/playlists/playlist_detail_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

final _root = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _slideUp(GoRouterState s, Widget child) => CustomTransitionPage(
      key: s.pageKey, child: child, transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, a, __, c) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)).animate(a), child: c),
    );

final appRouter = GoRouter(
  navigatorKey: _root,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (_, __) => const LibraryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/playlists', builder: (_, __) => const PlaylistsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/downloads', builder: (_, __) => const DownloadsScreen())]),
      ],
    ),
    GoRoute(path: '/playlists/:id', builder: (_, s) => PlaylistDetailScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/import', builder: (_, __) => const ImportScreen()),
    GoRoute(path: '/player', parentNavigatorKey: _root, pageBuilder: (_, s) => _slideUp(s, const FullPlayerScreen())),
  ],
);
