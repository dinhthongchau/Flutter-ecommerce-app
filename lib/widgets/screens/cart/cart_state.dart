part of 'cart_cubit.dart';

 class CartState {
  final List<ProductModel> cartItems;
  final List<int> selectedItem;
  final LoadStatus loadStatus;
  final Map<int, int> quantities; // Map<Key, Value> product_id , so luong
  final List<ProductModel> selectedProducts; // Lưu sản phẩm đã chọn
  final Map<int, int> selectedQuantities;
  final int totalPayment;
  final bool allSelected;
  const CartState.init({
    this.cartItems= const [],
    this.selectedItem = const [],
    this.loadStatus = LoadStatus.Init,
    this.quantities = const {},
    this.selectedProducts = const [],
    this.selectedQuantities = const {},
    this.totalPayment = 0,
    this.allSelected = false,
  });

  //<editor-fold desc="Data Methods">
  const CartState({
    required this.cartItems,
    required this.selectedItem,
    required this.loadStatus,
    required this.quantities,
    required this.selectedProducts,
    required this.selectedQuantities,
    required this.totalPayment,
    required this.allSelected,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartState &&
          runtimeType == other.runtimeType &&
          cartItems == other.cartItems &&
          selectedItem == other.selectedItem &&
          loadStatus == other.loadStatus &&
          quantities == other.quantities &&
          selectedProducts == other.selectedProducts &&
          selectedQuantities == other.selectedQuantities &&
          totalPayment == other.totalPayment &&
          allSelected == other.allSelected);

  @override
  int get hashCode =>
      cartItems.hashCode ^
      selectedItem.hashCode ^
      loadStatus.hashCode ^
      quantities.hashCode ^
      selectedProducts.hashCode ^
      selectedQuantities.hashCode ^
      totalPayment.hashCode ^
      allSelected.hashCode;

  @override
  String toString() {
    return 'CartState{' +
        ' cartItems: $cartItems,' +
        ' selectedItem: $selectedItem,' +
        ' loadStatus: $loadStatus,' +
        ' quantities: $quantities,' +
        ' selectedProducts: $selectedProducts,' +
        ' selectedQuantities: $selectedQuantities,' +
        ' totalPayment: $totalPayment,' +
        ' allSelected: $allSelected,' +
        '}';
  }

  CartState copyWith({
    List<ProductModel>? cartItems,
    List<int>? selectedItem,
    LoadStatus? loadStatus,
    Map<int, int>? quantities,
    List<ProductModel>? selectedProducts,
    Map<int, int>? selectedQuantities,
    int? totalPayment,
    bool? allSelected,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      selectedItem: selectedItem ?? this.selectedItem,
      loadStatus: loadStatus ?? this.loadStatus,
      quantities: quantities ?? this.quantities,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedQuantities: selectedQuantities ?? this.selectedQuantities,
      totalPayment: totalPayment ?? this.totalPayment,
      allSelected: allSelected ?? this.allSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItems': this.cartItems,
      'selectedItem': this.selectedItem,
      'loadStatus': this.loadStatus,
      'quantities': this.quantities,
      'selectedProducts': this.selectedProducts,
      'selectedQuantities': this.selectedQuantities,
      'totalPayment': this.totalPayment,
      'allSelected': this.allSelected,
    };
  }

  factory CartState.fromMap(Map<String, dynamic> map) {
    return CartState(
      cartItems: map['cartItems'] as List<ProductModel>,
      selectedItem: map['selectedItem'] as List<int>,
      loadStatus: map['loadStatus'] as LoadStatus,
      quantities: map['quantities'] as Map<int, int>,
      selectedProducts: map['selectedProducts'] as List<ProductModel>,
      selectedQuantities: map['selectedQuantities'] as Map<int, int>,
      totalPayment: map['totalPayment'] as int,
      allSelected: map['allSelected'] as bool,
    );
  }

  //</editor-fold>
}


