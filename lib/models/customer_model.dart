import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';
@JsonSerializable()
class CustomerModel {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;

  const CustomerModel({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
  });

  //json to object
  factory CustomerModel.fromJson(Map<String,dynamic> json) => _$CustomerFromJson(json);

  //object to json
  Map<String,dynamic> toJson() =>  _$CustomerToJson(this);
}