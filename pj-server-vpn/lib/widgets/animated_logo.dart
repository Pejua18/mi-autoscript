import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});
  @override State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  late Animation<double> _glow;

  @override void initState() { super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _ctrl, builder: (context, _) {
      return Transform.scale(scale: _pulse.value, child: Container(width: 200, height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF00C8FF).withOpacity(0.15 * _glow.value), blurRadius: 40, spreadRadius: 10)]),
        child: CustomPaint(painter: _LogoPainter(_glow.value),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFE8F4FF), Color(0xFF00C8FF), Color(0xFFFFFFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds),
              child: const Text('PJ SERVER', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3))),
            const SizedBox(height: 2),
            Text('VPN PREMIUM', style: TextStyle(fontSize: 11, color: const Color(0xFF00C8FF).withOpacity(0.8), letterSpacing: 4, fontWeight: FontWeight.w400)),
          ])))));
    });
  }
}

class _LogoPainter extends CustomPainter {
  final double glowIntensity;
  _LogoPainter(this.glowIntensity);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0xFF00C8FF).withOpacity(0.3 * glowIntensity);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2 + 10), width: size.width * 0.85, height: size.height * 0.35), paint);
  }
  @override bool shouldRepaint(_LogoPainter old) => old.glowIntensity != glowIntensity;
}
