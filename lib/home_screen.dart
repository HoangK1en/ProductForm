import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  CollectionReference products =
      FirebaseFirestore.instance.collection('product');

     void _addProduct() {
         products.add({
          'Name': _nameController.text,
          'Category': _categoryController.text,
          'Price': _priceController.text,
        });
        _nameController.clear();
        _categoryController.clear();
        _priceController.clear();
     }

  void _deleteProduct(String productId) {
    products.doc(productId).delete();
  }

  void _editProduct(DocumentSnapshot product) {
    _nameController.text = product['Name'];
    _categoryController.text = product['Category'];
    _priceController.text = product['Price'];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit product'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    _updateProduct(product.id);
                  },
                  child: const Text('Update')),
            ],
          );
        });
  }

  void _updateProduct(String productId) {
    products.doc(productId).update({
      'Name': _nameController.text,
      'Category': _categoryController.text,
      'Price': _priceController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DANH SÁCH SẢN PHẨM"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _addProduct();
                },
                child: const Text("Thêm sản phẩm"),
              ),
              const SizedBox(height: 16),
              Expanded(
                  child: StreamBuilder(
                stream: products.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
        
                  return ListView.builder(
                    
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var product = snapshot.data!.docs[index];
                      return Dismissible(
                        key: Key(product.id),
                        background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            )),
                        onDismissed: (direction) {
                          _deleteProduct(product.id);
                        },
                        direction: DismissDirection.endToStart,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),                 
                          child: ListTile(
                            title: Text('Tên sp: ${product['Name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Loại sp: ${product['Category']}'),
                                Text('Giá sp: ${product['Price']}'),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _editProduct(product);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
            ],
          )),
    );
  }
}

extension on Object {
  get docs => null;
}
