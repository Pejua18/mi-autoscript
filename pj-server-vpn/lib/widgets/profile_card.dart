import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_provider.dart';
import '../screens/profile_selector_screen.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});
  @override Widget build(BuildContext context) {
    return Consumer<VpnProvider>(builder: (context, vpn, _) {
      final isWs = vpn.activeProfile.type == 'ws+ssh';
      return GestureDetector(onTap: vpn.isConnected || vpn.isConnecting ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: vpn, child: const ProfileSelectorScreen()))),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(gradient: LinearGradient(colors: isWs ? [const Color(0xFF00C8FF), const Color(0xFF0066CC)] : [const Color(0xFFBB57FF), const Color(0xFF6600CC)],
                begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(10)),
              child: Icon(isWs ? Icons.lan_rounded : Icons.terminal_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vpn.activeProfile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text('${isWs ? "WS+SSH" : "SSH"} | ${vpn.activeProfile.host}', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11, letterSpacing: 0.5)),
            ])),
            if (!vpn.isConnected && !vpn.isConnecting) const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ])));
    });
  }
}
