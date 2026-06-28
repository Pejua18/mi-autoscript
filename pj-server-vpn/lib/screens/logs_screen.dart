import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/vpn_provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});
  @override Widget build(BuildContext context) {
    return Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.3), radius: 1.2, colors: [Color(0xFF0D2550), Color(0xFF060E1E)])),
      child: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF1A4A8A), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.terminal_rounded, color: Color(0xFF00C8FF), size: 20)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Registros', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Ver y copiar logs de conexion', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ])),
          Consumer<VpnProvider>(builder: (context, vpn, _) => Row(children: [
            _actionBtn(label: 'Limpiar', onTap: vpn.clearLogs),
            const SizedBox(width: 8),
            _actionBtn(label: 'Copiar', primary: true, onTap: () {
              Clipboard.setData(ClipboardData(text: vpn.logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs copiados al portapapeles'), duration: Duration(seconds: 2)));
            }),
          ])),
        ])),
        const SizedBox(height: 16),
        Expanded(child: Consumer<VpnProvider>(builder: (context, vpn, _) {
          if (vpn.logs.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.notes_rounded, color: Colors.white12, size: 48), const SizedBox(height: 12),
            const Text('Sin registros aun', style: TextStyle(color: Colors.white24, fontSize: 14))]));
          return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration: BoxDecoration(color: const Color(0xFF050D1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: ListView.builder(padding: const EdgeInsets.all(14), reverse: true,
              itemCount: vpn.logs.length,
              itemBuilder: (context, index) {
                final log = vpn.logs[index];
                final lineNum = vpn.logs.length - index;
                return Padding(padding: const EdgeInsets.only(bottom: 6), child: RichText(text: TextSpan(children: [
                  TextSpan(text: '[$lineNum] ', style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF3A7BD5), fontWeight: FontWeight.bold)),
                  TextSpan(text: log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF9ECFFF), height: 1.4)),
                ])));
              })));
        })),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('REFRESCANDO LOGS EN TIEMPO REAL...', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.2), letterSpacing: 1.5, fontWeight: FontWeight.w600))),
      ])));
  }
  Widget _actionBtn({required String label, bool primary = false, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: primary ? const Color(0xFF1A4A8A).withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(20), border: Border.all(color: primary ? const Color(0xFF3A7BD5) : Colors.white.withOpacity(0.2))),
      child: Text(label, style: TextStyle(fontSize: 13, color: primary ? const Color(0xFF00C8FF) : Colors.white60, fontWeight: FontWeight.w500))));
  }
}
