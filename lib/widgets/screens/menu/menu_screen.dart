// lib/widgets/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/repositories/api_server.dart';
import 'package:project_one/widgets/common_widgets/bold_text.dart';
import 'package:project_one/widgets/screens/menu/upload_product_cubit.dart';
import 'package:project_one/widgets/screens/settings/settings_screen.dart';

import '../../../common/enum/load_status.dart';

class MenuScreen extends StatelessWidget {
  static const String route = "MenuScreen";

  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Center(child: CustomBoldText(text: "Menu")),
          ),
          ListTile(
            tileColor: Colors.deepOrangeAccent,
            title: Row(
              children: const [Text("Settings"), Icon(Icons.settings)],
            ),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.route);
            },
          ),
          ListTile(
            tileColor: Colors.blueAccent,
            title: Row(
              children: const [Text("Upload Product"), Icon(Icons.upload)],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ProductUploadCubit>(),
                    child: UploadProductScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UploadProductScreen extends StatefulWidget {
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

  // Chọn file từ thiết bị
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

  // Gửi dữ liệu lên server
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
                Navigator.pop(context); // Quay lại sau khi upload thành công
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
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _productPrice = int.parse(value!),
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