import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "家用快篩地圖",
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [Locale('zh', 'TW')],
      theme: ThemeData(
        brightness: WidgetsBinding.instance.window.platformBrightness,
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}
