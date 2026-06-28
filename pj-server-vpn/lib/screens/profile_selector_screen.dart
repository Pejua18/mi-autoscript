import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_provider.dart';

class ProfileSelectorScreen extends StatelessWidget {
  const ProfileSelectorScreen({super.key});
  static final List<VpnProfile> _profiles = [
    VpnProfile(name: 'PERSONAL 1 - WS + SSH', host: 'www.pejotaa.site', wsPort: 2080, sshPort: 111, type: 'ws+ssh'),
    VpnProfile(name: 'PERSONAL 2 - SSH Directo', host: 'www.pejotaa.site', wsPort: 2080, sshPort: 111, type: 'ssh'),
    VpnProfile(name: 'PERSONAL 3 - SSH Puerto 109', host: 'www.pejotaa.site', wsPort: 2080, sshPort: 109, type: 'ssh'),
  ];
  @override Widget build(BuildContext context) {
    final vpn = context.read<VpnProvider>();
    return Scaffold(backgroundColor: const Color(0xFF060E1E),
      appBar: AppBar(backgroundColor: const Color(0xFF0D1F3C), foregroundColor: Colors.white,
        title: const Text('Seleccionar perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), elevation: 0),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _profiles.length,
        itemBuilder: (context, i) {
          final profile = _profiles[i];
          final isActive = vpn.activeProfile.name == profile.name;
          return GestureDetector(onTap: () { vpn.setProfile(profile); Navigator.pop(context); },
            child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isActive ? const Color(0xFF1A4A8A).withOpacity(0.5) : const Color(0xFF0D1F3C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isActive ? const Color(0xFF00C8FF) : Colors.white.withOpacity(0.08), width: isActive ? 1.5 : 1)),
              child: Row(children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: profile.type == 'ws+ssh' ? [const Color(0xFF00C8FF), const Color(0xFF0066CC)] : [const Color(0xFFBB57FF), const Color(0xFF6600CC)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
                  child: Icon(profile.type == 'ws+ssh' ? Icons.lan_rounded : Icons.terminal_rounded, color: Colors.white, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('${profile.host} : ${profile.type == 'websocket' ? profile.wsPort : profile.sshPort}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ])),
                if (isActive) const Icon(Icons.check_circle, color: Color(0xFF00C8FF), size: 20),
              ])));
        }));
  }
}
