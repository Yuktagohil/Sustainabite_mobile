import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodwastetracker/components/navbar.dart';


class Product {
  String name;
  String month;

  Product({
    required this.name,
    required this.month,
  });
}

class ShopList extends StatefulWidget {
  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  List<Product> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    getSelectedProducts();
  }

  String getMonthName(int? month) {
  if (month == null || month < 1 || month > 12) {
    return 'Invalid Month';
  }

  List<String> monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  return monthNames[month - 1];
}


int? extractMonth(String date) {
  try {
    List<String> parts = date.split('-');
    if (parts.length == 2) {
      int year = int.tryParse(parts[0]) ?? 0; 
      int month = int.tryParse(parts[1]) ?? 1; 
      print('Year: $year, Month: $month');  // Add logging here

      if (year >= 0 && month >= 1 && month <= 12) {
        return month;
      }
    }
    throw FormatException('Invalid date format: $date');  // Include the input date in the exception
  } catch (e) {
    print('Error extracting month: $e');
    return null;
  }
}




  void getSelectedProducts() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference checkedProductCollection = FirebaseFirestore.instance.collection('users/$userId/checkedproduct');
  QuerySnapshot querySnapshot = await checkedProductCollection.get();
  List<Product> productList = [];

   for (var doc in querySnapshot.docs) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      String name = data['name'] ?? '';
      String? date = data['date'] ?? '';
      if (date == null || date.isEmpty) {
        DateTime now = DateTime.now();
        date = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        print('Using current date as default: $date');
      }
      int? month = extractMonth(date);
      String monthName = getMonthName(month);
      Product product = Product(
        name: name,
        month: monthName,
      );
      productList.add(product);
    }
  }
  setState(() {
    selectedProducts = productList;
  });
}




 @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shop List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DataTable(
                columns: [
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Month')),
                ],
                rows: selectedProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(Text(product.name)),
                    DataCell(Text(product.month)),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}