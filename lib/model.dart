import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class SelfTestInfo {
  final String sellerName;
  final String sellerAddress;
  final String sellerTel;
  final LatLng latLng;
  final String manufactor;
  final int remainAmount;
  final DateTime updateTime;
  final String note;

  SelfTestInfo.fromList(List<dynamic> list)
      : sellerName = list[1],
        sellerAddress = list[2],
        latLng = LatLng(list[4], list[3]),
        sellerTel = list[5],
        manufactor = list[6],
        remainAmount = list[7],
        updateTime = DateFormat("yyyy/MM/dd hh:mm:ss").parse(list[8]),
        note = list[9];
}
