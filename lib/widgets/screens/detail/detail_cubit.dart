import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_one/common/enum/load_status.dart';

part 'detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  DetailCubit() : super(DetailState.init());
}
