import '../models/models.dart';

/// Swap this implementation for SQLite/API later; UI only depends on this contract.
abstract class LibraryRepository {
  Future<List<Song>> songs();
  Future<List<Playlist>> playlists();
  Future<List<DownloadTask>> downloads();
}

class MockLibraryRepository implements LibraryRepository {
  static const _raw = [
    ['Casa Vazia', 'Marina Alves', 'Janelas', 214, true],
    ['Linha do Horizonte', 'Marina Alves', 'Janelas', 187, true],
    ['Maré Baixa', 'Duo Cais', 'Sal', 243, true],
    ['Trilho', 'Duo Cais', 'Sal', 198, true],
    ['Domingo Longo', 'Rafael Prado', 'Sem Pressa', 262, true],
    ['Quintal', 'Rafael Prado', 'Sem Pressa', 176, true],
    ['Vidro Fosco', 'Nina Coutinho', 'Ruído Branco', 231, true],
    ['Ponte', 'Nina Coutinho', 'Ruído Branco', 205, true],
    ['Farol', 'Orquestra Lume', 'Noite Clara', 289, true],
    ['Estação Sul', 'Orquestra Lume', 'Noite Clara', 254, false],
    ['Chuva de Verão', 'Tiago Meirelles', 'Arquivo', 192, false],
    ['Velho Rádio', 'Tiago Meirelles', 'Arquivo', 221, false],
  ];

  static final _songs = [
    for (var i = 0; i < _raw.length; i++)
      Song(id: 's$i', title: _raw[i][0] as String, artist: _raw[i][1] as String, album: _raw[i][2] as String,
          duration: Duration(seconds: _raw[i][3] as int), downloaded: _raw[i][4] as bool),
  ];

  @override
  Future<List<Song>> songs() async {
    await Future.delayed(const Duration(milliseconds: 600)); // exercises the loading state
    return _songs;
  }

  @override
  Future<List<Playlist>> playlists() async => [
        Playlist(id: 'p1', name: 'Foco', songIds: ['s0', 's4', 's6', 's8'], updatedAt: DateTime.now().subtract(const Duration(hours: 3))),
        Playlist(id: 'p2', name: 'Estrada', songIds: ['s1', 's2', 's3', 's5', 's7'], updatedAt: DateTime.now().subtract(const Duration(days: 2))),
        Playlist(id: 'p3', name: 'Madrugada', songIds: ['s8', 's9'], updatedAt: DateTime.now().subtract(const Duration(days: 9))),
      ];

  @override
  Future<List<DownloadTask>> downloads() async => [
        DownloadTask(id: 'd1', song: _songs[9], status: DownloadStatus.downloading, received: 4404019, total: 6081741),
        DownloadTask(id: 'd2', song: _songs[10], status: DownloadStatus.queued, total: 5200000),
        DownloadTask(id: 'd3', song: _songs[11], status: DownloadStatus.failed, total: 5600000),
        DownloadTask(id: 'd4', song: _songs[8], status: DownloadStatus.completed, received: 7100000, total: 7100000),
      ];
}
