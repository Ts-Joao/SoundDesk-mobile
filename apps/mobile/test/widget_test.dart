import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sounddesk_mobile/core/theme/app_theme.dart';
import 'package:sounddesk_mobile/features/home/home_screen.dart';
import 'package:sounddesk_mobile/features/player/full_player_screen.dart';
import 'package:sounddesk_mobile/features/playlists/playlists_screen.dart';
import 'package:sounddesk_mobile/shared/data/library_repository.dart';
import 'package:sounddesk_mobile/shared/models/models.dart';
import 'package:sounddesk_mobile/shared/providers.dart';
import 'package:sounddesk_mobile/shared/widgets/components.dart';

class TestLibraryRepo implements LibraryRepository {
  @override
  Future<List<Song>> songs() async => [
        const Song(id: 's1', title: 'Song 1', artist: 'Artist 1', album: 'Album 1', duration: Duration(minutes: 3), downloaded: true),
        const Song(id: 's2', title: 'Song 2', artist: 'Artist 2', album: 'Album 2', duration: Duration(minutes: 4), downloaded: true),
      ];

  @override
  Future<List<Playlist>> playlists() async => [
        Playlist(id: 'p1', name: 'Playlist 1', songIds: ['s1'], updatedAt: DateTime.now()),
      ];

  @override
  Future<List<DownloadTask>> downloads() async => [];
}

void main() {
  testWidgets('HomeScreen renders with new palette without layout errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(TestLibraryRepo()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tocadas recentemente'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Song 1'), findsOneWidget);
    expect(find.text('Playlist 1'), findsOneWidget);
    expect(find.text('Ir para a biblioteca'), findsOneWidget);
  });

  testWidgets('PlaylistsScreen renders with styled FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(TestLibraryRepo()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const PlaylistsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Nova playlist'), findsWidgets);
  });

  testWidgets('FullPlayerScreen renders ambient glow and controls', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(TestLibraryRepo()),
      ],
    );
    addTearDown(() {
      container.read(playerProvider.notifier).stop();
      container.dispose();
    });

    const testSong = Song(id: 's1', title: 'Song 1', artist: 'Artist 1', album: 'Album 1', duration: Duration(minutes: 3), downloaded: true);
    container.read(playerProvider.notifier).play(testSong, [testSong]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const FullPlayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tocando agora'), findsOneWidget);
    expect(find.text('Song 1'), findsOneWidget);
    expect(find.text('Artist 1'), findsOneWidget);

    container.read(playerProvider.notifier).stop();
  });

  testWidgets('MiniPlayer renders and closes when close button is tapped', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(TestLibraryRepo()),
      ],
    );
    addTearDown(() {
      container.read(playerProvider.notifier).stop();
      container.dispose();
    });

    const testSong = Song(id: 's1', title: 'Song 1', artist: 'Artist 1', album: 'Album 1', duration: Duration(minutes: 3), downloaded: true);
    container.read(playerProvider.notifier).play(testSong, [testSong]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            bottomNavigationBar: MiniPlayer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Song 1'), findsOneWidget);
    expect(find.byTooltip('Fechar player'), findsOneWidget);

    // Tap close button
    await tester.tap(find.byTooltip('Fechar player'));
    await tester.pumpAndSettle();

    // Verify MiniPlayer is dismissed and song is null
    expect(find.text('Song 1'), findsNothing);
    expect(container.read(playerProvider).song, isNull);
  });
}
