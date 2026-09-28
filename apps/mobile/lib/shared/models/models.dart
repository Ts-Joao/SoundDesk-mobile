class Song {
  final String id, title, artist, album;
  final Duration duration;
  final bool downloaded;
  const Song({required this.id, required this.title, required this.artist, required this.album, required this.duration, this.downloaded = true});
}

class Playlist {
  final String id, name;
  final List<String> songIds;
  final DateTime updatedAt;
  const Playlist({required this.id, required this.name, required this.songIds, required this.updatedAt});
  Playlist copyWith({String? name, List<String>? songIds}) =>
      Playlist(id: id, name: name ?? this.name, songIds: songIds ?? this.songIds, updatedAt: DateTime.now());
}

enum DownloadStatus { downloading, queued, completed, failed }

class DownloadTask {
  final String id;
  final Song song;
  final DownloadStatus status;
  final int received, total; // bytes
  const DownloadTask({required this.id, required this.song, required this.status, this.received = 0, this.total = 0});
  double get progress => total == 0 ? 0 : received / total;
  DownloadTask copyWith({DownloadStatus? status, int? received}) =>
      DownloadTask(id: id, song: song, status: status ?? this.status, received: received ?? this.received, total: total);
}
