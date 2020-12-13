import 'package:flutter/material.dart';
import 'package:nhis_chat_admin/screens/all_groups.dart';
import 'package:nhis_chat_admin/screens/create_group.dart';
import 'package:nhis_chat_admin/screens/create_users_screen.dart';
import 'package:nhis_chat_admin/screens/all_users.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome SUPER ADMIN',
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateUsers(),
                      ),
                    );
                  },
                  child: Text('Create User'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AllUsers()));
                  },
                  child: Text('NHIS Users'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateGroupScreen(),
                      ),
                    );
                  },
                  child: Text('Create Group'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AllGroups(),
                      ),
                    );
                  },
                  child: Text('NHIS Groups'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
