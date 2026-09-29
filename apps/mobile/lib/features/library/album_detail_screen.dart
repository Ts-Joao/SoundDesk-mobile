import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final String name;
  const AlbumDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumsProvider).where((a) => a.name == name).firstOrNull;
    if (album == null) return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    final zip = ref.watch(albumZipProvider(name));
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(actions: [const NowPlayingAction(), AppIconButton(icon: Icons.more_vert_rounded, tooltip: 'Opções', onPressed: () {})]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Tk.s16, 0, Tk.s16, Tk.s16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Cover(seed: album.name, size: 100, radius: Tk.rMd),
            const SizedBox(width: Tk.s16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(album.name, style: t.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: Tk.s4),
              Text(album.artist, style: t.bodyMedium?.copyWith(color: t.bodySmall?.color)),
              const SizedBox(height: 2),
              Text('${album.songs.length} músicas', style: t.bodySmall),
              const SizedBox(height: Tk.s12),
              Row(children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 16)),
                  onPressed: () => ref.read(playerProvider.notifier).play(album.songs.first, album.songs),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20), label: const Text('Tocar'),
                ),
                const SizedBox(width: Tk.s8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 14)),
                  onPressed: zip.phase == AlbumZipPhase.idle || zip.phase == AlbumZipPhase.error
                      ? () => ref.read(albumZipProvider(name).notifier).start(album.songs.length)
                      : null,
                  icon: const Icon(Icons.folder_zip_outlined, size: 18), label: const Text('Baixar álbum'),
                ),
              ]),
            ])),
          ]),
        ),
        if (zip.phase != AlbumZipPhase.idle) AlbumZipPanel(name: name, total: album.songs.length),
        const Divider(height: 1),
        Expanded(child: SongList(album.songs)),
      ]),
    );
  }
}

/// Preparing → Compacting → Done panel for the album-zip flow.
/// Kept as its own widget so only this row rebuilds while the timer ticks.
class AlbumZipPanel extends ConsumerWidget {
  final String name;
  final int total;
  const AlbumZipPanel({super.key, required this.name, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zip = ref.watch(albumZipProvider(name));
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    late final String label;
    late final Widget leading;
    switch (zip.phase) {
      case AlbumZipPhase.preparing:
        label = 'Preparando álbum…  ${zip.done} de $total músicas';
        leading = SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, value: zip.done / total));
      case AlbumZipPhase.zipping:
        label = 'Compactando…';
        leading = const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2));
      case AlbumZipPhase.done:
        label = 'Álbum pronto';
        leading = Icon(Icons.check_circle_rounded, size: 18, color: cs.primary);
      case AlbumZipPhase.error:
        label = 'Não foi possível gerar o arquivo.';
        leading = Icon(Icons.error_outline_rounded, size: 18, color: cs.error);
      case AlbumZipPhase.idle:
        label = ''; leading = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(Tk.s16, 0, Tk.s16, Tk.s16),
      padding: const EdgeInsets.all(Tk.s12),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(Tk.rMd), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(children: [
        leading,
        const SizedBox(width: Tk.s12),
        Expanded(child: Text(label, style: t.bodyMedium)),
        if (zip.phase == AlbumZipPhase.done)
          TextButton(
            // TODO: replace with FileSaver/share sheet once real zip bytes exist.
            onPressed: () { ref.read(albumZipProvider(name).notifier).reset(); },
            child: const Text('Salvar ZIP'),
          ),
      ]),
    );
  }
}
