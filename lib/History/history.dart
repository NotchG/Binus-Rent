import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  final User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? _historyStream;

  @override
  void initState() {
    super.initState();
    setState(() {
      _historyStream = FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("history").orderBy('time', descending: true).limit(10).snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2E9BFF),
                      Color(0xff3E00C1),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.1, 1],
                  )
              ),
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  ProfilePicture(
                    name: "${user!.displayName}",
                    radius: 35,
                    fontsize: 22,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[350],
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(
                        "${user?.displayName}",
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20,bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: (_historyStream != null) ? StreamBuilder<QuerySnapshot>(
                      stream: _historyStream!,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            "Something Went Wrong",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            "Loading...",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87
                            ),
                          );
                        }

                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((e) {
                            Map<String, dynamic> data = e.data()! as Map<String, dynamic>;
                            DateTime date = (data["time"] as Timestamp).toDate();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"]
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  DateFormat.yMEd().add_jms().format(date),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            );
                          }).toList().cast(),
                        );
                      },
                    ) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
