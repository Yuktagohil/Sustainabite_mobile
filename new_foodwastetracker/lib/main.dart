import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './components/foodlist.dart';
import './components/remindersection.dart';
import './components/shoplist.dart';
import './components/navbar.dart'; // Create Navbar widget in separate file
import './components/signup.dart'; // Create Signup widget in separate file
import './components/signin.dart'; // Create Signin widget in separate file
import 'package:shared_preferences/shared_preferences.dart'; // Import the shared_preferences package
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}
final GlobalKey<_AppState> appStateKey = GlobalKey<_AppState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
  App() : super(key: appStateKey);
}

class _AppState extends State<App> {
  String? user;

  void handleSignup(String username, String password) {
    // Implement signup logic here if needed
    // For this example, we'll just navigate to the FoodListPage
    setState(() {
      user = username;
    });
  }

  Future<void> handleSignin(String email, String password) async {
    // Your sign in logic here...
    setState(() {
      user = email;
    });
  }

  Future<void> handleLogout() async {
  // Your logout logic here...
  setState(() {
    user = null;
  });

  // Navigate to the signup screen after logging out
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup(onSignup: handleSignup, handleSigninModal: showSignInModal)));
}



  void showSignInModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Signin(onSignin: handleSignin),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // User is not logged in, show the signup page without a drawer
      return Scaffold(
        appBar: AppBar(
          title: Text('SustainaBite'),
        ),
        body: Signup(onSignup: handleSignup, handleSigninModal: showSignInModal),
      );
    } else {
      // User is logged in, show the home page with a drawer
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
              ListTile(
                title: Text('Sign out'),
                onTap: () async {
                  await handleLogout();
                  // Navigator.pushNamed(context, '/signup');
                },


              ),
            ],
          ),
        ),
        body: // Your logged-in app content here...
        FloatingActionButton(
          onPressed: () {
            // Implement the logic to add a product
            // ...
          },
          child: Icon(Icons.add),
        ),
      );
    }
  }
}
