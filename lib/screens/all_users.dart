import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhis_chat_admin/screens/update_user.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final db = FirebaseFirestore.instance;
  bool isSuperAdmin = false;
  // final userRef = db.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('All NHIS Members'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: db.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              final int eventCount = snapshot.data.docs.length;
              // isSuperAdmin = snapshot.data.docs.single.get("superadmin");

              if (snapshot == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  isSuperAdmin = snapshot.data.docs[index].get("superadmin");
                  return (isSuperAdmin)
                      ? Container()
                      : ListTile(
                          onTap: () async {
                            var userID = snapshot.data.docs[index].id;
                            print(userID);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UpdateUser(
                                      userId: userID,
                                    )));
                          },
                          title:
                              Text('${snapshot.data.docs[index].get("name")}'),
                          trailing: Text((snapshot.data.docs[index]
                                      .get("admin") !=
                                  null)
                              ? 'admin: ${snapshot.data.docs[index].get("admin")}'
                              : ''),
                          subtitle: Text(
                              'Document ID: ${snapshot.data.docs[index].get("documentID")}'),
                        );
                },
                itemCount: eventCount,
              );
            }));
  }
}
