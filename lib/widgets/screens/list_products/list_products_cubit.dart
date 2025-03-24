import 'package:bloc/bloc.dart';
import 'package:project_one/models/product_model.dart';
import '../../../common/enum/load_status.dart';
import '../../../repositories/api.dart';
import '../../../repositories/api_server.dart'; // Add this import

part 'list_products_state.dart';

class ListProductsCubit extends Cubit<ListProductsState> {
  ApiServer api; // Change from Api to ApiServer
  ListProductsCubit(this.api) : super(ListProductsState.init());

  Future<void> loadData() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      List<ProductModel> product = await api.getAllProducts();
      emit(state.copyWith(loadStatus: LoadStatus.Done, product: product));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  void setSelectedIndex(int index) {
    emit(state.copyWith(selectedItem: index));
  }
}