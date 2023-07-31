import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodwastetracker/components/foodlist.dart'; // Replace this with the correct import for your FoodList page

class Signup extends StatefulWidget {
  static const routeName = '/signup';
  final Function(String, String) onSignup;
  final VoidCallback handleSigninModal;

  Signup({required this.onSignup, required this.handleSigninModal});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String username = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  void handleUsernameChange(String value) {
    setState(() {
      username = value;
    });
  }

  void handlePasswordChange(String value) {
    setState(() {
      password = value;
    });
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Create a new user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: username,
          password: password,
        );

        // User signed up successfully
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success', style: TextStyle(color: Colors.green)),
              content: Text('Sign up successful!', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              actions: <Widget>[
                TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodListPage()), // Replace YourFoodListPage with your FoodList page class
                    );
                  },
                ),
              ],
            );
          },
        );

      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The account already exists for that email.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The email address is not valid.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign up.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.924, // Specify a fixed height here
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1494859802809-d069c3b71a8a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            child: Card(
              borderOnForeground: false,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Signup',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Username'),
                        onChanged: handleUsernameChange,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email.';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Password'),
                        onChanged: handlePasswordChange,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          } else if (value.length < 6) {
                            return 'Password should be at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text('Signup'),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: widget.handleSigninModal,
                        child: Text('Already have an account? Signin'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
