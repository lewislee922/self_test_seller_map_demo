import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoDialog extends StatelessWidget {
  const DeveloperInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Info"),
      contentPadding: const EdgeInsets.all(24.0),
      children: [
        const Text("利用衛福部Open Data製作之快篩販售地圖\n可快速查詢線上剩餘庫存、電話和開啟手機地圖App導航"),
        const SizedBox(height: 16.0),
        const Text("版本：1.0.2"),
        const SizedBox(height: 32.0),
        TextButton(
            onPressed: () => launchUrl(Uri.parse(
                "https://github.com/lewislee922/self_test_seller_map_demo")),
            child: const Text("GitHub頁面"))
      ],
    );
  }
}
