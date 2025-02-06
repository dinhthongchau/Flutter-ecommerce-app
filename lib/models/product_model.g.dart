// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      product_id: (json['product_id'] as num).toInt(),
      product_name: json['product_name'] as String,
      product_price: (json['product_price'] as num).toInt(),
      product_color: json['product_color'] as String,
      product_description: json['product_description'] as String,
      product_image: (json['product_image'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'product_id': instance.product_id,
      'product_name': instance.product_name,
      'product_price': instance.product_price,
      'product_color': instance.product_color,
      'product_description': instance.product_description,
      'product_image': instance.product_image,
    };
