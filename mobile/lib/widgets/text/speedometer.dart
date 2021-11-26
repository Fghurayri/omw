import 'package:flutter/material.dart';

class Speedometer extends StatelessWidget {
  final String text;

  const Speedometer({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 150,
          ),
        ),
        const Text(
          "mph",
          style: TextStyle(
            color: Colors.blueGrey,
          ),
        )
      ],
    );
  }
}
