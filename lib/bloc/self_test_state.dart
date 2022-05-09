import 'package:self_test_seller_map_demo/model.dart';

abstract class SelfTestState {}

class LoadingState extends SelfTestState {}

class InitialState extends SelfTestState {}

class FinishState extends SelfTestState {
  final List<SelfTestInfo> list;

  FinishState(this.list);
}

class NetworkErrorState extends SelfTestState {}
