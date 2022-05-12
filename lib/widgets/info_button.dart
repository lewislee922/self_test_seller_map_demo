import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../develop_info_dialog.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white.withOpacity(0.75)
              : Colors.grey.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10.0)),
      child: IconButton(
        onPressed: () async {
          final _version = (await PackageInfo.fromPlatform()).version;
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (ctx) => DeveloperInfoDialog(verion: _version));
        },
        icon: const Icon(Icons.info),
      ),
    );
  }
}
