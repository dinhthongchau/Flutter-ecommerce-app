part of 'upload_product_cubit.dart';

abstract class ProductUploadState {
  final String? message;

  ProductUploadState({this.message});
}

class ProductUploadInitial extends ProductUploadState {
  ProductUploadInitial() : super(message: null);
}

class ProductUploadLoading extends ProductUploadState {
  ProductUploadLoading() : super(message: "Uploading...");
}

class ProductUploadSuccess extends ProductUploadState {
  final Map<String, dynamic> response;
  ProductUploadSuccess(this.response) : super(message: "Product uploaded successfully!");
}

class ProductUploadFailure extends ProductUploadState {
  final String error;
  ProductUploadFailure(this.error) : super(message: "Failed to upload product: $error");
}