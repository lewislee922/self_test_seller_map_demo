import 'package:flutter/material.dart';

class IdDayWidget extends StatelessWidget {
  final String content;
  const IdDayWidget({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white.withOpacity(0.75)
              : Colors.grey.withOpacity(0.75)),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(content),
      ),
    );
  }
}
