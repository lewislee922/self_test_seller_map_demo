import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/self_test_bloc.dart';
import '../bloc/self_test_event.dart';
import '../bloc/self_test_state.dart';
import '../widgets/id_day_widget.dart';
import '../widgets/info_button.dart';
import '../widgets/instruction_dialog.dart';
import '../widgets/instruction_guide_button.dart';
import '../widgets/mark_popup_widget.dart';
import '../widgets/pin_example_widget.dart';

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
  double _currentZoom = 15.0;
  int _updateTime = 120;

  String _idDay() {
    final _weekDay = DateTime.now().weekday;
    if (_weekDay == 7) {
      return "無限制";
    } else if (_weekDay % 2 == 0) {
      return "身分證尾數0、2、4、6、8可購買";
    }
    return "身分證尾數1、3、5、7、9可購買";
  }

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
                  const Text("請開啟定位功能與權限以定位附近販售點"),
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
        if (_updateTime != 0) {
          _updateTime = _updateTime - 1;
        } else {
          _bloc.add(FetchEvent());
          _updateTime = 120;
        }
        _updateStreamController.sink.add(_updateTime);
      });

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _bloc = SelfTestBloc();
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
        child: const Icon(Icons.my_location),
        onPressed: () async {
          final position = await latlng();
          _mapController.move(
              LatLng(position.latitude, position.longitude), _currentZoom);
        },
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<LatLng>(
              future: latlng(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        center: LatLng(
                            snapshot.data!.latitude, snapshot.data!.longitude),
                        zoom: _currentZoom,
                        onPositionChanged: (_, __) =>
                            _currentZoom = _mapController.zoom),
                    children: [
                      TileLayerWidget(
                        options: TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                      ),
                      LocationMarkerLayerWidget(
                        options: LocationMarkerLayerOptions(
                          showHeadingSector: !kIsWeb,
                        ),
                      ),
                      BlocBuilder<SelfTestBloc, SelfTestState>(
                          bloc: _bloc,
                          builder: (context, state) {
                            if (state is FinishState) {
                              return PopupMarkerLayerWidget(
                                options: PopupMarkerLayerOptions(
                                    popupAnimation: const PopupAnimation.fade(),
                                    markerTapBehavior: MarkerTapBehavior
                                        .togglePopupAndHideRest(),
                                    markers: List<Marker>.from(
                                        state.list.map((e) => Marker(
                                            point: e.latLng,
                                            builder: (ctx) => Icon(
                                                  Icons.location_pin,
                                                  size: 32.0,
                                                  color: e.remainAmount >= 25
                                                      ? Colors.green
                                                      : Colors.red,
                                                )))),
                                    markerCenterAnimation:
                                        const MarkerCenterAnimation(),
                                    popupBuilder: (ctx, marker) {
                                      final _brightness = WidgetsBinding
                                          .instance.window.platformBrightness;
                                      final index = state.list.indexWhere(
                                          (element) =>
                                              element.latLng == marker.point);
                                      return SizedBox(
                                        width: 208,
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
                      SizedBox(height: 8.0),
                      Text("初始化中，請稍候")
                    ],
                  ),
                );
              },
            ),
            const Positioned(top: 16.0, left: 16.0, child: InfoButton()),
            Positioned(
                top: 16.0,
                right: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StreamBuilder(
                        stream: _updateStreamController.stream,
                        builder: (context, snapshot) {
                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
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
                                      _updateTime = 120;
                                      timer = _setTimer();
                                    })
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 8.0),
                    IdDayWidget(content: _idDay()),
                    const SizedBox(height: 8.0),
                    const PinExampleWidget(),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (ctx) => const InstructionDialog()),
                      child: const InstructionGuideButton(),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
