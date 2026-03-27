import 'package:flutter/material.dart';
import 'dart:math';

class AppBackground extends StatefulWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // Crear letras flotantes
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_particles, _controller.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late String letter;    // Letra del alfabeto
  late double delay;     // Delay individual
  late double rotation;  // Rotación suave

  Particle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble() * 1.5; // Distribución más amplia en Y
    size = random.nextDouble() * 30 + 20; // Tamaño de fuente más grande
    speed = random.nextDouble() * 0.3 + 0.08; // Velocidad más lenta para mejor dispersión
    color = const Color(0xFFf58b2a).withOpacity(random.nextDouble() * 0.25 + 0.15);
    delay = random.nextDouble() * 4; // Delay más amplio para mayor dispersión
    rotation = random.nextDouble() * 0.3 - 0.15; // Rotación sutil
    
    // Seleccionar letra aleatoria del alfabeto español
    const letters = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ];
    letter = letters[random.nextInt(letters.length)];
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Aplicar delay individual para movimiento natural
      final adjustedTime = (animationValue + particle.delay) % 1.0;
      final currentY = ((particle.y + adjustedTime * particle.speed) % 1.8) - 0.4;
      final screenY = currentY * size.height;
      final screenX = particle.x * size.width;
      
      // Movimiento horizontal sutil (deriva)
      final driftX = sin(adjustedTime * pi * 2) * 20;
      final finalX = screenX + driftX;
      
      // Solo dibujar si está visible
      if (screenY >= -particle.size && screenY <= size.height + particle.size) {
        canvas.save();
        canvas.translate(finalX, screenY);
        canvas.rotate(particle.rotation + adjustedTime * 0.2); // Rotación muy sutil
        
        // Configurar estilo de texto
        final textPainter = TextPainter(
          text: TextSpan(
            text: particle.letter,
            style: TextStyle(
              fontSize: particle.size,
              color: particle.color,
              fontWeight: FontWeight.w300, // Fuente ligera
              fontFamily: 'Arial', // Fuente simple y legible
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        // Centrar la letra
        final offset = Offset(
          -textPainter.width / 2,
          -textPainter.height / 2,
        );
        
        textPainter.paint(canvas, offset);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}