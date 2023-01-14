import 'package:flutter/material.dart';

class SnakePixels extends StatelessWidget {
  const SnakePixels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 50, 235, 96),
            borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
