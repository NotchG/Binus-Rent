import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:go_router/go_router.dart';
import 'package:rentapp/ColorPalette.dart';
import 'package:rentapp/home/components/Item.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../Classes/BorrowItemClass.dart';

// HOMEPAGE HOUSING CATALOG AND BORROWED ITEM

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final User? user = FirebaseAuth.instance.currentUser;

  final Stream<QuerySnapshot> _itemStream = FirebaseFirestore.instance.collection("items").snapshots();

  PanelController panelController = PanelController();

  BorrowItemClass returnBorrowItem = BorrowItemClass.empty();

  BorrowItemClass currBorrowItem = BorrowItemClass.empty();

  void triggerPanel() {
    if (panelController.isPanelClosed) {
      panelController.open();
    } else {
      panelController.close();
    }
  }

  @override
  void initState() {
    EasyLoading.show(status: "Loading...");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(FirebaseAuth.instance.currentUser == null) {
        context.pushReplacement("/");
      } else {
        final items = FirebaseFirestore.instance.collection("items");
        final query = items.where("currBorrow", isEqualTo: user!.uid);
        query.get().then((value) {
          if (value.size != 0) {
            var doc = value.docs.first;
            setState(() {
              returnBorrowItem = BorrowItemClass(name: doc["name"], imgUrl: doc["imgUrl"], available: doc["available"], uid: doc.id);
            });
          }
          EasyLoading.dismiss();
        }).onError((error, stackTrace) {
          EasyLoading.showError(error.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      body: SlidingUpPanel(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        backdropOpacity: 0.7,
        backdropEnabled: true,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        minHeight: 0,
        controller: panelController,
        panel: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    color: const Color(0xff0066C5),
                    width: 30,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff2f3552),
                    image: DecorationImage(
                      image: NetworkImage(currBorrowItem.imgUrl),
                      fit: BoxFit.cover,
                    )
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      currBorrowItem.name,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currBorrowItem.available ? Colors.green : Colors.red
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          currBorrowItem.available ? "Available" : "Unavailable",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: currBorrowItem.available && returnBorrowItem.uid == "" ? () {
                        context.push('/camera', extra: {"item": currBorrowItem, "borrow": true});
                      } : null,
                      style: ButtonStyle(
                          backgroundColor: currBorrowItem.available && returnBorrowItem.uid == "" ? MaterialStateProperty.all(const Color(0xff0066C5)) : MaterialStateProperty.all(const Color(0xff0066C5).withOpacity(0.5)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ))
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: Text("Borrow"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        onPanelClosed: () {
          currBorrowItem = BorrowItemClass.empty();
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPalette.accentColor,
                        ColorPalette.mainColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                              fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis
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
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (returnBorrowItem.name != "") Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Borrowed Item",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          height: 300,
                          width: min(500, MediaQuery.of(context).size.width),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ColorPalette.mainColor,
                              image: DecorationImage(
                                image: NetworkImage(returnBorrowItem.imgUrl),
                                fit: BoxFit.cover,
                              )
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                        begin: FractionalOffset.topCenter,
                                        end: FractionalOffset.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.5),
                                        ],
                                        stops: const [
                                          0.0,
                                          1.0
                                        ])),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          returnBorrowItem.name,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.push('/camera', extra: {"item": returnBorrowItem, "borrow": false});
                                          },
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(ColorPalette.accentColor),
                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20)
                                              ))
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                            child: Text("Return"),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                    const Text(
                      "Catalog",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _itemStream,
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
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data!.docs.map((e) {
                              Map<String, dynamic> data = e.data()! as Map<String, dynamic>;
                              BorrowItemClass item = BorrowItemClass(name: data["name"], imgUrl: data["imgUrl"], available: data["available"], uid: e.id,);
                              return BorrowItem(
                                  item: item,
                                  openPanel: () {
                                    setState(() {
                                      currBorrowItem = item;
                                    });
                                    triggerPanel();
                                  }
                              );
                            }).toList().cast(),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 1/6,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
