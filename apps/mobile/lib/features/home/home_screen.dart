import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);
    final playlists = ref.watch(playlistsProvider);
    final downloads = ref
        .watch(downloadsProvider)
        .where((d) => d.status == DownloadStatus.downloading || d.status == DownloadStatus.queued)
        .toList();
    final offline = ref.watch(offlineProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            Text(_greeting),
          ],
        ),
        actions: [
          const NowPlayingAction(),
          AppIconButton(icon: Icons.search_rounded, tooltip: 'Buscar', onPressed: () => context.push('/search')),
          AppIconButton(icon: Icons.settings_outlined, tooltip: 'Configurações', onPressed: () => context.push('/settings')),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: Tk.s32), children: [
        if (offline) const OfflineBanner(),
        songs.when(
          loading: () => const SizedBox(height: 250, child: LoadingState(rows: 3)),
          error: (e, _) =>
              ErrorState(message: 'Não foi possível carregar sua biblioteca.', onRetry: () => ref.invalidate(songsProvider)),
          data: (all) {
            final recent = all.where((s) => s.downloaded).take(6).toList();
            if (recent.isEmpty) return const SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader('Tocadas recentemente'),
              SizedBox(
                height: 195,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Tk.s16),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: Tk.s16),
                  itemBuilder: (_, i) => AlbumCard(
                    width: 140,
                    title: recent[i].title,
                    subtitle: recent[i].artist,
                    seed: recent[i].album,
                    onTap: () => ref.read(playerProvider.notifier).play(recent[i], recent),
                  ),
                ),
              ),
            ]);
          },
        ),
        if (downloads.isNotEmpty) ...[
          SectionHeader('Baixando agora', onAction: () => context.go('/downloads'), actionLabel: 'Abrir'),
          for (final d in downloads.take(2)) DownloadItem(task: d, onRemove: () => ref.read(downloadsProvider.notifier).remove(d.id)),
        ],
        SectionHeader('Playlists', onAction: () => context.go('/playlists')),
        SizedBox(
          height: 195,
          child: playlists.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Tk.s16),
                  itemCount: playlists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: Tk.s16),
                  itemBuilder: (_, i) => AlbumCard(
                    width: 140,
                    title: playlists[i].name,
                    subtitle: '${playlists[i].songIds.length} músicas',
                    seed: playlists[i].id,
                    onTap: () => context.push('/playlists/${playlists[i].id}'),
                  ),
                ),
        ),
        const SizedBox(height: Tk.s12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Tk.s16),
          child: Material(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Tk.rMd),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Tk.s16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.14),
                ),
                child: Icon(Icons.library_music_rounded, color: cs.primary, size: 22),
              ),
              title: const Text('Ir para a biblioteca'),
              subtitle: const Text('Explore todas as músicas, álbuns e artistas'),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              onTap: () => context.go('/library'),
            ),
          ),
        ),
      ]),
    );
  }
}
