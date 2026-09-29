import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sounddesk_mobile/features/home/home_screen.dart';
import 'package:sounddesk_mobile/shared/data/library_repository.dart';
import 'package:sounddesk_mobile/shared/models/models.dart';
import 'package:sounddesk_mobile/shared/providers.dart';

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
  testWidgets('HomeScreen renders horizontal shelves without layout errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(TestLibraryRepo()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tocadas recentemente'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Song 1'), findsOneWidget);
    expect(find.text('Playlist 1'), findsOneWidget);
  });
}
