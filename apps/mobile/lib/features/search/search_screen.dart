import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songsProvider).valueOrNull ?? [];
    final playlists = ref.watch(playlistsProvider);
    final q = _q.trim().toLowerCase();
    bool m(String s) => s.toLowerCase().contains(q);
    final rs = q.isEmpty ? [] : songs.where((s) => m(s.title)).toList();
    final artists = q.isEmpty ? <String>[] : songs.map((s) => s.artist).toSet().where(m).toList();
    final albums = q.isEmpty ? <String>[] : songs.map((s) => s.album).toSet().where(m).toList();
    final pls = q.isEmpty ? [] : playlists.where((p) => m(p.name)).toList();
    final none = q.isNotEmpty && rs.isEmpty && artists.isEmpty && albums.isEmpty && pls.isEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(padding: const EdgeInsets.only(right: Tk.s16),
            child: AppSearchBar(hint: 'Músicas, artistas, álbuns, playlists', autofocus: true, onChanged: (v) => setState(() => _q = v))),
      ),
      body: q.isEmpty
          ? const EmptyState(icon: Icons.search_rounded, title: 'Buscar na biblioteca', message: 'Encontre músicas, artistas, álbuns e playlists.')
          : none
              ? EmptyState(icon: Icons.search_off_rounded, title: 'Nada encontrado', message: 'Não há resultados para "$_q".')
              : ListView(children: [
                  if (rs.isNotEmpty) ...[const SectionHeader('Músicas'), for (final s in rs) SongTile(song: s, queue: [...rs])],
                  if (artists.isNotEmpty) ...[const SectionHeader('Artistas'),
                    for (final a in artists) ArtistTile(name: a, songCount: songs.where((s) => s.artist == a).length)],
                  if (albums.isNotEmpty) ...[const SectionHeader('Álbuns'),
                    for (final a in albums) ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: Tk.s16),
                        leading: Cover(seed: a, size: 48), title: Text(a),
                        subtitle: Text(songs.firstWhere((s) => s.album == a).artist, style: Theme.of(context).textTheme.bodySmall))],
                  if (pls.isNotEmpty) ...[const SectionHeader('Playlists'),
                    for (final p in pls) PlaylistCard(playlist: p, onTap: () => context.push('/playlists/${p.id}'), onMore: () {})],
                ]),
    );
  }
}
