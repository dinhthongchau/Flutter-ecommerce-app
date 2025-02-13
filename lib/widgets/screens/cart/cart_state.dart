part of 'cart_cubit.dart';

 class CartState {
  final List<ProductModel> cartItems;
  final List<int> selectedItem;
  final LoadStatus loadStatus;
  final Map<int, int> quantities; // Map<Key, Value> product_id , so luong
  const CartState.init({
    this.cartItems= const [],
    this.selectedItem = const [],
    this.loadStatus = LoadStatus.Init,
    this.quantities = const {},
  });

  //<editor-fold desc="Data Methods">
  const CartState({
    required this.cartItems,
    required this.selectedItem,
    required this.loadStatus,
    required this.quantities,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartState &&
          runtimeType == other.runtimeType &&
          cartItems == other.cartItems &&
          selectedItem == other.selectedItem &&
          loadStatus == other.loadStatus &&
          quantities == other.quantities);

  @override
  int get hashCode =>
      cartItems.hashCode ^
      selectedItem.hashCode ^
      loadStatus.hashCode ^
      quantities.hashCode;

  @override
  String toString() {
    return 'CartState{' +
        ' cartItems: $cartItems,' +
        ' selectedItem: $selectedItem,' +
        ' loadStatus: $loadStatus,' +
        ' quantities: $quantities,' +
        '}';
  }

  CartState copyWith({
    List<ProductModel>? cartItems,
    List<int>? selectedItem,
    LoadStatus? loadStatus,
    Map<int, int>? quantities,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      selectedItem: selectedItem ?? this.selectedItem,
      loadStatus: loadStatus ?? this.loadStatus,
      quantities: quantities ?? this.quantities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItems': this.cartItems,
      'selectedItem': this.selectedItem,
      'loadStatus': this.loadStatus,
      'quantities': this.quantities,
    };
  }

  factory CartState.fromMap(Map<String, dynamic> map) {
    return CartState(
      cartItems: map['cartItems'] as List<ProductModel>,
      selectedItem: map['selectedItem'] as List<int>,
      loadStatus: map['loadStatus'] as LoadStatus,
      quantities: map['quantities'] as Map<int, int>,
    );
  }

  //</editor-fold>
}


