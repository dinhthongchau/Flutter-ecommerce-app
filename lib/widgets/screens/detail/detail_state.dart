part of 'detail_cubit.dart';

@immutable
class DetailState {
  final LoadStatus loadStatus;

  const DetailState.init({
    this.loadStatus = LoadStatus.Init,
  });
}
