import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';
@JsonSerializable()
class ProductModel{

  final int product_id;
  final String product_name;
  final int product_price;
  final String product_color;
  final String product_description;
  final List<String> product_image;


  ProductModel({
    required this.product_id,
    required this.product_name,
    required this.product_price,
    required this.product_color,
    required this.product_description,
    required this.product_image,
  });

  //json to object
  factory ProductModel.fromJson(Map<String,dynamic> json) => _$ProductModelFromJson(json);

  //object to json
  Map<String,dynamic> toJson() =>  _$ProductModelToJson(this);

  // Override toString() để hiển thị dữ liệu chi tiết hơn khi debug
  @override
  String toString() {
    return 'ProductModel{id: $product_id, name: $product_name, price: $product_price, color: $product_color}';
  }


}