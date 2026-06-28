import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';

enum VpnStatus { disconnected, connecting, connected, error }

class VpnProfile {
  final String name;
  final String host;
  final int wsPort;
  final int sshPort;
  final String type;
  VpnProfile({required this.name, required this.host, required this.wsPort, required this.sshPort, required this.type});
}

class _WsSSHSocket implements SSHClientSocket {
  final WebSocket _ws;
  final _inCtl = StreamController<Uint8List>();
  _WsSSHSocket(this._ws) {
    _ws.listen(
      (data) {
        if (data is Uint8List) _inCtl.add(data);
        else if (data is String) _inCtl.add(Uint8List.fromList(utf8.encode(data)));
        else if (data is List<int>) _inCtl.add(Uint8List.fromList(data));
      },
      onError: (e) => _inCtl.addError(e),
      onDone: () => _inCtl.close(),
      cancelOnError: false,
    );
  }
  @override Stream<Uint8List> get stream => _inCtl.stream;
  @override StreamSink<List<int>> get sink => _WsSink(_ws);
  @override Future<void> destroy() async { await _ws.close(); await _inCtl.close(); }
  @override Future<void> close() => destroy();
}

class _WsSink implements StreamSink<List<int>> {
  final WebSocket _ws;
  _WsSink(this._ws);
  @override void add(List<int> data) => _ws.add(Uint8List.fromList(data));
  @override void addError(Object error, [StackTrace? st]) {}
  @override Future addStream(Stream<List<int>> stream) async { await for (final chunk in stream) _ws.add(Uint8List.fromList(chunk)); }
  @override Future get done => Future.value();
  @override Future close() async => _ws.close();
}

class VpnProvider extends ChangeNotifier {
  VpnStatus _status = VpnStatus.disconnected;
  String _username = '';
  String _password = '';
  final List<String> _logs = [];
  VpnProfile _activeProfile = VpnProfile(name: 'PERSONAL 1', host: 'www.pejotaa.site', wsPort: 2080, sshPort: 111, type: 'ws+ssh');
  WebSocket? _ws;
  SSHClient? _sshClient;
  SSHSession? _sshSession;
  Timer? _pingTimer;
  int _pingMs = 0;
  String _errorMessage = '';

  VpnStatus get status => _status;
  String get username => _username;
  String get password => _password;
  List<String> get logs => List.unmodifiable(_logs);
  VpnProfile get activeProfile => _activeProfile;
  int get pingMs => _pingMs;
  String get errorMessage => _errorMessage;
  bool get isConnected => _status == VpnStatus.connected;
  bool get isConnecting => _status == VpnStatus.connecting;
  bool get hasError => _status == VpnStatus.error;

  void setUsername(String v) { _username = v; notifyListeners(); }
  void setPassword(String v) { _password = v; notifyListeners(); }
  void setProfile(VpnProfile p) { _activeProfile = p; notifyListeners(); }

  void addLog(String msg) {
    final now = DateTime.now();
    final t = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}';
    _logs.insert(0, '[$t] $msg');
    if (_logs.length > 200) _logs.removeLast();
    notifyListeners();
  }
  void clearLogs() { _logs.clear(); notifyListeners(); }

  Future<void> connect() async {
    if (_username.isEmpty || _password.isEmpty) { addLog('Ingrese usuario y contrasena'); return; }
    _status = VpnStatus.connecting; _errorMessage = ''; notifyListeners();
    try {
      if (_activeProfile.type == 'ws+ssh') await _connectWsSsh();
      else await _connectSshDirect();
    } catch (e) {
      _status = VpnStatus.error; _errorMessage = e.toString();
      addLog('Error: $_errorMessage'); await _cleanup(); notifyListeners();
    }
  }

  Future<void> _connectWsSsh() async {
    final host = _activeProfile.host;
    final wsPort = _activeProfile.wsPort;
    addLog('Conectando a $host...');
    _ws = await WebSocket.connect('ws://$host:$wsPort', headers: {'Host': host}).timeout(const Duration(seconds: 12));
    addLog('WebSocket OK');
    _sshClient = SSHClient(_WsSSHSocket(_ws!), username: _username, onPasswordRequest: () => _password, onAuthenticated: () => addLog('Autenticacion exitosa'));
    await _sshClient!.authenticated.timeout(const Duration(seconds: 15));
    _sshSession = await _sshClient!.shell();
    _sshSession!.stdout.transform(utf8.decoder).listen((data) { for (final l in data.split('\n')) { final s = l.trim(); if (s.isNotEmpty) addLog('> $s'); } });
    _sshSession!.stderr.transform(utf8.decoder).listen((data) { final s = data.trim(); if (s.isNotEmpty) addLog('! $s'); });
    _sshSession!.done.then((_) { if (_status == VpnStatus.connected) _handleDisconnect(); });
    _onConnected();
  }

  Future<void> _connectSshDirect() async {
    final host = _activeProfile.host;
    final port = _activeProfile.sshPort;
    addLog('SSH directo -> $host:$port (Dropbear)');
    final rawSocket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
    _sshClient = SSHClient(rawSocket, username: _username, onPasswordRequest: () => _password, onAuthenticated: () => addLog('Auth exitosa'));
    await _sshClient!.authenticated.timeout(const Duration(seconds: 15));
    _sshSession = await _sshClient!.shell();
    _sshSession!.stdout.transform(utf8.decoder).listen((data) { for (final l in data.split('\n')) { final s = l.trim(); if (s.isNotEmpty) addLog('> $s'); } });
    _sshSession!.done.then((_) { if (_status == VpnStatus.connected) _handleDisconnect(); });
    _onConnected();
  }

  void _onConnected() {
    _status = VpnStatus.connected;
    addLog('Conectado - usuario: $_username');
    notifyListeners();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final start = DateTime.now();
        final port = _activeProfile.type == 'ws+ssh' ? _activeProfile.wsPort : _activeProfile.sshPort;
        final s = await Socket.connect(_activeProfile.host, port, timeout: const Duration(seconds: 3));
        _pingMs = DateTime.now().difference(start).inMilliseconds;
        s.destroy(); notifyListeners();
      } catch (_) {}
    });
  }

  Future<void> disconnect() async { addLog('Desconectando...'); await _cleanup(); _handleDisconnect(); }
  void _handleDisconnect() { _status = VpnStatus.disconnected; _pingMs = 0; addLog('Desconectado'); notifyListeners(); }
  Future<void> _cleanup() async {
    _pingTimer?.cancel(); _pingTimer = null;
    try { _sshSession?.close(); } catch (_) {}
    try { _sshClient?.close(); } catch (_) {}
    try { await _ws?.close(); } catch (_) {}
    _sshSession = null; _sshClient = null; _ws = null;
  }
  @override void dispose() { _cleanup(); super.dispose(); }
}
