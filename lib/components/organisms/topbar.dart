import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/logo.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Topbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,          // +alto para que el logo respire
      titleSpacing: 12,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Logo(
              width: 50,
              height: 50,
              color: const Color(0xFFE7E0EC),
              location: 'assets/logo.png',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
