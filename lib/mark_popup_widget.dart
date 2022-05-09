import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:self_test_seller_map_demo/model.dart';

class MarkPopupWidget extends StatelessWidget {
  final SelfTestInfo info;
  const MarkPopupWidget({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 2, child: Text(info.manufactor)),
                Flexible(
                  flex: 1,
                  child: Text(
                    info.remainAmount.toString(),
                    style: TextStyle(
                        fontSize: 24,
                        color: info.remainAmount >= 50 ? null : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info.sellerName,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      info.sellerTel,
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                info.note != "無"
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    children: [Center(child: Text(info.note))],
                                  ));
                        },
                        icon: Icon(Icons.warning))
                    : const SizedBox(),
              ],
            ),
            Spacer(),
            TextButton(
                onPressed: () async {
                  final availableMaps = await MapLauncher.installedMaps;
                  await availableMaps.first.showMarker(
                    coords: Coords(info.latLng.latitude, info.latLng.longitude),
                    title: info.sellerName,
                  );
                },
                child: Text("導航"))
          ],
        ),
      ),
    );
  }
}
