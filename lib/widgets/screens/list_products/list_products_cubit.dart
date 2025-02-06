import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_one/models/product_model.dart';

import '../../../common/enum/load_status.dart';
import '../../../repositories/api.dart';

part 'list_products_state.dart';

class ListProductsCubit extends Cubit<ListProductsState> {
  Api api;
  ListProductsCubit(this.api) : super(ListProductsState.init());

  Future<void> loadData() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try{
        List<ProductModel> product = await api.getAllProducts();
        emit(state.copyWith(loadStatus: LoadStatus.Done, product: product));
        print("Products fetched: ${product.length}");
    }
    catch(e){
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  void setSelectedIndex(int index) {
    emit(state.copyWith(selectedItem: index));
  }
}
