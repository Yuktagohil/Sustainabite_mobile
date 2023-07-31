import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodwastetracker/components/navbar.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final DateTime? expirationDate = product['expirationDate'];
    final formattedExpirationDate =
        expirationDate != null ? expirationDate.toString().split(' ')[0] : 'No date set';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product['name']),
          Text('Location: ${product['location']}'),
          Text('Expiration Date: $formattedExpirationDate'),
        ],
      ),
    );
  }
}

class FoodListPage extends StatefulWidget {
  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<Map<String, dynamic>> products = [];
  String dropdownValue = 'Freezer'; // Default location
  String reminderValue = '3 days before'; // Default reminder
  DateTime selectedDate = DateTime.now();
  DateTime? selectedExpirationDate; // Initialize selectedExpirationDate to null
  TextEditingController productController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch and populate the products list when the page is initialized
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users/$userId/product')
          .get();

      setState(() {
        products = snapshot.docs.map((doc) {
          final expirationDate = doc['expirationDate'] as Timestamp?;
          final productData = doc.data();
          if (expirationDate != null) {
            productData['expirationDate'] = expirationDate.toDate();
          }
          return productData;
        }).toList();
      });
    }
  }

  void showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: productController,
                      decoration: InputDecoration(labelText: "Product name"),
                    ),
                    DropdownButtonFormField<String>(
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: "Location"),
                      items: <String>['Freezer', 'Fridge', 'Pantry', 'Medicine Box']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    // Expiration Date Picker Here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiration Date:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedExpirationDate = picked;
                              });
                            }
                          },
                          child: Text(
                            selectedExpirationDate != null
                                ? selectedExpirationDate.toString().split(' ')[0]
                                : 'Select Expiration date',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: reminderValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          reminderValue = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: "Set reminder"),
                      items: <String>['3 days before', '5 days before', 'Custom']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Adding to Firebase
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final userId = user.uid;
                  await FirebaseFirestore.instance
                      .collection('users/$userId/product')
                      .add({
                    'name': productController.text,
                    'location': dropdownValue,
                    'expirationDate': selectedExpirationDate != null ? Timestamp.fromDate(selectedExpirationDate!) : null,
                    'reminder': reminderValue,
                  });
                }

                // Update the products list and close the dialog
                setState(() {
                  products.add({
                    'name': productController.text,
                    'location': dropdownValue,
                    'expirationDate': selectedExpirationDate,
                    'reminder': reminderValue,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: BasePage(
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: showAddProductDialog,
      child: Icon(Icons.add),
    ),
  );
  }
}

void main() {
  runApp(MaterialApp(
    home: FoodListPage(),
  ));
}
