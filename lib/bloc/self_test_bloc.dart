import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_test_seller_map/chopper/self_test_info_list_service.dart';

import '../bloc/self_test_event.dart';
import '../bloc/self_test_state.dart';
import '../model.dart';

class SelfTestBloc extends Bloc<SelfTestEvent, SelfTestState> {
  final chopper = ChopperClient(services: [
    SelfTestInfoListService.create(),
  ], converter: InfoConverter());
  SelfTestBloc() : super(InitialState()) {
    on<FetchEvent>((event, emit) async {
      final _service = chopper.getService<SelfTestInfoListService>();
      final response = await _service.getInfo();

      if (response.isSuccessful) {
        final dataList = response.body as List<List<dynamic>>;
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
