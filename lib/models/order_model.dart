import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final int customerId;
  final double orderTotal;
  final String orderPaymentMethod;
  final String orderStatus;
  final String orderNote;

  OrderModel({
    required this.customerId,
    required this.orderTotal,
    required this.orderPaymentMethod,
    required this.orderStatus,
    required this.orderNote,
  });

  // Convert JSON to OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  // Convert OrderModel to JSON
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
