import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../models/models.dart';
import '../providers.dart';

/// Cover placeholder: muted hue derived from a seed. Replace child with Image.file later.
class Cover extends StatelessWidget {
  final String seed;
  final double? size;
  final double radius;
  const Cover({super.key, required this.seed, this.size, this.radius = Tk.rSm});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = HSLColor.fromAHSL(1, (seed.hashCode.abs() % 360).toDouble(), 0.22, dark ? 0.30 : 0.74).toColor();
    final box = DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: Center(child: Icon(Icons.music_note_rounded, color: Colors.white.withValues(alpha: 0.55), size: (size ?? 64) * 0.4)),
    );
    return size == null ? AspectRatio(aspectRatio: 1, child: box) : SizedBox.square(dimension: size, child: box);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String actionLabel;
  const SectionHeader(this.title, {super.key, this.onAction, this.actionLabel = 'Ver tudo'});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s24, Tk.s8, Tk.s8),
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          if (onAction != null) TextButton(onPressed: onAction, child: Text(actionLabel)),
        ]),
      );
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  const AppIconButton({super.key, required this.icon, required this.tooltip, this.onPressed, this.size = 24});
  @override
  Widget build(BuildContext context) => IconButton(icon: Icon(icon, size: size), tooltip: tooltip, onPressed: onPressed);
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  const AppButton(this.label, {super.key, this.onPressed, this.outlined = false});
  @override
  Widget build(BuildContext context) => outlined
      ? OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd))),
          child: Text(label))
      : FilledButton(onPressed: onPressed, child: Text(label));
}

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  const AppSearchBar({super.key, this.hint = 'Buscar', this.onChanged, this.onTap, this.autofocus = false});
  @override
  Widget build(BuildContext context) => TextField(
        autofocus: autofocus, onChanged: onChanged, onTap: onTap, readOnly: onTap != null,
        decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search_rounded, size: 22)),
      );
}

class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> queue;
  const SongTile({super.key, required this.song, required this.queue});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final current = ref.watch(playerProvider.select((p) => p.song?.id == song.id));
    return ListTile(
      onTap: () => ref.read(playerProvider.notifier).play(song, queue),
      contentPadding: const EdgeInsets.symmetric(horizontal: Tk.s16),
      leading: Cover(seed: song.album, size: 48),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: current ? cs.primary : null, fontWeight: FontWeight.w500)),
      subtitle: Text('${song.artist} · ${fmtDuration(song.duration)}', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(song.downloaded ? Icons.download_done_rounded : Icons.cloud_outlined, size: 18, color: cs.onSurfaceVariant),
        IconButton(icon: const Icon(Icons.more_vert_rounded, size: 20), tooltip: 'Opções', onPressed: () => showSongOptions(context, ref, song)),
      ]),
    );
  }
}

class SongList extends StatelessWidget {
  final List<Song> songs;
  const SongList(this.songs, {super.key});
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.only(bottom: Tk.s16),
        itemCount: songs.length,
        itemBuilder: (_, i) => SongTile(song: songs[i], queue: songs),
      );
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onMore;
  const PlaylistCard({super.key, required this.playlist, required this.onTap, required this.onMore});
  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: Tk.s16, right: Tk.s4),
        leading: Cover(seed: playlist.id, size: 56, radius: Tk.rSm),
        title: Text(playlist.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Text('${playlist.songIds.length} músicas · ${fmtAgo(playlist.updatedAt)}', style: Theme.of(context).textTheme.bodySmall),
        trailing: IconButton(icon: const Icon(Icons.more_vert_rounded, size: 20), tooltip: 'Opções', onPressed: onMore),
      );
}

/// Square tile for horizontal shelves (albums / recent playlists).
class AlbumCard extends StatelessWidget {
  final String title, subtitle, seed;
  final VoidCallback? onTap;
  const AlbumCard({super.key, required this.title, required this.subtitle, required this.seed, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(Tk.rMd),
        child: SizedBox(width: 132, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Cover(seed: seed, size: 132, radius: Tk.rMd),
          const SizedBox(height: Tk.s8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
        ])),
      );
}

class ArtistTile extends StatelessWidget {
  final String name;
  final int songCount;
  const ArtistTile({super.key, required this.name, required this.songCount});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Tk.s16),
        leading: ClipOval(child: Cover(seed: name, size: 48, radius: 24)),
        title: Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Text('$songCount músicas', style: Theme.of(context).textTheme.bodySmall),
      );
}

class DownloadItem extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onRetry, onRemove;
  const DownloadItem({super.key, required this.task, this.onRetry, this.onRemove});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget detail;
    switch (task.status) {
      case DownloadStatus.downloading:
        detail = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Tk.s8),
          TweenAnimationBuilder<double>(
            tween: Tween(end: task.progress), duration: const Duration(milliseconds: 400),
            builder: (_, v, __) => ProgressIndicatorBar(value: v)),
          const SizedBox(height: Tk.s4),
          Text('${(task.progress * 100).round()}%  ·  ${fmtMb(task.received)} / ${fmtMb(task.total)}', style: t.bodySmall),
        ]);
      case DownloadStatus.queued:
        detail = Text('Aguardando…', style: t.bodySmall);
      case DownloadStatus.completed:
        detail = Text('Baixada · ${fmtMb(task.total)}', style: t.bodySmall);
      case DownloadStatus.failed:
        detail = Text('Falha no download. Toque para tentar de novo.', style: t.bodySmall?.copyWith(color: cs.error));
    }
    return ListTile(
      onTap: task.status == DownloadStatus.failed ? onRetry : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: Tk.s16, vertical: Tk.s4),
      leading: Cover(seed: task.song.album, size: 48),
      title: Text(task.song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.song.artist, style: t.bodySmall), detail,
      ]),
      trailing: task.status == DownloadStatus.completed ? null : IconButton(
          icon: Icon(task.status == DownloadStatus.failed ? Icons.refresh_rounded : Icons.close_rounded, size: 20),
          tooltip: task.status == DownloadStatus.failed ? 'Tentar de novo' : 'Cancelar',
          onPressed: task.status == DownloadStatus.failed ? onRetry : onRemove),
    );
  }
}

