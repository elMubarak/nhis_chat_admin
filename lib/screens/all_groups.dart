import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nhis_chat_admin/screens/update_group.dart';

class AllGroups extends StatefulWidget {
  @override
  _AllGroupsState createState() => _AllGroupsState();
}

class _AllGroupsState extends State<AllGroups> {
  final db = FirebaseFirestore.instance;
  String mainGroup = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Groups'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('groups').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          final int eventCount = snapshot.data.docs.length;
          if (snapshot == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  var groupId = snapshot.data.docs[index].id;

                  print(groupId);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UpdateGroup(
                            groupID: groupId,
                          )));
                },
                title: Text('${snapshot.data.docs[index].get("name")}'),
              );
            },
            itemCount: eventCount,
          );
        },
      ),
    );
  }
}
