import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/auth/auth_service.dart';

enum PopupMenuItems { signOut }

class TemperatureAppAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TemperatureAppAppBar(
      {super.key, required this.title, this.showMenu = true, this.onPop});

  final String title;
  final bool showMenu;
  final void Function()? onPop;

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthService>().signOut();
  }

  List<Widget>? menuActions(BuildContext context) {
    if (!showMenu) {
      return null;
    } else {
      return [
        PopupMenuButton<PopupMenuItems>(
          onSelected: (PopupMenuItems item) {
            switch (item) {
              case PopupMenuItems.signOut:
                // TODO: Add confirmation
                _signOut(context);
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuItems>>[
            const PopupMenuItem<PopupMenuItems>(
                value: PopupMenuItems.signOut, child: Text("SignOut")),
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: menuActions(context),
      leading: onPop == null ? null : IconButton(
        onPressed: onPop,
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
