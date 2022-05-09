import 'package:flutter/material.dart';

class DeveloperInfoDialog extends StatelessWidget {
  const DeveloperInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Text("利用衛福部Open Data製作之快篩販售地圖\n可快速查詢線上剩餘庫存、電話，並開啟手機地圖App導航"),
        Text("版本：1.0.0+1")
      ],
    );
  }
}
