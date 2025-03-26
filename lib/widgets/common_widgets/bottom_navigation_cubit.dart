import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavigationCubit extends Cubit<int> {
  BottomNavigationCubit() : super(0); // Khởi tạo với index 0 (Home)

  void setPageIndex(int index) {
    emit(index); // Phát ra index mới khi người dùng chọn trang
  }
}
