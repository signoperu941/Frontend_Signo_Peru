import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget de firma digital: captura trazos con el dedo y los exporta como
/// base64 PNG cuando el trazo termina.
class SignaturePad extends StatefulWidget {
  final void Function(String base64) onChanged;

  const SignaturePad({super.key, required this.onChanged});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];

  static const double _padHeight = 120.0;
  static const Color _primary = Color(0xFFf58b2a);

  bool get isEmpty => _strokes.isEmpty;

  void clear() {
    setState(() {
      _strokes.clear();
      _current = [];
    });
    widget.onChanged('');
  }

  Future<String> _toBase64(double width) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, _padHeight),
      Paint()..color = Colors.white,
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(width.toInt(), _padHeight.toInt());
    final bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return 'data:image/png;base64,${base64Encode(bytes!.buffer.asUint8List())}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: width,
              height: _padHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.4)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  // Línea guía
                  Positioned(
                    bottom: 28,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 1,
                      color: _primary.withOpacity(0.2),
                    ),
                  ),
                  // Área de dibujo
                  GestureDetector(
                    onPanStart: (d) {
                      setState(() => _current = [d.localPosition]);
                    },
                    onPanUpdate: (d) {
                      setState(() => _current.add(d.localPosition));
                    },
                    onPanEnd: (_) async {
                      if (_current.isNotEmpty) {
                        setState(() {
                          _strokes.add(List.from(_current));
                          _current = [];
                        });
                        final b64 = await _toBase64(width);
                        widget.onChanged(b64);
                      }
                    },
                    child: CustomPaint(
                      painter: _SignaturePainter(_strokes, _current),
                      size: Size(width, _padHeight),
                    ),
                  ),
                  // Placeholder
                  if (isEmpty && _current.isEmpty)
                    Positioned(
                      bottom: 32,
                      left: 12,
                      child: Text(
                        'Dibuja tu firma aquí',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: clear,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;

  const _SignaturePainter(this.strokes, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void draw(List<Offset> stroke) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawCircle(stroke.first, 1.5,
              paint..style = PaintingStyle.fill);
          paint.style = PaintingStyle.stroke;
        }
        return;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final s in strokes) { draw(s); }
    if (current.isNotEmpty) { draw(current); }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) => true;
}
