part of 'cart_cubit.dart';

 class CartState {
  final List<ProductModel> cartItems;
  final List<int> selectedItem;
  final LoadStatus loadStatus;
  const CartState.init({
    this.cartItems= const [],
    this.selectedItem = const [],
    this.loadStatus = LoadStatus.Init,
  });
  //<editor-fold desc="Data Methods">
  const CartState({
    required this.cartItems,
    required this.selectedItem,
    required this.loadStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartState &&
          runtimeType == other.runtimeType &&
          cartItems == other.cartItems &&
          selectedItem == other.selectedItem &&
          loadStatus == other.loadStatus);

  @override
  int get hashCode =>
      cartItems.hashCode ^ selectedItem.hashCode ^ loadStatus.hashCode;

  @override
  String toString() {
    return 'CartState{' +
        ' cartItems: $cartItems,' +
        ' selectedItem: $selectedItem,' +
        ' loadStatus: $loadStatus,' +
        '}';
  }

  CartState copyWith({
    List<ProductModel>? cartItems,
    List<int>? selectedItem,
    LoadStatus? loadStatus,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      selectedItem: selectedItem ?? this.selectedItem,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItems': this.cartItems,
      'selectedItem': this.selectedItem,
      'loadStatus': this.loadStatus,
    };
  }

  factory CartState.fromMap(Map<String, dynamic> map) {
    return CartState(
      cartItems: map['cartItems'] as List<ProductModel>,
      selectedItem: map['selectedItem'] as List<int>,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }

  //</editor-fold>
}


