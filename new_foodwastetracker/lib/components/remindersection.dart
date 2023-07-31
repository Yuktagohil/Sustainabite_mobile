import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodwastetracker/components/navbar.dart';
import 'package:foodwastetracker/components/shoplist.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderSection extends StatefulWidget {
  @override
  _ReminderSectionState createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> products = [];
  List<Product> selectedProducts = [];
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  void getProducts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot =
        await _firestore.collection('users/$userId/product').get();
    products = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return Product.fromMap(data);
      }
    }).where((product) => product != null).cast<Product>().toList();
    setState(() {});
  }

  void saveSelectedProducts(List<Product> selectedProducts) {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference checkedProductCollection =
      FirebaseFirestore.instance.collection('users/$userId/checkedproduct');
  for (var product in selectedProducts) {
    DateTime now = DateTime.now();
    String currentMonth = "${now.year}-${now.month}"; // Format the current month as "year-month"
    checkedProductCollection.doc().set({
      'name': product.name,
      'month': currentMonth,
    });
  }
}


  @override
  Widget build(BuildContext context) {
    var goingToExpireProducts = products.where((product) {
      var expirationDate = product.expirationDate;
      var reminderDate = expirationDate?.subtract(Duration(days: product.reminder));
      return currentDate.compareTo(reminderDate ?? DateTime.now()) >= 0 &&
          currentDate.compareTo(expirationDate ?? DateTime.now()) <= 0;
    }).toList();

    var expiredProducts = products.where((product) {
      var expirationDate = product.expirationDate;
      return currentDate.compareTo(expirationDate ?? DateTime.now()) > 0;
    }).toList();
    
    return BasePage(
      child: ListView(
        children: <Widget>[
          Text('Going to Expire'),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Product Name'),
              ),
              DataColumn(
                label: Text('Location'),
              ),
              DataColumn(
                label: Text('Days Remaining'),
              ),
            ],
            rows: goingToExpireProducts.map((product) => DataRow(
              cells: <DataCell>[
                DataCell(Text(product.name)),
                DataCell(Text(product.location)),
                DataCell(Text(product.daysRemaining().toString())),
              ],
            )).toList(),
          ),
          Text('Expired'),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Product Name'),
              ),
              DataColumn(
                label: Text('Location'),
              ),
              DataColumn(
                label: Text('Buy Again'),
              ),
            ],
            rows: expiredProducts.map((product) => DataRow(
              cells: <DataCell>[
                DataCell(Text(product.name)),
                DataCell(Text(product.location)),
                DataCell(Checkbox(
                  value: product.isSelected,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        product.isSelected = value;
                        if (value) {
                          selectedProducts.add(product);
                        } else {
                          selectedProducts.remove(product);
                        }
                      });
                    }
                  },
                )),
              ],
            )).toList(),
          ),
          Center(
        child: SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: selectedProducts.isNotEmpty
                ? () {
                    saveSelectedProducts(selectedProducts);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopList(),
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.add),
            label: Text('Add Selected'),
            style: ButtonStyle(
              // Customize button style as needed
              // For example:
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ),
        ),
      ),


        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String location;
  final DateTime? expirationDate; // make this field nullable
  final int reminder;
  bool isSelected = false; // add this line

  Product({
    required this.name,
    required this.location,
    required this.expirationDate,
    required this.reminder,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    var reminderString = data['reminder'] as String;
    var reminder = int.tryParse(reminderString.split(" ")[0]) ?? 0;
    Timestamp? timestamp = data['expirationDate'];
    DateTime? expirationDate = timestamp != null ? timestamp.toDate() : null;

    return Product(
      name: data['name'],
      location: data['location'],
      expirationDate: expirationDate,
      reminder: reminder,
    );
  }

  // Add these methods
  int daysRemaining() {
    if (expirationDate != null) {
      return expirationDate!.difference(DateTime.now()).inDays;
    }
    return 0; // or any other value you see fit
  }

  
}
