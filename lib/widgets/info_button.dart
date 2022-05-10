import 'package:flutter/material.dart';

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
        onPressed: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (ctx) => const DeveloperInfoDialog());
        },
        icon: const Icon(Icons.info),
      ),
    );
  }
}
