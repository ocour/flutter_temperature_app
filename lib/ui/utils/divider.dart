import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  const MyDivider({super.key, this.height = 16.0});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
