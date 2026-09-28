import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Widget _group(BuildContext c, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(Tk.s16, Tk.s24, Tk.s16, Tk.s4),
      child: Text(title, style: Theme.of(c).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final quality = ref.watch(audioQualityProvider);
    final offline = ref.watch(offlineProvider);
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
        _group(context, 'Áudio e armazenamento'),
        ListTile(leading: const Icon(Icons.graphic_eq_rounded), title: const Text('Qualidade de áudio'), subtitle: Text(quality),
            onTap: () => showModalBottomSheet(context: context, builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final q in const ['Baixa', 'Média', 'Alta'])
                ListTile(title: Text(q), trailing: q == quality ? Icon(Icons.check_rounded, color: cs.primary) : null,
                    onTap: () { ref.read(audioQualityProvider.notifier).set(q); Navigator.pop(sheet); }),
            ])))),
        ListTile(leading: const Icon(Icons.storage_outlined), title: const Text('Armazenamento'),
            subtitle: const Text('1,2 GB usados por músicas baixadas')),
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
}
