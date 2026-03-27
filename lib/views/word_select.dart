import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/config/env_variables.dart';

class WordSelectScreen extends StatefulWidget {
  final List<dynamic> word;
  const WordSelectScreen({super.key, required this.word});

  @override
  State<StatefulWidget> createState() => _WordSelectScreenState();
}

class _WordSelectScreenState extends State<WordSelectScreen> {
  static const Color primaryColor = Color(0xFFf58b2a);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> wordsList = widget.word;

    return Scaffold(
      appBar: const Topbar(title: "Aprende LSP"),
      body: AppBackground(
        child: SafeArea(
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: wordsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final wordData = wordsList[index] as Map<String, dynamic>;
                final palabra = wordData['palabra'] ?? 'Sin nombre';
                final ruta = wordData['ruta_local'] ?? '';
                final enlace = ruta.isNotEmpty ? '${EnvVariables.baseUrl}$ruta' : '';

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(
                      child: _BounceTile(
                        palabra: palabra,
                        enlace: enlace,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/doit',
                            arguments: {'palabra': palabra, 'enlace': enlace},
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Tile con efecto rebote al presionar
class _BounceTile extends StatefulWidget {
  final String palabra;
  final String enlace;
  final VoidCallback onTap;
  static const Color primaryColor = Color(0xFFf58b2a);

  const _BounceTile({
    required this.palabra,
    required this.enlace,
    required this.onTap,
  });

  @override
  State<_BounceTile> createState() => _BounceTileState();
}

class _BounceTileState extends State<_BounceTile>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutBack,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _BounceTile.primaryColor, width: 1.5),
        ),
        elevation: 2,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              widget.palabra,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: _BounceTile.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
