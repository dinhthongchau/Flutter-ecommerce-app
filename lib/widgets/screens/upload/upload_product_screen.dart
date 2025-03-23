
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/common_widgets/bottom_navigation_bar.dart';
import 'package:project_one/widgets/screens/upload/upload_product_cubit.dart';

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
          SnackBar(content: Text("Please select at least one image")),
        );
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
        title: Text("Upload Product"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ProductUploadCubit, ProductUploadState>(
          listener: (context, state) {
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
              if (state is ProductUploadSuccess) {
                Navigator.pop(context);
              }
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Product Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _productName = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Product Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (int.tryParse(value) == null) return 'Must be a valid number';
                        return null;
                      },
                      onSaved: (value) {
                        _productPrice = int.tryParse(value!) ?? 0; // Default to 0 if invalid
                        print("Parsed productPrice: $_productPrice"); // Debug log
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Product Color'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _productColor = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Product Description'),
                      onSaved: (value) => _productDescription = value ?? '',
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: Text('Pick Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    Text('Selected images: ${_imageFiles.length}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: state is ProductUploadLoading ? null : _submit,
                      child: state is ProductUploadLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                          : Text('Upload Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
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