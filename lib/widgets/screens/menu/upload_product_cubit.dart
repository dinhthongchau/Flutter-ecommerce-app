import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api_server.dart';

part 'upload_product_state.dart';

class ProductUploadCubit extends Cubit<ProductUploadState> {
  final ApiServer apiServer;

  ProductUploadCubit(this.apiServer) : super(ProductUploadInitial());

  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required String productColor,
    required String productDescription,
    required List<PlatformFile> imageFiles,
  }) async {
    emit(ProductUploadLoading());

    try {
      ProductModel product = ProductModel(
        product_id: 0, // Server sẽ tạo ID
        product_name: productName,
        product_price: productPrice,
        product_color: productColor,
        product_description: productDescription,
        product_image: [], // Không cần gửi URL, server sẽ trả về URL
      );

      final response = await apiServer.createProduct(product, imageFiles);
      emit(ProductUploadSuccess(response));
    } catch (e) {
      emit(ProductUploadFailure(e.toString()));
    }
  }
}