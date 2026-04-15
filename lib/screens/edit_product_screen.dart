import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditProductScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.data['title']);

    priceController =
        TextEditingController(text: widget.data['price'].toString());

    descController =
        TextEditingController(text: widget.data['description']);
  }

  Future<void> updateProduct() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.docId)
        .update({
      'title': titleController.text,
      'price': double.parse(priceController.text),
      'description': descController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ), //  IMPORTANT COMMA HERE

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateProduct,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}