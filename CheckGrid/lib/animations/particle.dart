import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double lifespan;
  Color color;
  final double _initialLifespan;

  static const double _gravity = 0.1; // Gravitationseffekt

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifespan,
    required this.color,
  }) : _initialLifespan = lifespan;

  void update() {
    position += velocity;
    velocity = Offset(velocity.dx, velocity.dy + _gravity); // Lägg till gravitation
    lifespan -= 1 / 60;

    // Små storleksvariationer (valfritt)
    final sizeFactor = 1.0 + (sin(lifespan * pi * 2) * 0.1);
    size = (size * sizeFactor).clamp(0.5, 2.0);

    // Fadea ut över tiden
    color = color.withOpacity((lifespan / _initialLifespan).clamp(0.0, 1.0));
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.lifespan <= 0) continue;

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
