part of 'create_customer_cubit.dart';


class CreateCustomerState {
  final List<CustomerModel> customer;
  final LoadStatus loadStatus;
  final int idCustomer;
  const CreateCustomerState.init(
      {
        this.customer = const [],
        this.loadStatus = LoadStatus.Init,
        this.idCustomer = 0,
      }
      );
//<editor-fold desc="Data Methods">

  const CreateCustomerState(
      {
        required this.customer ,
        required this.loadStatus ,
        required this.idCustomer ,
      }
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreateCustomerState &&
          runtimeType == other.runtimeType &&
          customer == other.customer &&
          loadStatus == other.loadStatus &&
          idCustomer == other.idCustomer);

  @override
  int get hashCode =>
      customer.hashCode ^ loadStatus.hashCode ^ idCustomer.hashCode;

  @override
  String toString() {
    return 'CreateCustomerState{' +
        ' customer: $customer,' +
        ' loadStatus: $loadStatus,' +
        ' idCustomer: $idCustomer,' +
        '}';
  }

  CreateCustomerState copyWith({
    List<CustomerModel>? customer,
    LoadStatus? loadStatus,
    int? idCustomer,
  }) {
    return CreateCustomerState(
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

  factory CreateCustomerState.fromMap(Map<String, dynamic> map) {
    return CreateCustomerState(
      customer: map['customer'] as List<CustomerModel>,
      loadStatus: map['loadStatus'] as LoadStatus,
      idCustomer: map['idCustomer'] as int,
    );
  }

//</editor-fold>
}


