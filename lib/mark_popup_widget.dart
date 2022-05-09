import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:self_test_seller_map_demo/model.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkPopupWidget extends StatelessWidget {
  final SelfTestInfo info;
  final Brightness brightness;
  const MarkPopupWidget(
      {Key? key, required this.info, required this.brightness})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(flex: 4, child: Text(info.manufactor, softWrap: true)),
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      info.remainAmount.toString(),
                      style: TextStyle(
                          fontSize: 24,
                          color: info.remainAmount >= 50 ? null : Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color:
                  brightness == Brightness.light ? Colors.black : Colors.white,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          info.sellerName,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        info.sellerTel,
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ),
                info.note != "無"
                    ? Flexible(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                        contentPadding:
                                            const EdgeInsets.all(8.0),
                                        children: [
                                          Center(child: Text(info.note))
                                        ],
                                      ));
                            },
                            icon: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Icon(Icons.warning))),
                      )
                    : const SizedBox(),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !kIsWeb
                    ? TextButton(
                        onPressed: () {
                          launchUrl(Uri(
                              scheme: 'tel',
                              path: info.sellerTel
                                  .replaceAll(RegExp(r"/(\(\)/)"), "")));
                        },
                        child: Text("致電"))
                    : const SizedBox(),
                TextButton(
                    onPressed: () async {
                      if (kIsWeb) {
                        MapsLauncher.launchCoordinates(info.latLng.latitude,
                            info.latLng.longitude, info.sellerName);
                      } else {
                        final availableMaps = await MapLauncher.installedMaps;
                        await availableMaps.first.showMarker(
                          coords: Coords(
                              info.latLng.latitude, info.latLng.longitude),
                          title: info.sellerName,
                        );
                      }
                    },
                    child: Text("導航"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
