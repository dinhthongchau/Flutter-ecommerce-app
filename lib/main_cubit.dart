import 'package:bloc/bloc.dart';


import 'repositories/log.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainState.init());

  void setTheme(bool isLightTheme) {
    emit(state.copyWith(isLightTheme: isLightTheme));
  }
}
//log

class MyBlocObserver extends BlocObserver {
  final Log log;
  static const String TAG = "Bloc";

  MyBlocObserver(this.log);

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log.i(TAG, 'onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.i(TAG, 'onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.i(TAG, 'onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log.i(TAG, 'onClose -- ${bloc.runtimeType}');
  }
}
