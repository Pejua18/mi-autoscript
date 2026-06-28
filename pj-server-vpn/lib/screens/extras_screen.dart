import 'package:flutter/material.dart';
class ExtrasScreen extends StatelessWidget {
  const ExtrasScreen({super.key});
  @override Widget build(BuildContext context) {
    return Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.3), radius: 1.2, colors: [Color(0xFF0D2550), Color(0xFF060E1E)])),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Extras', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _extraTile(icon: Icons.speed_rounded, label: 'Test de velocidad', subtitle: 'Mide la velocidad de tu conexion'),
        _extraTile(icon: Icons.dns_rounded, label: 'Configurar DNS', subtitle: 'Cambia el servidor DNS'),
        _extraTile(icon: Icons.info_outline_rounded, label: 'Sobre la app', subtitle: 'PJ Server VPN v1.0.0'),
      ]))));
  }
  Widget _extraTile({required IconData icon, required String label, required String subtitle}) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0D1F3C).withOpacity(0.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.07))),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00C8FF), size: 22), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      ]));
  }
}
