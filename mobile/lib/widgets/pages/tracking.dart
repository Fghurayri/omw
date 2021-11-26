import 'dart:async';

import 'package:omw/widgets/text/normal_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omw/widgets/button/generic_button.dart';
import 'package:omw/widgets/text/speedometer.dart';
import 'package:phoenix_socket/phoenix_socket.dart';

const String webURL = "https://omw.lab.faisal.sh/follow/";
const String channelTopic = "tracking:";

class Tracking extends StatefulWidget {
  final String sessionId;
  final PhoenixSocket socket;
  final Function() clearSession;

  const Tracking(
      {Key? key,
      required this.socket,
      required this.sessionId,
      required this.clearSession})
      : super(key: key);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  late PhoenixChannel _channel;
  late StreamSubscription<Position> _positionStream;
  Position? _currentPosition;

  @override
  void initState() {
    setState(() {
      _channel =
          widget.socket.addChannel(topic: channelTopic + widget.sessionId);
      _channel.join();
    });
    watchAndPushLocation();
    super.initState();
  }

  @override
  void dispose() {
    _channel.close();
    _positionStream.cancel();
    super.dispose();
  }

  void watchAndPushLocation() async {
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    ).listen((Position position) {
      _channel.push("NEW_COORDS", position.toJson());
      setState(() {
        _currentPosition = position;
      });
    });
  }

  String convertMetersPerSecondToMph(speed) {
    double convertedSpeed = speed * 2.2369362921;
    return convertedSpeed.toStringAsFixed(0);
  }

  String formatSpeed(double? speed) {
    if (speed == null) return "";
    return convertMetersPerSecondToMph(speed);
  }

  String getTrackingURL(sessionId) {
    return webURL + sessionId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            NormalText(text: "(" + widget.sessionId + ")"),
            const SizedBox(
              height: 20,
            ),
            GenericButton(
                onPressed: () {
                  var trackingURL = getTrackingURL(widget.sessionId);
                  Share.share(trackingURL);
                },
                backgroundColor: Colors.grey.shade200,
                text: "🔗"),
          ],
        ),
        _currentPosition == null
            ? const Text("getting your location...")
            : Speedometer(text: formatSpeed(_currentPosition?.speed)),
        GenericButton(
          onPressed: widget.clearSession,
          text: "🗑",
          backgroundColor: Colors.grey.shade200,
        )
      ],
    );
  }
}
