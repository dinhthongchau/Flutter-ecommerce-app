part of 'customer_cubit.dart';


class CustomerState {
  final List<CustomerModel> customer;
  final LoadStatus loadStatus;
  final int idCustomer;

  const CustomerState.init(
      {
        this.customer = const [],
        this.loadStatus = LoadStatus.Init,
        this.idCustomer = 0,
      }
      );
//<editor-fold desc="Data Methods">

  const CustomerState(
      {
        required this.customer ,
        required this.loadStatus ,
        required this.idCustomer ,
      }
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerState &&
          runtimeType == other.runtimeType &&
          customer == other.customer &&
          loadStatus == other.loadStatus &&
          idCustomer == other.idCustomer);

  @override
  int get hashCode =>
      customer.hashCode ^ loadStatus.hashCode ^ idCustomer.hashCode;

  @override
  String toString() {
    return 'CustomerState{' +
        ' customer: $customer,' +
        ' loadStatus: $loadStatus,' +
        ' idCustomer: $idCustomer,' +
        '}';
  }

  CustomerState copyWith({
    List<CustomerModel>? customer,
    LoadStatus? loadStatus,
    int? idCustomer,
  }) {
    return CustomerState(
      customer: customer ?? this.customer,
      loadStatus: loadStatus ?? this.loadStatus,
      idCustomer: idCustomer ?? this.idCustomer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer': this.customer,
      'loadStatus': this.loadStatus,
      'idCustomer': this.idCustomer,
    };
  }

  factory CustomerState.fromMap(Map<String, dynamic> map) {
    return CustomerState(
      customer: map['customer'] as List<CustomerModel>,
      loadStatus: map['loadStatus'] as LoadStatus,
      idCustomer: map['idCustomer'] as int,
    );
  }

//</editor-fold>
}


