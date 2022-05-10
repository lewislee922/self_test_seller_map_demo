import 'package:flutter/material.dart';

class PinExampleWidget extends StatelessWidget {
  const PinExampleWidget({Key? key}) : super(key: key);

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
          child: Row(
            children: [
              Icon(
                Icons.location_pin,
                color: Colors.green,
              ),
              Text(">=25"),
              SizedBox(width: 4.0),
              Icon(
                Icons.location_pin,
                color: Colors.red,
              ),
              Text("<25"),
            ],
          )),
    );
  }
}
