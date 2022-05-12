import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InstructionDialog extends StatelessWidget {
  static final Map<String, dynamic> _linkMap = {
    "羅氏家用自我檢測套組": {
      "國語": "https://www.youtube.com/watch?v=R-q9l_bT6H4",
      "台語": "https://www.youtube.com/watch?v=HcOpkOFMd4c",
      "客語": "https://www.youtube.com/watch?v=Jzsbu0UoLKI",
      "泰語": "https://www.youtube.com/watch?v=n2zG07VTYAU",
      "印尼語": "https://www.youtube.com/watch?v=FYl1cQQMb0U",
      "越南語": "https://www.youtube.com/watch?v=UBt0dg6gxKI"
    }
  };
  const InstructionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      title: Text("操作影片說明"),
      children: _mapToWidget(),
    );
  }

  _mapToWidget() {
    final widget = <Widget>[];
    _linkMap.forEach((key, value) {
      widget.add(Text(
        "★ " + key,
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      widget.add(SizedBox(height: 8.0));
      final list = (value as Map<String, String>)
          .keys
          .map((key) => TextButton(
              onPressed: () => launchUrlString(value[key].toString()),
              child: Text(key)))
          .toList();
      widget.add(Wrap(children: list));
    });
    return widget;
  }
}
