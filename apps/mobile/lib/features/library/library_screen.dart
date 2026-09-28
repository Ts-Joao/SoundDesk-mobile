import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

enum _Sort { title, artist, duration }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _q = '';
  _Sort _sort = _Sort.title;
  bool _onlyDownloaded = false;

  List<Song> _apply(List<Song> all) {
    var l = all.where((s) => (!_onlyDownloaded || s.downloaded) &&
        ('${s.title} ${s.artist} ${s.album}'.toLowerCase().contains(_q.toLowerCase()))).toList();
    l.sort((a, b) => switch (_sort) {
          _Sort.title => a.title.compareTo(b.title),
          _Sort.artist => a.artist.compareTo(b.artist),
          _Sort.duration => a.duration.compareTo(b.duration),
        });
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songsProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          bottom: const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, dividerColor: Colors.transparent,
              tabs: [Tab(text: 'Músicas'), Tab(text: 'Artistas'), Tab(text: 'Álbuns'), Tab(text: 'Baixadas')]),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s8, Tk.s8, Tk.s4),
            child: Row(children: [
              Expanded(child: AppSearchBar(hint: 'Buscar na biblioteca', onChanged: (v) => setState(() => _q = v))),
              PopupMenuButton<_Sort>(
                icon: const Icon(Icons.sort_rounded), tooltip: 'Ordenar', initialValue: _sort,
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _Sort.title, child: Text('Título')),
                  PopupMenuItem(value: _Sort.artist, child: Text('Artista')),
                  PopupMenuItem(value: _Sort.duration, child: Text('Duração')),
                ],
              ),
            ]),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tk.s16),
              child: FilterChip(
                label: const Text('Somente baixadas'), selected: _onlyDownloaded, showCheckmark: false,
                onSelected: (v) => setState(() => _onlyDownloaded = v),
              ),
            ),
          ),
          Expanded(
            child: songs.when(
              loading: () => const LoadingState(),
              error: (_, __) => ErrorState(message: 'Não foi possível ler sua biblioteca.', onRetry: () => ref.invalidate(songsProvider)),
              data: (all) {
                if (all.isEmpty) {
                  return EmptyState(icon: Icons.library_music_outlined, title: 'Sua biblioteca está vazia',
                      message: 'Adicione ou baixe sua primeira música para começar a montar sua biblioteca.',
                      actionLabel: 'Adicionar música', onAction: () {});
                }
                final list = _apply(all);
                final artists = <String, int>{};
                final albums = <String, String>{};
                for (final s in list) {
                  artists[s.artist] = (artists[s.artist] ?? 0) + 1;
                  albums[s.album] = s.artist;
                }
                if (list.isEmpty) {
                  return const EmptyState(icon: Icons.search_off_rounded, title: 'Nada encontrado', message: 'Tente outro termo ou remova os filtros.');
                }
                return TabBarView(children: [
                  SongList(list),
                  ListView(children: [for (final e in artists.entries) ArtistTile(name: e.key, songCount: e.value)]),
                  GridView.count(
                    crossAxisCount: 2, mainAxisSpacing: Tk.s16, crossAxisSpacing: Tk.s16, childAspectRatio: 0.85,
                    padding: const EdgeInsets.all(Tk.s16),
                    children: [for (final e in albums.entries) LayoutBuilder(builder: (_, c) => AlbumCard(title: e.key, subtitle: e.value, seed: e.key))],
                  ),
                  SongList(list.where((s) => s.downloaded).toList()),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
