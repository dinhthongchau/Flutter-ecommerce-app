import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/common_widgets/bottom_navigation_bar.dart';
import 'package:project_one/widgets/screens/list_products/list_products_screen.dart';
import 'package:project_one/widgets/screens/upload/upload_product_cubit.dart';

import '../../common_widgets/custom_gradient_appbar.dart';
import '../../common_widgets/notice_snackbar.dart';

class UploadProductScreen extends StatefulWidget {
  static const String route = "UploadProductScreen";

  const UploadProductScreen({super.key});

  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  int _productPrice = 0;
  String _productColor = '';
  String _productDescription = '';
  List<PlatformFile> _imageFiles = [];

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageFiles = result.files;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_imageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            noticeSnackbar("Please select at least one image ", true));
        return;
      }

      context.read<ProductUploadCubit>().uploadProduct(
            productName: _productName,
            productPrice: _productPrice,
            productColor: _productColor,
            productDescription: _productDescription,
            imageFiles: _imageFiles,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        title: CustomGradientAppBar(title: "Upload Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ProductUploadCubit, ProductUploadState>(
          listener: (context, state) {
            if (state.message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(noticeSnackbar(state.message!, false));
              if (state is ProductUploadSuccess) {
                Navigator.of(context).pushNamed(ListProductsScreen.route);
              }
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Sửa: Thêm màu nền và bo góc cho TextFormField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _productName = value!,
                    ),
                    const SizedBox(height: 16), // Thêm khoảng cách
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Product Price',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (int.tryParse(value) == null)
                          return 'Must be a valid number';
                        return null;
                      },
                      onSaved: (value) {
                        _productPrice = int.tryParse(value!) ?? 0;
                        print("Parsed productPrice: $_productPrice");
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Product Color',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _productColor = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Product Description',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSaved: (value) => _productDescription = value ?? '',
                    ),
                    const SizedBox(height: 24), // Tăng khoảng cách
                    // Sửa: Cải thiện nút "Chọn ảnh"
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Chọn ảnh', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.image_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selected images: ${_imageFiles.length}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    // Sửa: Làm nút Upload nổi bật hơn
                    Container(
                      width: double.infinity, // Full width
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(0.1), // Màu nền nhẹ để nổi bật
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed:
                            state is ProductUploadLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 5, // Thêm shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state is ProductUploadLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Upload',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.upload,
                                      color: Colors.white, size: 24),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16), // Khoảng trống cuối
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
