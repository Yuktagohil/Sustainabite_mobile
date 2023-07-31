import 'package:flutter/material.dart';
import './foodlist.dart'; // Import the FoodListPage
import './remindersection.dart'; // Import the ReminderSection
import './shoplist.dart'; // Import the ShopList
import 'package:firebase_auth/firebase_auth.dart';
import './signup.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  BasePage({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SustainaBite'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('SustainaBite'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Food List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodListPage()),
                );
              },
            ),
            ListTile(
              title: Text('Reminder'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderSection()),
                );
              },
            ),
            ListTile(
              title: Text('Shop List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopList()),
                );
              },
            ),
            GestureDetector(
              onTap: () async {
                  print('Sign out tapped.'); // Add this line to check if the onTap callback is executed.
                  try {
                    await FirebaseAuth.instance.signOut();
                    
                  } catch (e) {
                    print('Error signing out: $e');
                  }
                },

              child: ListTile(
                title: Text('Sign out'),
              ),
            )


          ],
        ),
      ),
      body: child,
    );
  }
}
