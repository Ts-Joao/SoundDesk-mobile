import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final q = _q.toLowerCase();
    final l = all.where((s) => (!_onlyDownloaded || s.downloaded) &&
        ('${s.title} ${s.artist} ${s.album}'.toLowerCase().contains(q))).toList();
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
    // Albums/artists come from shared derived providers so switching tabs
    // never re-scans the whole catalog — only songsProvider triggers that.
    final albums = ref.watch(albumsProvider);
    final artists = ref.watch(artistsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          actions: const [NowPlayingAction()],
          bottom: const TabBar(tabs: [Tab(text: 'Músicas'), Tab(text: 'Artistas'), Tab(text: 'Álbuns'), Tab(text: 'Baixadas')]),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s12, Tk.s8, Tk.s4),
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
              padding: const EdgeInsets.symmetric(horizontal: Tk.s16, vertical: Tk.s4),
              child: FilterChip(
                label: const Text('Somente baixadas'), selected: _onlyDownloaded, showCheckmark: false,
                onSelected: (v) => setState(() => _onlyDownloaded = v),
              ),
            ),
          ),
          const SizedBox(height: Tk.s4),
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
                final q = _q.toLowerCase();
                final filteredArtists = q.isEmpty ? artists : {for (final e in artists.entries.where((e) => e.key.toLowerCase().contains(q))) e.key: e.value};
                final filteredAlbums = q.isEmpty ? albums : albums.where((a) => a.name.toLowerCase().contains(q)).toList();

                return TabBarView(children: [
                  list.isEmpty
                      ? const EmptyState(icon: Icons.search_off_rounded, title: 'Nada encontrado', message: 'Tente outro termo ou remova os filtros.')
                      : SongList(list),
                  filteredArtists.isEmpty
                      ? const EmptyState(icon: Icons.search_off_rounded, title: 'Nada encontrado', message: 'Tente outro termo.')
                      : ListView.builder(
                          itemCount: filteredArtists.length,
                          itemBuilder: (_, i) {
                            final e = filteredArtists.entries.elementAt(i);
                            return ArtistTile(name: e.key, songCount: e.value);
                          },
                        ),
                  filteredAlbums.isEmpty
                      ? const EmptyState(icon: Icons.search_off_rounded, title: 'Nada encontrado', message: 'Tente outro termo.')
                      : GridView.builder(
                          // Max-extent delegate: columns adapt to screen width instead of a
                          // fixed count, so the grid fills the row edge-to-edge on any device.
                          padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s12, Tk.s16, Tk.s24),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 168, mainAxisSpacing: Tk.s24, crossAxisSpacing: Tk.s16, childAspectRatio: 0.72),
                          itemCount: filteredAlbums.length,
                          itemBuilder: (_, i) {
                            final a = filteredAlbums[i];
                            return AlbumCard(title: a.name, subtitle: a.artist, seed: a.name,
                                onTap: () => context.push('/albums/${Uri.encodeComponent(a.name)}'));
                          },
                        ),
                  list.where((s) => s.downloaded).isEmpty
                      ? const EmptyState(icon: Icons.download_outlined, title: 'Nenhuma música baixada', message: 'As músicas baixadas aparecem aqui.')
                      : SongList(list.where((s) => s.downloaded).toList()),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
