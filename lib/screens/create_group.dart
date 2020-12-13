import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:math';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isSuperAdmin = false;
  bool isChecked = false;
  int adedIndex = 0;
  String abbvr = 'MN';
  String colorGen = '0123456789ABCDEF';
  String groupID = '';
  String colors = '';
  List tempMembers = [];
  List userjoinedGroups = [];
  String superAdmin = '';
  Future<String> createGroup() async {
    superAdmin = auth.currentUser.uid;
    abbvr = groupNameController.text.substring(0, 3).toUpperCase();
    //
    Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    String result = "";

    for (var i = 0; i < 6; i++) {
      result += colorGen[rnd.nextInt(colorGen.length)];
    }
    colors = result;
    print(colors);
    print(abbvr);

    var createdGroup = await db.collection("groups").add({
      "name": groupNameController.text,
      "color": colors,
      "members": tempMembers,
      "abbreviation": abbvr,
    });
    var createdGroupSnapshot = await createdGroup.get();
    var value = createdGroupSnapshot;
    var groupID = value.id;
    //adds group id
    print("this is grp id ==> $groupID");

    print('created group $createdGroup');
    if (!tempMembers.contains(superAdmin)) {
      tempMembers.add(superAdmin);
    } else {
      return groupID;
    }

    return groupID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name of Group',
                ),
              ),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Users'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tempMembers.clear();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.close),
                            Text('Clear Selection'),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Added Users (${tempMembers.length})'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection("users").snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  final int eventCount = snapshot.data.docs.length;
                  if (snapshot.data == null) {
                    return CircularProgressIndicator();
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      // index = index;

                      var userID = snapshot.data.docs[index].id;

                      isSuperAdmin =
                          snapshot.data.docs[index].get("superadmin");
                      return (isSuperAdmin)
                          ? Container()
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: (tempMembers.contains(userID))
                                      ? Colors.green.withOpacity(0.18)
                                      : Colors.white),
                              child: CheckboxListTile(
                                title: Text(
                                  snapshot.data.docs[index].get("name"),
                                ),
                                value: (tempMembers.contains(userID)),
                                onChanged: (val) async {
                                  if (val) {
                                    if (!tempMembers.contains(userID)) {
                                      //sends group id(this gets run first)
                                      //  addUserToGroup(userID);
                                      setState(() {
                                        print("group ID here $groupID");
                                        tempMembers.add(userID);
                                      });
                                    }
                                  } else {
                                    //remove
                                    if (tempMembers.contains(userID)) {
                                      setState(() {
                                        tempMembers.removeWhere(
                                            (element) => element == userID);
                                      });
                                    }
                                  }
                                  setState(() {
                                    print("aded user ==> $userID");
                                    print("current user ==> $superAdmin");
                                    print("list of added users $tempMembers");
                                  });
                                },
                              ),
                            );
                    },
                    itemCount: eventCount,
                  );
                },
              ),
            ),
            (tempMembers.length == 0 || groupNameController.text.length < 4)
                ? MaterialButton(
                    onPressed: null,
                    disabledElevation: 0,
                    disabledColor: Colors.grey,
                    color: Colors.blue,
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : MaterialButton(
                    disabledColor: Colors.grey,
                    color: Colors.blue,
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      createGroup().then(
                        (value) {
                          print(' this returned $value');
                          var doc = value;
                          for (var item in tempMembers) {
                            print(item);
                            db.collection("users").doc(item).update({
                              "joinedGroups": FieldValue.arrayUnion([value]),
                            });
                            // DocumentReference reference = Firestore.instance
                            //     .collection('users')
                            //     .document('uid')
                            //     .collection('order')
                            //     .document();
                            // reference.setData({
                            //   'name': name,
                            //   'description': description,
                            //   'price': price,
                            //   'image': uploadFileURL,
                            // });
                          }
                          DocumentReference ref =
                              db.collection("groups").doc(doc);
                          ref
                              .collection("channels")
                              .doc()
                              .set({"name": "Messages"});
                          //create a collection for channel (chat)

                          setState(() {
                            groupNameController.clear();
                            tempMembers.clear();
                          });
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
