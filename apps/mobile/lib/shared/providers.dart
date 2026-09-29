import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/library_repository.dart';
import 'models/models.dart';

// ---- Infra ----
final libraryRepositoryProvider = Provider<LibraryRepository>((_) => MockLibraryRepository());
final songsProvider = FutureProvider<List<Song>>((ref) => ref.watch(libraryRepositoryProvider).songs());

/// Derived, cached by Riverpod: only recomputes when the song list actually
/// changes, so Library/Albums tab switches don't re-scan the catalog.
final albumsProvider = Provider<List<AlbumInfo>>((ref) {
  final songs = ref.watch(songsProvider).valueOrNull ?? const [];
  final byAlbum = <String, List<Song>>{};
  for (final s in songs) {
    byAlbum.putIfAbsent(s.album, () => []).add(s);
  }
  return [for (final e in byAlbum.entries) AlbumInfo(name: e.key, artist: e.value.first.artist, songs: e.value)];
});

final artistsProvider = Provider<Map<String, int>>((ref) {
  final songs = ref.watch(songsProvider).valueOrNull ?? const [];
  final map = <String, int>{};
  for (final s in songs) {
    map[s.artist] = (map[s.artist] ?? 0) + 1;
  }
  return map;
});

class AlbumInfo {
  final String name, artist;
  final List<Song> songs;
  const AlbumInfo({required this.name, required this.artist, required this.songs});
}

// ---- Settings ----
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system; // persist with SQLite/shared_prefs later
  void set(ThemeMode m) => state = m;
}
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class BoolNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}
/// Demo switch; replace with connectivity_plus.
final offlineProvider = NotifierProvider<BoolNotifier, bool>(BoolNotifier.new);

class QualityNotifier extends Notifier<String> {
  @override
  String build() => 'Alta';
  void set(String v) => state = v;
}
final audioQualityProvider = NotifierProvider<QualityNotifier, String>(QualityNotifier.new);

/// Whether the persistent mini player shows above the nav bar.
/// Settings → Player → "Mostrar mini player".
class MiniPlayerVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true; // persist with SharedPreferences later
  void set(bool v) => state = v;
}
final miniPlayerVisibleProvider = NotifierProvider<MiniPlayerVisibilityNotifier, bool>(MiniPlayerVisibilityNotifier.new);

/// Root folder for SoundDesk/{Music,Albums,Playlists,Covers,Downloads}.
/// Backed today by a plain string; swap for path_provider + file_picker
/// (Android SAF / iOS document picker) without touching the UI.
class StorageLocationNotifier extends Notifier<String> {
  @override
  String build() => '/storage/emulated/0/SoundDesk';

  /// Returns null (accepted) or an error message.
  String? trySet(String path) {
    final p = path.trim();
    if (!p.startsWith('/')) return 'Informe um caminho absoluto.';
    if (p.length < 3) return 'Caminho muito curto.';
    state = p; // TODO: on real FS, move/relink existing downloads here
    return null;
  }
}
final storageLocationProvider = NotifierProvider<StorageLocationNotifier, String>(StorageLocationNotifier.new);
const storageSubfolders = ['Music', 'Albums', 'Playlists', 'Covers', 'Downloads'];

// ---- Playlists ----
class PlaylistsNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() {
    ref.read(libraryRepositoryProvider).playlists().then((v) => state = v);
    return const [];
  }

  void create(String name) => state = [
        Playlist(id: 'p${DateTime.now().microsecondsSinceEpoch}', name: name, songIds: const [], updatedAt: DateTime.now()),
        ...state,
      ];
  void rename(String id, String name) => state = [for (final p in state) p.id == id ? p.copyWith(name: name) : p];
  void delete(String id) => state = state.where((p) => p.id != id).toList();
  void addSong(String id, String songId) => state = [
        for (final p in state)
          if (p.id == id && !p.songIds.contains(songId)) p.copyWith(songIds: [...p.songIds, songId]) else p
      ];
}
final playlistsProvider = NotifierProvider<PlaylistsNotifier, List<Playlist>>(PlaylistsNotifier.new);

// ---- Downloads (simulated progress) ----
class DownloadsNotifier extends Notifier<List<DownloadTask>> {
  Timer? _timer;

  @override
  List<DownloadTask> build() {
    ref.onDispose(() => _timer?.cancel());
    ref.read(libraryRepositoryProvider).downloads().then((v) {
      state = v;
      _ensureTimer();
    });
    return const [];
  }

