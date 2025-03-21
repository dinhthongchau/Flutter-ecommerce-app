part of 'list_products_cubit.dart';

class ListProductsState {
  final List<ProductModel> product;
  final int selectedItem;
  final LoadStatus loadStatus;
  const ListProductsState.init({
    this.product = const [],
    this.selectedItem = -1,
    this.loadStatus = LoadStatus.Init,
  });

  //<editor-fold desc="Data Methods">
  const ListProductsState({
    required this.product,
    required this.selectedItem,
    required this.loadStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListProductsState &&
          runtimeType == other.runtimeType &&
          product == other.product &&
          selectedItem == other.selectedItem &&
          loadStatus == other.loadStatus);

  @override
  int get hashCode =>
      product.hashCode ^ selectedItem.hashCode ^ loadStatus.hashCode;

  @override
  String toString() {
    return 'ListProductsState{' +
        ' product: $product,' +
        ' selectedItem: $selectedItem,' +
        ' loadStatus: $loadStatus,' +
        '}';
  }

  ListProductsState copyWith({
    List<ProductModel>? product,
    int? selectedItem,
    LoadStatus? loadStatus,
  }) {
    return ListProductsState(
      product: product ?? this.product,
      selectedItem: selectedItem ?? this.selectedItem,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': this.product,
      'selectedItem': this.selectedItem,
      'loadStatus': this.loadStatus,
    };
  }

  factory ListProductsState.fromMap(Map<String, dynamic> map) {
    return ListProductsState(
      product: map['product'] as List<ProductModel>,
      selectedItem: map['selectedItem'] as int,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }

  //</editor-fold>
}
