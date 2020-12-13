import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:nhis_chat_admin/data/firebase_doc_path.dart';

class CreateUsers extends StatefulWidget {
  @override
  _CreateUsersState createState() => _CreateUsersState();
}

class _CreateUsersState extends State<CreateUsers> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController documentID = TextEditingController();
  TextEditingController departmentGroupController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final databaseReference = FirebaseFirestore.instance;
  String userDocumentID = "";

  bool isAdmin = false;
  registerUser() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      //if user created sucessfully
      if (userCredential != null) {
        //prepare data to be saved
        //for user reference by id set
        final docRef = databaseReference
            .doc(FirestorePaths.userPath(userCredential.user.uid));
        //for main group reference by id add
        final groupRef = databaseReference
            .doc(FirestorePaths.groupPath("U8WPYAC7FI9ccll1RZIA"));
        //setting user data
        userDocumentID = "NHIS/${documentID.text}/PF";
        await docRef.set({
          "email": emailController.text,
          "name": userCredential.user.email,
          "joinedGroups": ['U8WPYAC7FI9ccll1RZIA'],
          "documentID": userDocumentID,
          "locale": 'en',
          "admin": isAdmin,
          "disabled": false,
          "superadmin": false,
          "uid": userCredential.user.uid,
          "token": userCredential.user.refreshToken,
        });
        //ading user to group
        await groupRef.update({
          "members": FieldValue.arrayUnion([userCredential.user.uid]),
        });
        //send mail
        String username = 'superuser.nhis@gmail.com';
        String password = 'admin300';
        var options = new GmailSmtpOptions()
          ..username = username
          ..password = password;

        var emailTransport = new SmtpTransport(options);

        var envelope = new Envelope()
          ..from = 'superuser.nhis@gmail.com'
          ..recipients.add('${emailController.text}')
          // ..bccRecipients.add('hidden@recipient.com')
          ..subject = 'NHIS user Created Account'
          // ..attachments.add(new Attachment(file: new File('path/to/file')))
          ..text = ''
          ..html = '''<p>Hello, this is from the admin office,
               your NHIS chat account has been created </p>
              <p> Your document id <h1> $userDocumentID </h1> 
              and password is ${passwordController.text} <br> kindly login and change your password''';

        // Email it.
        emailTransport
            .send(envelope)
            .then((envelope) => print('Email sent!'))
            .catchError((e) => print('Error occurred: $e'));
      }
      emailController.clear();
      documentID.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      // Navigator.of(context).pop();
      // showSnackbar(message: '${e.message}');
      print(e.message);
      // showSnackbar(message: e.message);

      if (e.code == 'weak-password') {
        // showSnackbar(message: _errorMessage.passwordWeak);
        // print(_errorMessage.passwordWeak);
      } else if (e.code == 'email-already-in-use') {
        // showSnackbar(message: _errorMessage.emailInUse);
        // print(_errorMessage.emailInUse);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Create NHIS user'),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: documentID,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    hintText: 'Document ID',
                    helperText: (documentID.text.isEmpty)
                        ? ''
                        : 'NHIS/${documentID.text}/PF',
                  ),
                  onChanged: (val) {
                    if (val.length >= 0) {
                      setState(() {});
                    }
                  },
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
                  child: Text('Create User'),
                  onPressed: () {
                    registerUser();
                  },
                ),
                SizedBox(height: 15),
                Text('Make Admin'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not Admin'),
                    Switch(
                      value: isAdmin,
                      onChanged: (val) {
                        setState(() {
                          isAdmin = val;
                          print(isAdmin);
                        });
                      },
                    ),
                    Text('Admin'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