  void _ensureTimer() {
    if (!state.any((t) => t.status == DownloadStatus.downloading || t.status == DownloadStatus.queued)) return;
    _timer ??= Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void _tick() {
    var list = [...state];
    if (!list.any((t) => t.status == DownloadStatus.downloading)) {
      final i = list.indexWhere((t) => t.status == DownloadStatus.queued);
      if (i >= 0) list[i] = list[i].copyWith(status: DownloadStatus.downloading);
    }
    list = [
      for (final t in list)
        if (t.status == DownloadStatus.downloading)
          (t.received + 180000 >= t.total)
              ? t.copyWith(status: DownloadStatus.completed, received: t.total)
              : t.copyWith(received: t.received + 180000)
        else
          t
    ];
    state = list;
    if (!list.any((t) => t.status == DownloadStatus.downloading || t.status == DownloadStatus.queued)) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void enqueue(Song s) {
    if (state.any((t) => t.song.id == s.id)) return;
    state = [...state, DownloadTask(id: 'd${s.id}', song: s, status: DownloadStatus.queued, total: 5500000)];
    _ensureTimer();
  }

  void retry(String id) {
    state = [for (final t in state) t.id == id ? t.copyWith(status: DownloadStatus.queued, received: 0) : t];
    _ensureTimer();
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
    if (!state.any((t) => t.status == DownloadStatus.downloading || t.status == DownloadStatus.queued)) {
      _timer?.cancel();
      _timer = null;
    }
  }
}
final downloadsProvider = NotifierProvider<DownloadsNotifier, List<DownloadTask>>(DownloadsNotifier.new);

// ---- Album zip download ----
enum AlbumZipPhase { idle, preparing, zipping, done, error }

class AlbumZipState {
  final AlbumZipPhase phase;
  final int done, total;
  const AlbumZipState({this.phase = AlbumZipPhase.idle, this.done = 0, this.total = 0});
  AlbumZipState copyWith({AlbumZipPhase? phase, int? done}) =>
      AlbumZipState(phase: phase ?? this.phase, done: done ?? this.done, total: total);
}

/// One notifier instance per album (keyed by album name) via .family, so
/// progress for one album never rebuilds another album's screen.
class AlbumZipNotifier extends FamilyNotifier<AlbumZipState, String> {
  Timer? _timer;
  @override
  AlbumZipState build(String arg) {
    ref.onDispose(() => _timer?.cancel());
    return const AlbumZipState();
  }

  void start(int songCount) {
    _timer?.cancel();
    state = AlbumZipState(phase: AlbumZipPhase.preparing, done: 0, total: songCount);
    var i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 450), (t) {
      i++;
      if (i <= songCount) {
        state = state.copyWith(phase: AlbumZipPhase.preparing, done: i);
      } else if (i == songCount + 1) {
        state = state.copyWith(phase: AlbumZipPhase.zipping);
      } else {
        state = state.copyWith(phase: AlbumZipPhase.done);
        t.cancel(); // TODO: write real zip via `archive` pkg into storageLocationProvider path
      }
    });
  }

  void reset() { _timer?.cancel(); state = const AlbumZipState(); }
}
final albumZipProvider = NotifierProvider.family<AlbumZipNotifier, AlbumZipState, String>(AlbumZipNotifier.new);

// ---- Player (fake clock; swap for just_audio) ----
class PlayerState {
  final Song? song;
  final List<Song> queue;
  final bool playing;
  final Duration position;
  final double volume;
  const PlayerState({this.song, this.queue = const [], this.playing = false, this.position = Duration.zero, this.volume = 0.8});
  PlayerState copyWith({Song? song, List<Song>? queue, bool? playing, Duration? position, double? volume}) => PlayerState(
      song: song ?? this.song, queue: queue ?? this.queue, playing: playing ?? this.playing,
      position: position ?? this.position, volume: volume ?? this.volume);
}

class PlayerNotifier extends Notifier<PlayerState> {
  Timer? _timer;
  @override
  PlayerState build() {
    ref.onDispose(() => _timer?.cancel());
    return const PlayerState();
  }

  void play(Song s, List<Song> queue) {
    state = PlayerState(song: s, queue: queue, playing: true, volume: state.volume);
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state.song;
      if (s == null) return;
      final next = state.position + const Duration(seconds: 1);
      next >= s.duration ? skip(1) : state = state.copyWith(position: next);
    });
  }

  void toggle() {
    if (state.song == null) return;
    if (state.playing) {
      _timer?.cancel();
    } else {
      _start();
    }
    state = state.copyWith(playing: !state.playing);
  }

  void skip(int dir) {
    final s = state.song;
    if (s == null || state.queue.isEmpty) return;
    if (dir < 0 && state.position.inSeconds > 3) return seek(Duration.zero);
    final i = state.queue.indexWhere((e) => e.id == s.id);
    final n = state.queue[(i + dir) % state.queue.length];
    state = state.copyWith(song: n, position: Duration.zero);
  }

  void seek(Duration d) => state = state.copyWith(position: d);
  void setVolume(double v) => state = state.copyWith(volume: v);
}
final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);
