part of 'checkout_cubit.dart';

@immutable
class CheckoutState {

  LoadStatus loadStatus;
  final String selectedMethod;

    CheckoutState.init({
    this.loadStatus = LoadStatus.Init,
    this.selectedMethod = "",
  });

//<editor-fold desc="Data Methods">
  CheckoutState({
    required this.loadStatus,
    required this.selectedMethod,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckoutState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          selectedMethod == other.selectedMethod);

  @override
  int get hashCode => loadStatus.hashCode ^ selectedMethod.hashCode;

  @override
  String toString() {
    return 'CheckoutState{' +
        ' loadStatus: $loadStatus,' +
        ' selectedMethod: $selectedMethod,' +
        '}';
  }

  CheckoutState copyWith({
    LoadStatus? loadStatus,
    String? selectedMethod,
  }) {
    return CheckoutState(
      loadStatus: loadStatus ?? this.loadStatus,
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'selectedMethod': this.selectedMethod,
    };
  }

  factory CheckoutState.fromMap(Map<String, dynamic> map) {
    return CheckoutState(
      loadStatus: map['loadStatus'] as LoadStatus,
      selectedMethod: map['selectedMethod'] as String,
    );
  }

//</editor-fold>
}


