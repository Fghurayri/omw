import 'package:flutter/material.dart';
import 'package:omw/widgets/button/generic_button.dart';
import 'package:omw/widgets/v_spacer.dart';
import 'package:phoenix_socket/phoenix_socket.dart';

import 'package:omw/widgets/text/large_text.dart';
import 'package:omw/widgets/text/normal_text.dart';

class Onboarding extends StatefulWidget {
  final PhoenixSocket socket;
  final Function(String) persistSession;

  const Onboarding(
      {Key? key, required this.socket, required this.persistSession})
      : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  String _suggestedSessionId = "";
  late PhoenixChannel _channel;

  @override
  void initState() {
    setState(() {
      _channel = widget.socket.addChannel(topic: "onboarding");
      _channel.join();
    });
    _generateSessionName();
    super.initState();
  }

  @override
  void dispose() {
    _channel.close();
    super.dispose();
  }

  void _generateSessionName() {
    _channel.push("GENERATE_NEW_SESSION_NAME", {}).onReply("ok",
        (generatedSessionName) {
      setState(() {
        _suggestedSessionId = generatedSessionName.response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GenericButton(
          onPressed: _generateSessionName,
          text: "↻",
        ),
        Column(
          children: [
            const NormalText(text: "suggested session name"),
            const VSpacer(),
            LargeText(text: _suggestedSessionId),
          ],
        ),
        GenericButton(
          onPressed: () => widget.persistSession(_suggestedSessionId),
          text: "✓",
          backgroundColor: Colors.green,
        ),
      ],
    );
  }
}
