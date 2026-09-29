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
      AppIconButton(icon: Icons.skip_previous_rounded, size: 38, tooltip: 'Anterior', onPressed: () => n.skip(-1)),
      const SizedBox(width: Tk.s24),
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: Tk.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.42),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IconButton(
          iconSize: 38,
          color: Colors.white,
          tooltip: p.playing ? 'Pausar' : 'Tocar',
          onPressed: n.toggle,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(p.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, key: ValueKey(p.playing)),
          ),
        ),
      ),
      const SizedBox(width: Tk.s24),
      AppIconButton(icon: Icons.skip_next_rounded, size: 38, tooltip: 'Próxima', onPressed: () => n.skip(1)),
    ]);

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.headlineSmall),
          const SizedBox(height: 4),
          Text(s.artist, style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
        ])),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: AppIconButton(
              icon: Icons.playlist_add_rounded,
              tooltip: 'Adicionar à playlist',
              onPressed: () => showAddToPlaylist(context, ref, s)),
        ),
      ]),
      const SizedBox(height: Tk.s24),
      Slider(
        value: p.position.inSeconds.toDouble().clamp(0, s.duration.inSeconds.toDouble()),
        max: s.duration.inSeconds.toDouble(),
        onChanged: (v) => n.seek(Duration(seconds: v.round())),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tk.s8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtDuration(p.position), style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            Text(fmtDuration(s.duration), style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      const SizedBox(height: Tk.s24),
      controls,
      const SizedBox(height: Tk.s24),
      Row(children: [
        Icon(Icons.volume_down_rounded, size: 20, color: cs.onSurfaceVariant),
        Expanded(child: Slider(value: p.volume, onChanged: n.setVolume)),
        Icon(Icons.volume_up_rounded, size: 20, color: cs.onSurfaceVariant),
      ]),
    ]);

    Widget albumArtwork() => Stack(
          alignment: Alignment.center,
          children: [
            // Ambient colorful glow
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: cs.secondary.withValues(alpha: 0.2),
                    blurRadius: 80,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
              child: Hero(tag: 'cover', child: Cover(seed: s.album, radius: Tk.rLg)),
            ),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
            icon: Icons.keyboard_arrow_down_rounded, size: 30, tooltip: 'Voltar', onPressed: () => context.pop()),
        title: Text('Tocando agora', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [AppIconButton(icon: Icons.more_vert_rounded, tooltip: 'Opções', onPressed: () => showSongOptions(context, ref, s))],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (_, o) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tk.s24, vertical: Tk.s16),
            child: o == Orientation.portrait
                ? Column(children: [
                    Expanded(child: Center(child: albumArtwork())),
                    const SizedBox(height: Tk.s16),
                    info,
                  ])
                : Row(children: [
                    Expanded(child: Center(child: albumArtwork())),
                    const SizedBox(width: Tk.s32),
                    Expanded(child: SingleChildScrollView(child: info)),
                  ]),
          ),
        ),
      ),
    );
  }
}
