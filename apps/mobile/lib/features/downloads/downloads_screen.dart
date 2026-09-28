import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/models.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(downloadsProvider);
    final n = ref.read(downloadsProvider.notifier);
    final offline = ref.watch(offlineProvider);
    Widget group(String title, DownloadStatus s) {
      final items = all.where((d) => d.status == s).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title),
        for (final d in items) DownloadItem(task: d, onRetry: () => n.retry(d.id), onRemove: () => n.remove(d.id)),
      ]);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: all.isEmpty
          ? const EmptyState(icon: Icons.download_outlined, title: 'Nenhum download',
              message: 'As músicas que você baixar aparecem aqui, com o progresso de cada uma.')
          : ListView(children: [
              if (offline) const OfflineBanner(),
              group('Baixando', DownloadStatus.downloading),
              group('Na fila', DownloadStatus.queued),
              group('Com erro', DownloadStatus.failed),
              group('Concluídos', DownloadStatus.completed),
            ]),
    );
  }
}
