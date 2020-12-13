import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nhis_chat_admin/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final db = FirebaseFirestore.instance;
  bool isSuperAdmin = false;

  logInAdmin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        DocumentSnapshot userCheker =
            await db.collection("users").doc(userCredential.user.uid).get();
        var userInfo = userCheker.data();
        isSuperAdmin = userInfo["superadmin"];
        print(isSuperAdmin);
        if (isSuperAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (
                context,
              ) =>
                  DashBoard(),
            ),
          );
        } else {
          print('not super admin');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('Welcome'),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                ),
                SizedBox(height: 15),
                MaterialButton(
                  child: Text('Login'),
                  onPressed: () {
                    logInAdmin();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
