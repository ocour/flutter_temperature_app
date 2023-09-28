import 'package:flutter/material.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

class BleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BleAppBar({super.key, required this.title, this.onPop});

  final String title;
  final void Function()? onPop;

  @override
  Widget build(BuildContext context) {
    return TemperatureAppAppBar(
      title: title,
      showMenu: false,
      onPop: onPop,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
