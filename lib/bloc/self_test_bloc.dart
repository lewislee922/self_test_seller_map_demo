import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/self_test_event.dart';
import '../bloc/self_test_state.dart';
import '../model.dart';

class SelfTestBloc extends Bloc<SelfTestEvent, SelfTestState> {
  final http.Client client;
  SelfTestBloc(this.client) : super(InitialState()) {
    on<FetchEvent>((event, emit) async {
      final _uri = Uri.parse(
          'https://data.nhi.gov.tw/Datasets/Download.ashx?rid=A21030000I-D03001-001&l=https://data.nhi.gov.tw/resource/Nhi_Fst/Fstdata.csv');
      final response = await client.get(_uri);
      if (response.statusCode == 200) {
        final dataString = utf8.decode(response.bodyBytes.toList());
        final dataList = CsvToListConverter().convert(dataString);
        dataList.removeAt(0);
        List<SelfTestInfo> info = <SelfTestInfo>[];
        for (var item in dataList) {
          info.add(SelfTestInfo.fromList(item));
        }
        emit(FinishState(info));
      } else {
        emit(NetworkErrorState());
      }
    });
  }
}
