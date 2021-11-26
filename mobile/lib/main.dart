import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omw/widgets/text/normal_text.dart';
import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/pages/onboarding.dart';
import 'widgets/pages/tracking.dart';

const String wsURL = "wss://bitter-sky-9233.fly.dev/socket/websocket";
const String sessionPersistenceKey = "omw-session";

enum AppFlowState {
  initializing,
  onboarding,
  tracking,
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Omw',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PhoenixSocket _socket = PhoenixSocket(wsURL);
  String? _sessionId;

  AppFlowState _appFlowState = AppFlowState.initializing;
  bool _isInitializing() =>
      _appFlowState.toString() == AppFlowState.initializing.toString();
  bool _isOnboarding() =>
      _appFlowState.toString() == AppFlowState.onboarding.toString();

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    _connectSocket();
    _loadPersistedSession();
  }

  void _connectSocket() {
    _socket.connect();
  }

  void _loadPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(sessionPersistenceKey);
    return _sessionId == null
        ? setState(() {
            _appFlowState = AppFlowState.onboarding;
          })
        : setState(() {
            _appFlowState = AppFlowState.tracking;
          });
  }

  void _persistSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionPersistenceKey, sessionId);
    _sessionId = sessionId;
    setState(() {
      _appFlowState = AppFlowState.tracking;
    });
  }

  void _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _sessionId = null;
    setState(() {
      _appFlowState = AppFlowState.onboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          toolbarHeight: 0.1,
        ),
        body: Center(
            child: _isInitializing()
                ? const NormalText(
                    text: "Loading",
                  )
                : _isOnboarding()
                    ? Onboarding(
                        socket: _socket,
                        persistSession: _persistSession,
                      )
                    : Tracking(
                        socket: _socket,
                        sessionId: _sessionId!,
                        clearSession: _clearSession,
                      )));
  }
}
