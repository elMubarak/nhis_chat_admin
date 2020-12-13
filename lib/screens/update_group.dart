import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateGroup extends StatefulWidget {
  UpdateGroup({this.groupID});
  final String groupID;
  @override
  _UpdateGroupState createState() => _UpdateGroupState();
}

class _UpdateGroupState extends State<UpdateGroup> {
  final db = FirebaseFirestore.instance;
  List memberNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group info'),
      ),
      body: StreamBuilder(
          stream: db.collection('groups').doc('${widget.groupID}').snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '${snapshot.data.get("name")}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Text('Members'),
                  Flexible(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var groupMenbersID =
                            snapshot.data.get("members")[index];
                        print(groupMenbersID);
                        var groupMembersNamesFromID =
                            db.collection("users").doc(groupMenbersID);
                        // print(groupMembersNamesFromID);
                        var stream = groupMembersNamesFromID
                            .snapshots()
                            .asBroadcastStream();
                        stream.forEach(
                          (element) async {
                            var loopGroupName = await element.get("name");
                            if (!memberNames.contains(loopGroupName)) {
                              setState(() {
                                memberNames.add(loopGroupName);
                              });
                            }
                            // memberNames = loopGroupName;
                            print(element.get("name"));
                            return loopGroupName;
                          },
                        );
                        return ListTile(
                          title: Text('${memberNames[index]}'),
                        );
                      },
                      itemCount: snapshot.data.get("members").length,
                    ),
                  ),
                  //     mainGroup = snapshot.data.docs[index].get("name");
                  // (mainGroup == 'Main')
                  Center(
                    child: IconButton(
                        color: Colors.red,
                        icon: Icon(
                          Icons.delete,
                        ),
                        onPressed: () async {
                          snapshot.data.reference
                              .delete()
                              .then((value) => Navigator.of(context).pop());
                        }),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
