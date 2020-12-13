import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUser extends StatefulWidget {
  UpdateUser({this.userId});
  final userId;
  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  bool isSuperAdmin = false;
  final db = FirebaseFirestore.instance;
  List groupNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Info'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: db.collection('users').doc('${widget.userId}').snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              isSuperAdmin = snapshot.data.get("superadmin");
              if (snapshot == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      '${snapshot.data.get("name")}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text('is an admin : ${snapshot.data.get("admin")}'),
                    Flexible(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          var groupID =
                              snapshot.data.get("joinedGroups")[index];
                          print(groupID);
                          var groupIdFromJoinedGroups =
                              db.collection("groups").doc(groupID);
                          // print(groupMembersNamesFromID);
                          var stream = groupIdFromJoinedGroups
                              .snapshots()
                              .asBroadcastStream();
                          stream.forEach(
                            (element) async {
                              var loopGroupName = await element.get("name");
                              if (!groupNames.contains(loopGroupName)) {
                                setState(() {
                                  groupNames.add(loopGroupName);
                                });
                              }
                              // memberNames = loopGroupName;
                              print(element.get("name"));
                              return loopGroupName;
                            },
                          );

                          return ListTile(
                            title: Text('${groupNames[index]}'),
                          );
                        },
                        itemCount: snapshot.data.get("joinedGroups").length,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Column(
                          children: [
                            (isSuperAdmin)
                                ? Container()
                                : Row(
                                    children: [
                                      Text('Not Admin'),
                                      Switch(
                                        value: snapshot.data.get("admin"),
                                        onChanged: (val) {
                                          snapshot.data.reference
                                              .update({"admin": val});
                                        },
                                      ),
                                      Text('Admin'),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                    // IconButton(
                    //     icon: Icon(
                    //       Icons.delete,
                    //     ),
                    //     onPressed: () async {
                    //       User user;
                    //       FirebaseAuth firebaseAuth;
                    //       firebaseAuth;

                    //       snapshot.data.reference
                    //           .delete()
                    //           .then((value) => Navigator.of(context).pop());
                    //     }),
                  ],
                ),
              );
            }));
  }
}
