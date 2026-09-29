import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Widget _group(BuildContext c, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s24, Tk.s16, Tk.s4),
      child: Text(title, style: Theme.of(c).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.1)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final quality = ref.watch(audioQualityProvider);
    final offline = ref.watch(offlineProvider);
    final miniPlayerOn = ref.watch(miniPlayerVisibleProvider);
    final storagePath = ref.watch(storageLocationProvider);
    final cs = Theme.of(context).colorScheme;

    Widget soon(IconData i, String t) => ListTile(enabled: false, leading: Icon(i), title: Text(t), trailing: const Text('Em breve'));

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(children: [
        _group(context, 'Aparência'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Tk.s16, vertical: Tk.s8),
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Escuro'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto_outlined)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
          ),
        ),

        _group(context, 'Player'),
        SwitchListTile(
          secondary: const Icon(Icons.smart_button_outlined),
          title: const Text('Mostrar mini player'),
          subtitle: const Text('Barra com a música atual acima da navegação'),
          value: miniPlayerOn,
          onChanged: ref.read(miniPlayerVisibleProvider.notifier).set,
        ),

        _group(context, 'Áudio e armazenamento'),
        ListTile(leading: const Icon(Icons.graphic_eq_rounded), title: const Text('Qualidade de áudio'), subtitle: Text(quality),
            onTap: () => showModalBottomSheet(context: context, builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final q in const ['Baixa', 'Média', 'Alta'])
                ListTile(title: Text(q), trailing: q == quality ? Icon(Icons.check_rounded, color: cs.primary) : null,
                    onTap: () { ref.read(audioQualityProvider.notifier).set(q); Navigator.pop(sheet); }),
            ])))),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: const Text('Local de armazenamento'),
          subtitle: Text(storagePath, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showStorageSheet(context, ref),
        ),
        const ListTile(leading: Icon(Icons.storage_outlined), title: Text('Espaço usado'),
            subtitle: Text('1,2 GB usados por músicas baixadas')),
        ListTile(leading: const Icon(Icons.download_outlined), title: const Text('Gerenciar downloads'),
            subtitle: const Text('Limpar concluídos e falhas'),
            onTap: () {
              final n = ref.read(downloadsProvider.notifier);
              for (final d in ref.read(downloadsProvider)) { if (d.status.name == 'completed' || d.status.name == 'failed') n.remove(d.id); }
            }),

        _group(context, 'Conta e sincronização'),
        soon(Icons.person_outline_rounded, 'Conta'),
        soon(Icons.sync_rounded, 'Sincronização'),
        soon(Icons.dns_outlined, 'Servidor (API)'),

        _group(context, 'Desenvolvimento'),
        SwitchListTile(secondary: const Icon(Icons.cloud_off_outlined), title: const Text('Simular modo offline'),
            value: offline, onChanged: ref.read(offlineProvider.notifier).set),

        _group(context, 'Sobre'),
        const ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('SoundDesk Mobile'), subtitle: Text('Versão 0.1.0')),
      ]),
    );
  }

  void _showStorageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Consumer(builder: (_, ref, __) {
        final current = ref.watch(storageLocationProvider);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
          child: SafeArea(child: _StorageEditor(current: current)),
        );
      }),
    );
  }
}

class _StorageEditor extends ConsumerStatefulWidget {
  final String current;
  const _StorageEditor({required this.current});
  @override
  ConsumerState<_StorageEditor> createState() => _StorageEditorState();
}

class _StorageEditorState extends ConsumerState<_StorageEditor> {
  late final _c = TextEditingController(text: widget.current);
  String? _error;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(Tk.s16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Local de armazenamento', style: t.titleMedium),
        const SizedBox(height: Tk.s4),
        Text('As pastas Music, Albums, Playlists, Covers e Downloads ficam dentro deste diretório.', style: t.bodySmall),
        const SizedBox(height: Tk.s16),
        TextField(
          controller: _c,
          decoration: InputDecoration(hintText: '/storage/...', errorText: _error),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: Tk.s12),
        // On-device UI has no folder browser here; the real implementation swaps
        // this row for file_picker's directory picker (Android SAF / iOS docs).
        OutlinedButton.icon(
          onPressed: () => setState(() => _c.text = '/storage/emulated/0/Documents/SoundDesk'),
          icon: const Icon(Icons.drive_folder_upload_outlined, size: 18),
          label: const Text('Alterar diretório'),
        ),
        const SizedBox(height: Tk.s16),
        Wrap(spacing: Tk.s8, runSpacing: Tk.s4, children: [for (final f in storageSubfolders) Chip(label: Text(f), visualDensity: VisualDensity.compact)]),
        const SizedBox(height: Tk.s24),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
          const SizedBox(width: Tk.s12),
          Expanded(child: FilledButton(
            onPressed: () {
              final err = ref.read(storageLocationProvider.notifier).trySet(_c.text);
              if (err != null) { setState(() => _error = err); return; }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          )),
        ]),
      ]),
    );
  }
}
