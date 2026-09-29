import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

Future<void> playlistOptions(BuildContext context, WidgetRef ref, Playlist p, {bool popAfterDelete = false}) {
  return showModalBottomSheet(
    context: context,
    builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: Text(p.name, style: Theme.of(context).textTheme.titleMedium)),
      ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Renomear'), onTap: () async {
        Navigator.pop(sheet);
        final n = await showNameDialog(context, title: 'Renomear playlist', initial: p.name, confirm: 'Salvar');
        if (n != null) ref.read(playlistsProvider.notifier).rename(p.id, n);
      }),
      ListTile(leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
          title: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)), onTap: () async {
        Navigator.pop(sheet);
        final ok = await confirmDialog(context, title: 'Excluir playlist?', message: 'As músicas continuam na sua biblioteca.', confirm: 'Excluir');
        if (ok) {
          ref.read(playlistsProvider.notifier).delete(p.id);
          if (popAfterDelete && context.mounted) context.pop();
        }
      }),
    ])),
  );
}

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(playlistsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists'), actions: [
        const NowPlayingAction(),
        AppIconButton(icon: Icons.file_download_outlined, tooltip: 'Importar playlist', onPressed: () => context.push('/import')),
      ]),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: Tk.primaryGradient,
          borderRadius: BorderRadius.circular(Tk.rFull),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: () async {
            final n = await showNameDialog(context, title: 'Nova playlist', confirm: 'Criar');
            if (n != null) ref.read(playlistsProvider.notifier).create(n);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nova playlist', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      body: lists.isEmpty
          ? EmptyState(icon: Icons.queue_music_rounded, title: 'Nenhuma playlist ainda',
              message: 'Crie uma playlist para organizar suas músicas.', actionLabel: 'Nova playlist',
              onAction: () async {
                final n = await showNameDialog(context, title: 'Nova playlist', confirm: 'Criar');
                if (n != null) ref.read(playlistsProvider.notifier).create(n);
              })
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88), itemCount: lists.length,
              itemBuilder: (_, i) => PlaylistCard(playlist: lists[i], onTap: () => context.push('/playlists/${lists[i].id}'),
                  onMore: () => playlistOptions(context, ref, lists[i])),
            ),
    );
  }
}
