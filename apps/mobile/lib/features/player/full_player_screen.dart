import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/components.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    final n = ref.read(playerProvider.notifier);
    final s = p.song;
    if (s == null) return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final controls = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppIconButton(icon: Icons.skip_previous_rounded, size: 36, tooltip: 'Anterior', onPressed: () => n.skip(-1)),
      const SizedBox(width: Tk.s16),
      IconButton.filled(
        iconSize: 36, tooltip: p.playing ? 'Pausar' : 'Tocar', onPressed: n.toggle,
        style: IconButton.styleFrom(fixedSize: const Size(68, 68), backgroundColor: cs.onSurface, foregroundColor: cs.surface),
        icon: AnimatedSwitcher(duration: const Duration(milliseconds: 150),
            child: Icon(p.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, key: ValueKey(p.playing))),
      ),
      const SizedBox(width: Tk.s16),
      AppIconButton(icon: Icons.skip_next_rounded, size: 36, tooltip: 'Próxima', onPressed: () => n.skip(1)),
    ]);

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleLarge),
          const SizedBox(height: 2),
          Text(s.artist, style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
        ])),
        AppIconButton(icon: Icons.playlist_add_rounded, tooltip: 'Adicionar à playlist', onPressed: () => showAddToPlaylist(context, ref, s)),
      ]),
      const SizedBox(height: Tk.s16),
      Slider(value: p.position.inSeconds.toDouble().clamp(0, s.duration.inSeconds.toDouble()),
          max: s.duration.inSeconds.toDouble(), onChanged: (v) => n.seek(Duration(seconds: v.round()))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: Tk.s16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(fmtDuration(p.position), style: t.bodySmall), Text(fmtDuration(s.duration), style: t.bodySmall)])),
      const SizedBox(height: Tk.s16),
      controls,
      const SizedBox(height: Tk.s16),
      Row(children: [
        Icon(Icons.volume_down_rounded, size: 20, color: cs.onSurfaceVariant),
        Expanded(child: Slider(value: p.volume, onChanged: n.setVolume)),
        Icon(Icons.volume_up_rounded, size: 20, color: cs.onSurfaceVariant),
      ]),
    ]);

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(icon: Icons.keyboard_arrow_down_rounded, size: 30, tooltip: 'Voltar', onPressed: () => context.pop()),
        title: Text('Tocando agora', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [AppIconButton(icon: Icons.more_vert_rounded, tooltip: 'Opções', onPressed: () => showSongOptions(context, ref, s))],
      ),
      body: SafeArea(
        child: OrientationBuilder(builder: (_, o) => Padding(
          padding: const EdgeInsets.all(Tk.s24),
          child: o == Orientation.portrait
              ? Column(children: [
                  Expanded(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
                      child: Hero(tag: 'cover', child: Cover(seed: s.album, radius: Tk.rLg))))),
                  const SizedBox(height: Tk.s24),
                  info,
                ])
              : Row(children: [
                  Expanded(child: Center(child: Hero(tag: 'cover', child: Cover(seed: s.album, radius: Tk.rLg)))),
                  const SizedBox(width: Tk.s32),
                  Expanded(child: SingleChildScrollView(child: info)),
                ]),
        )),
      ),
    );
  }
}
