import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyWdgAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackTapped;

  const MyWdgAppbar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon:
                  const Icon(CupertinoIcons.chevron_back, color: Colors.black),
              onPressed: onBackTapped ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Butler',
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: actions,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
