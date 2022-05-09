import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:self_test_seller_map_demo/bloc/self_test_bloc.dart';
import 'package:self_test_seller_map_demo/bloc/self_test_event.dart';
import 'package:self_test_seller_map_demo/bloc/self_test_state.dart';
import 'package:self_test_seller_map_demo/develop_info_dialog.dart';
import 'package:self_test_seller_map_demo/mark_popup_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late SelfTestBloc _bloc;
  late Timer timer;
  late StreamController _updateStreamController;
  final MapController _mapController = MapController();
  int updateTime = 120;
  Future<LatLng> latlng() async {
    try {
      final position = await _determinePosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      late LatLng _latlng;
      await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                contentPadding: const EdgeInsets.all(8.0),
                children: [
                  const Text("請開啟定位功能與權限以定位附近販賣點"),
                  TextButton(
                      onPressed: () async {
                        final permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.deniedForever) {
                          _latlng = LatLng(23.973875, 120.982024);
                        } else {
                          final _position =
                              await Geolocator.getCurrentPosition();
                          _latlng =
                              LatLng(_position.latitude, _position.longitude);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("確定"))
                ],
              ));
      return _latlng;
    }
  }

  Timer _setTimer() => Timer.periodic(const Duration(seconds: 1), (timer) {
        if (updateTime != 0) {
          updateTime = updateTime - 1;
        } else {
          _bloc.add(FetchEvent());
          updateTime = 120;
        }
        _updateStreamController.sink.add(updateTime);
      });

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _bloc = SelfTestBloc(http.Client());
    _updateStreamController = StreamController<int>();
    timer = _setTimer();
    _bloc.add(FetchEvent());
  }

  @override
  void dispose() {
    _updateStreamController.close();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () async {
          final position = await latlng();
          _mapController.move(position, 15);
        },
      ),
      body: SafeArea(
        child: Stack(alignment: Alignment.center, children: [
          StreamBuilder<LatLng>(
              stream: latlng().asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(center: snapshot.data, zoom: 15.0),
                    children: [
                      TileLayerWidget(
                        options: TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                      ),
                      LocationMarkerLayerWidget(
                        options: LocationMarkerLayerOptions(),
                      ),
                      BlocBuilder<SelfTestBloc, SelfTestState>(
                          bloc: _bloc,
                          builder: (context, state) {
                            if (state is FinishState) {
                              return PopupMarkerLayerWidget(
                                options: PopupMarkerLayerOptions(
                                    popupAnimation: PopupAnimation.fade(),
                                    markerTapBehavior: MarkerTapBehavior
                                        .togglePopupAndHideRest(),
                                    markers: List<Marker>.from(
                                        state.list.map((e) => Marker(
                                            point: e.latLng,
                                            builder: (ctx) => Icon(
                                                  Icons.location_pin,
                                                  size: 32.0,
                                                  color: e.remainAmount >= 50
                                                      ? Colors.green
                                                      : Colors.red,
                                                )))),
                                    markerCenterAnimation:
                                        MarkerCenterAnimation(),
                                    popupBuilder: (ctx, marker) {
                                      final _brightness = WidgetsBinding
                                          .instance!.window.platformBrightness;
                                      final index = state.list.indexWhere(
                                          (element) =>
                                              element.latLng == marker.point);
                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        child: MarkPopupWidget(
                                          info: state.list[index],
                                          brightness: _brightness,
                                        ),
                                      );
                                    }),
                              );
                            }
                            return const SizedBox();
                          }),
                    ],
                  );
                }
                return Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 4.0),
                      Text("初始化中，請稍候")
                    ],
                  ),
                );
              }),
          Positioned(
              top: 16.0,
              left: 16.0,
              child: IconButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (ctx) => const DeveloperInfoDialog());
                  },
                  icon: const Icon(Icons.info))),
          Positioned(
              top: 16.0,
              right: 16.0,
              child: StreamBuilder(
                  stream: _updateStreamController.stream,
                  builder: (context, snapshot) {
                    return Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white.withOpacity(0.75)
                            : Colors.grey.withOpacity(0.75),
                      ),
                      child: Row(
                        children: [
                          Text("${snapshot.data ?? 0}秒後更新"),
                          const SizedBox(width: 4.0),
                          IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                timer.cancel();
                                _bloc.add(FetchEvent());
                                updateTime = 120;
                                timer = _setTimer();
                              })
                        ],
                      ),
                    );
                  })),
        ]),
      ),
    );
  }
}
