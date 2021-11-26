import 'package:flutter/material.dart';

class GenericButton extends StatelessWidget {
  final Function() onPressed;
  final Color backgroundColor;
  final double fontSize;
  final String text;

  const GenericButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      this.backgroundColor = Colors.blueGrey,
      this.fontSize = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
      ),
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size.square(100)),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor)),
    );
  }
}
