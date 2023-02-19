import 'package:chat_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helpers/helper_function.dart';

class Requests extends StatefulWidget {
  const Requests({Key? key}) : super(key: key);

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Member Requests",
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("members")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something is wrong"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, index) {
              DocumentSnapshot _documentSnapshot = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5,),
                            Text(
                              ' ${_documentSnapshot["name"]}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              ' wants to join \n ${_documentSnapshot["groupName"]}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10.0, right: 15.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 5,
                            color: Colors.green,
                            child: GestureDetector(
                              onTap: ()async{

                                String groupId = "${_documentSnapshot["grooupId"]}";
                                String groupName = "${_documentSnapshot["groupName"]}";
                                String uid = "${_documentSnapshot["userId"]}";
                                String userName = "${_documentSnapshot["name"]}";

                                await FirebaseFirestore.instance.collection("users").doc(_documentSnapshot["userId"]).update({
                                  "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
                                });
                                await FirebaseFirestore.instance.collection("groups").doc(_documentSnapshot["groupId"]).update({
                                  "members": FieldValue.arrayUnion(["${uid}_$userName"])
                                });

                                await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                                  await myTransaction.delete(snapshot.data!.docs[index].reference);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 5,
                            color: Colors.red,
                            child: GestureDetector(
                              onTap: () async {
                                await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                                  await myTransaction.delete(snapshot.data!.docs[index].reference);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Decline',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
