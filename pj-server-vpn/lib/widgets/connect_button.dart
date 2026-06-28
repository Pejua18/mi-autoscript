import 'package:flutter/material.dart';
import '../models/vpn_provider.dart';

class ConnectButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;
  const ConnectButton({super.key, required this.status, required this.onTap});
  @override State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;
  @override void initState() { super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _shimmer = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final isConnected = widget.status == VpnStatus.connected;
    final isConnecting = widget.status == VpnStatus.connecting;
    return GestureDetector(onTap: widget.onTap, child: AnimatedBuilder(animation: _shimmer, builder: (context, _) {
      return Container(height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        gradient: isConnected ? const LinearGradient(colors: [Color(0xFF00B050), Color(0xFF00D860)], begin: Alignment.centerLeft, end: Alignment.centerRight)
          : isConnecting ? LinearGradient(colors: [const Color(0xFF0066CC), const Color(0xFF00C8FF), const Color(0xFF0066CC)],
              stops: [(_shimmer.value - 0.5).clamp(0.0, 1.0), _shimmer.value.clamp(0.0, 1.0), (_shimmer.value + 0.5).clamp(0.0, 1.0)],
              begin: Alignment.centerLeft, end: Alignment.centerRight)
          : const LinearGradient(colors: [Color(0xFF3A7BD5), Color(0xFFBB57FF)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        boxShadow: [BoxShadow(color: (isConnected ? Colors.greenAccent : const Color(0xFF3A7BD5)).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Center(child: isConnecting
          ? const Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))), SizedBox(width: 10), Text('CONECTANDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5))])
          : Text(isConnected ? 'DESCONECTAR' : 'CONECTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 2))));
    }));
  }
}
