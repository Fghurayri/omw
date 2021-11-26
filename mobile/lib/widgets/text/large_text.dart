import 'package:flutter/material.dart';

class LargeText extends StatelessWidget {
  final String text;

  const LargeText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.blueGrey,
        fontSize: 40,
      ),
    );
  }
}
