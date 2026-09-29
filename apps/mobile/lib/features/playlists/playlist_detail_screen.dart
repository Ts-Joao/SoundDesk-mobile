import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';
import 'playlists_screen.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String id;
  const PlaylistDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playlistsProvider).where((e) => e.id == id).firstOrNull;
    final all = ref.watch(songsProvider).valueOrNull ?? [];
    if (p == null) return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    final songs = [for (final sid in p.songIds) ...all.where((s) => s.id == sid)];
    return Scaffold(
      appBar: AppBar(actions: [AppIconButton(icon: Icons.more_vert_rounded, tooltip: 'Opções', onPressed: () => playlistOptions(context, ref, p, popAfterDelete: true))]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(Tk.s16),
          child: Row(children: [
            Cover(seed: p.id, size: 96, radius: Tk.rMd),
            const SizedBox(width: Tk.s16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: Tk.s4),
              Text('${songs.length} músicas', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: Tk.s12),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                onPressed: songs.isEmpty ? null : () => ref.read(playerProvider.notifier).play(songs.first, songs),
                icon: const Icon(Icons.play_arrow_rounded), label: const Text('Tocar'),
              ),
            ])),
          ]),
        ),
        Expanded(
          child: songs.isEmpty
              ? const EmptyState(icon: Icons.music_note_rounded, title: 'Playlist vazia',
                  message: 'Use o menu de uma música para adicioná-la aqui.')
              : SongList(songs),
        ),
      ]),
    );
  }
}
