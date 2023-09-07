import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider({super.key, this.height = 16.0});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
