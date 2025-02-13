// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      customerId: (json['customerId'] as num).toInt(),
      orderTotal: (json['orderTotal'] as num).toDouble(),
      orderPaymentMethod: json['orderPaymentMethod'] as String,
      orderStatus: json['orderStatus'] as String,
      orderNote: json['orderNote'] as String,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'orderTotal': instance.orderTotal,
      'orderPaymentMethod': instance.orderPaymentMethod,
      'orderStatus': instance.orderStatus,
      'orderNote': instance.orderNote,
    };