class ProgressIndicatorBar extends StatelessWidget {
  final double value;
  const ProgressIndicatorBar({super.key, required this.value});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: value));
}

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    final s = p.song;
    final cs = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
      child: s == null ? const SizedBox(width: double.infinity) : Material(
        color: cs.surfaceContainerHighest,
        child: InkWell(
          onTap: () => context.push('/player'),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 1, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(Tk.s12, Tk.s8, Tk.s4, Tk.s8),
              child: Row(children: [
                Hero(tag: 'cover', child: Cover(seed: s.album, size: 44)),
                const SizedBox(width: Tk.s12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ])),
                IconButton(icon: Icon(p.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
                    tooltip: p.playing ? 'Pausar' : 'Tocar', onPressed: ref.read(playerProvider.notifier).toggle),
              ]),
            ),
            LinearProgressIndicator(value: p.position.inMilliseconds / s.duration.inMilliseconds, minHeight: 2),
          ]),
        ),
      ),
    );
  }
}

// ---- States ----
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(padding: const EdgeInsets.all(Tk.s32), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: Tk.s16),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: Tk.s8),
          Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14), textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: Tk.s24),
            SizedBox(width: 220, child: AppButton(actionLabel!, onPressed: onAction)),
          ],
        ])),
      );
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.error_outline_rounded, title: 'Algo deu errado', message: message, actionLabel: 'Tentar novamente', onAction: onRetry);
}

/// Skeleton rows; static (no shimmer) to stay quiet.
class LoadingState extends StatelessWidget {
  final int rows;
  const LoadingState({super.key, this.rows = 8});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).dividerColor;
    Widget bar(double w, double h) => Container(width: w, height: h, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)));
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), itemCount: rows,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tk.s16, vertical: Tk.s8),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(Tk.rSm))),
          const SizedBox(width: Tk.s12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bar(160, 12), const SizedBox(height: 8), bar(100, 10)]),
        ]),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(Tk.s16, Tk.s8, Tk.s16, 0),
        padding: const EdgeInsets.all(Tk.s12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Tk.rMd), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.cloud_off_rounded, size: 20),
          const SizedBox(width: Tk.s12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Você está offline', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Sua biblioteca e suas músicas baixadas continuam disponíveis normalmente. Importações e novos downloads precisam de conexão.',
                style: Theme.of(context).textTheme.bodySmall),
          ])),
        ]),
      );
}

// ---- Dialogs / sheets ----
Future<String?> showNameDialog(BuildContext context, {required String title, String initial = '', required String confirm}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Nome da playlist'), onSubmitted: (v) => Navigator.pop(context, v.trim())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: Text(confirm)),
      ],
    ),
  ).then((v) => (v == null || v.isEmpty) ? null : v);
}

Future<bool> confirmDialog(BuildContext context, {required String title, required String message, required String confirm}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(title: Text(title), content: Text(message), actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(confirm)),
      ]),
    ) ?? false;

void showSongOptions(BuildContext context, WidgetRef ref, Song song) {
  showModalBottomSheet(
    context: context,
    builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Cover(seed: song.album, size: 44), title: Text(song.title), subtitle: Text(song.artist)),
      const Divider(),
      ListTile(leading: const Icon(Icons.playlist_add_rounded), title: const Text('Adicionar à playlist'),
          onTap: () { Navigator.pop(sheet); showAddToPlaylist(context, ref, song); }),
      if (!song.downloaded)
        ListTile(leading: const Icon(Icons.download_rounded), title: const Text('Baixar'),
            onTap: () { ref.read(downloadsProvider.notifier).enqueue(song); Navigator.pop(sheet); }),
    ])),
  );
}

void showAddToPlaylist(BuildContext context, WidgetRef ref, Song song) {
  showModalBottomSheet(
    context: context,
    builder: (sheet) => Consumer(builder: (_, ref, __) {
      final lists = ref.watch(playlistsProvider);
      return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.all(Tk.s16), child: Align(alignment: Alignment.centerLeft,
            child: Text('Adicionar à playlist', style: Theme.of(context).textTheme.titleMedium))),
        ListTile(leading: const Icon(Icons.add_rounded), title: const Text('Nova playlist'), onTap: () async {
          final name = await showNameDialog(context, title: 'Nova playlist', confirm: 'Criar');
          if (name != null) {
            ref.read(playlistsProvider.notifier).create(name);
            ref.read(playlistsProvider.notifier).addSong(ref.read(playlistsProvider).first.id, song.id);
          }
          if (sheet.mounted) Navigator.pop(sheet);
        }),
        for (final p in lists)
          ListTile(leading: Cover(seed: p.id, size: 40), title: Text(p.name), subtitle: Text('${p.songIds.length} músicas'),
              onTap: () { ref.read(playlistsProvider.notifier).addSong(p.id, song.id); Navigator.pop(sheet); }),
      ]));
    }),
  );
}
