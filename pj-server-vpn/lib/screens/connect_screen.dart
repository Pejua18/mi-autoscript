import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_provider.dart';
import '../widgets/animated_logo.dart';
import '../widgets/profile_card.dart';
import '../widgets/connect_button.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _hotspot = false;

  @override void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnProvider>(builder: (context, vpn, _) {
      return Container(
        decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.3), radius: 1.2, colors: [Color(0xFF0D2550), Color(0xFF060E1E)])),
        child: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 40),
            if (vpn.isConnected) Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.4))),
              child: Row(children: [const Icon(Icons.signal_cellular_alt, color: Colors.green, size: 14), const SizedBox(width: 4), Text('${vpn.pingMs} ms', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600))]),
            ),
            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white54), onPressed: () {}),
          ])),
          const Spacer(flex: 2),
          const AnimatedLogo(),
          const SizedBox(height: 28),
          Text(vpn.isConnected ? 'Estas conectado' : vpn.isConnecting ? 'Conectando...' : 'Estas desconectado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
              color: vpn.isConnected ? Colors.greenAccent : vpn.isConnecting ? const Color(0xFF00C8FF) : Colors.white70, letterSpacing: 0.3)),
          if (vpn.isConnected) ...[const SizedBox(height: 6), Text('IP: ${vpn.localIp}', style: const TextStyle(fontSize: 13, color: Colors.white38))],
          if (vpn.hasError) ...[const SizedBox(height: 10), Container(
            margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.4))),
            child: Row(children: [const Icon(Icons.error_outline, color: Colors.redAccent, size: 16), const SizedBox(width: 8), Expanded(child: Text(vpn.errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)))])),
          ],
          const Spacer(flex: 2),
          Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0D1F3C).withOpacity(0.85), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(children: [
              const ProfileCard(),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _inputField(controller: _userCtrl, hint: 'Usuario', icon: Icons.person_outline, onChange: vpn.setUsername, enabled: !vpn.isConnected && !vpn.isConnecting)),
                const SizedBox(width: 10),
                Expanded(child: _inputField(controller: _passCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: !_showPass,
                  onChange: vpn.setPassword, enabled: !vpn.isConnected && !vpn.isConnecting,
                  suffix: IconButton(icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 18),
                    onPressed: () => setState(() => _showPass = !_showPass)))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ConnectButton(status: vpn.status, onTap: () { if (vpn.isConnected) vpn.disconnect(); else if (!vpn.isConnecting) vpn.connect(); })),
                const SizedBox(width: 12),
                Column(children: [
                  const Text('Hotspot', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Switch(value: _hotspot, onChanged: (v) => setState(() => _hotspot = v), activeColor: const Color(0xFF00C8FF), inactiveTrackColor: Colors.white.withOpacity(0.12)),
                ]),
              ]),
            ]),
          ),
        ])),
      );
    });
  }

  Widget _inputField({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false, bool enabled = true, Widget? suffix, required Function(String) onChange}) {
    return Container(height: 46,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(children: [
        const SizedBox(width: 10),
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 6),
        Expanded(child: TextField(controller: controller, obscureText: obscure, enabled: enabled,
          onChanged: onChange,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
        if (suffix != null) suffix,
      ]),
    );
  }
}
