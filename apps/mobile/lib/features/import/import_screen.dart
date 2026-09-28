import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

const _steps = ['Encontrando playlist…', 'Encontrando músicas…', 'Encontrando correspondências…', 'Preparando downloads…'];

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});
  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _c = TextEditingController();
  int? _step; // null = idle, _steps.length = done
  Timer? _t;

  @override
  void dispose() { _t?.cancel(); _c.dispose(); super.dispose(); }

  void _start() {
    setState(() => _step = 0);
    _t = Timer.periodic(const Duration(milliseconds: 1100), (t) {
      if (_step! >= _steps.length) return t.cancel();
      setState(() => _step = _step! + 1); // TODO: drive from FastAPI import job
    });
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(offlineProvider);
    final valid = _c.text.trim().startsWith('http');
    return Scaffold(
      appBar: AppBar(title: const Text('Importar playlist')),
      body: ListView(padding: const EdgeInsets.all(Tk.s16), children: [
        if (offline) const Padding(padding: EdgeInsets.only(bottom: Tk.s16), child: OfflineBanner()),
        Text('Cole o link da playlist', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Tk.s4),
        Text('Aceita links do Spotify e do YouTube.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Tk.s16),
        TextField(controller: _c, enabled: _step == null, keyboardType: TextInputType.url, onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'https://…')),
        const SizedBox(height: Tk.s16),
        AppButton('Importar', onPressed: (_step == null && valid && !offline) ? _start : null),
        if (_step != null) ...[
          const SizedBox(height: Tk.s32),
          ImportProgress(step: _step!),
        ],
      ]),
    );
  }
}

class ImportProgress extends StatelessWidget {
  final int step;
  const ImportProgress({super.key, required this.step});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      for (var i = 0; i < _steps.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Tk.s8),
          child: Row(children: [
            SizedBox.square(dimension: 20, child: i < step
                ? Icon(Icons.check_circle_rounded, size: 20, color: cs.primary)
                : i == step ? const CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.circle_outlined, size: 20, color: cs.outline)),
            const SizedBox(width: Tk.s12),
            Text(_steps[i], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: i > step ? cs.onSurfaceVariant : null)),
          ]),
        ),
    ]);
  }
}
