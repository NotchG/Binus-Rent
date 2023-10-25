import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rentapp/ColorPalette.dart';
import 'package:rentapp/home/components/Item.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

import '../Classes/BorrowItemClass.dart';

// HOMEPAGE HOUSING CATALOG AND BORROWED ITEM

class Home extends StatefulWidget {
  final Map<String, dynamic> location;
  const Home({super.key, required this.location});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final User? user = FirebaseAuth.instance.currentUser;

  final Stream<QuerySnapshot> _itemStream = FirebaseFirestore.instance.collection("items").snapshots();

  PanelController panelController = PanelController();

  BorrowItemClass returnBorrowItem = BorrowItemClass.empty();

  BorrowItemClass currBorrowItem = BorrowItemClass.empty();

  String notes = "";

  DateTime pickedTime = DateTime.now();

  int pickedMinute = 30;

  void triggerPanel() {
    if (panelController.isPanelClosed) {
      panelController.open();
    } else {
      panelController.close();
    }
  }

  double calculateDistance(double lat1, double long1, double lat2, double long2) {
    double earthRadius = 6371000;
    double dLat = radians(lat2 - lat1);
    double dLong = radians(long2 - long1);
    double a = sin(dLat/2) * sin(dLat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLong/2) * sin(dLong/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadius * c;
  }

  @override
  void initState() {
    EasyLoading.show(status: "Loading...");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
        final items = FirebaseFirestore.instance.collection("items");
        final query = items.where("currBorrow", isEqualTo: user!.uid);
        query.get().then((value) {
          if (value.size != 0) {
            var doc = value.docs.first;
            setState(() {
              returnBorrowItem = BorrowItemClass(name: doc["name"], imgUrl: doc["imgUrl"], available: doc["available"], uid: doc.id, borrowUntil: (doc["borrowUntil"] as Timestamp).toDate());
            });
          }
          EasyLoading.dismiss();
        }).onError((error, stackTrace) {
          EasyLoading.showError(error.toString());
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      body: SlidingUpPanel(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        backdropOpacity: 0.7,
        backdropEnabled: true,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        minHeight: 0,
        controller: panelController,
        panel: SingleChildScrollView(
          child: Column(
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
                        onPressed: currBorrowItem.available && returnBorrowItem.uid == "" ? () async {
                          EasyLoading.show(status: "Checking Location...");
                          LocationData loc = await Location().getLocation();
                          EasyLoading.show(status: "Distance: ${calculateDistance(loc.latitude!, loc.longitude!, widget.location["latitude"], widget.location["longitude"])}");
                          if (calculateDistance(loc.latitude!, loc.longitude!, widget.location["latitude"], widget.location["longitude"]) <= widget.location["distance"]) {
                            EasyLoading.dismiss();
                            pickedTime = DateTime.now().add(Duration(minutes: pickedMinute));
                            context.push('/camera', extra: {"item": currBorrowItem, "borrow": true, "notes": notes, "pickedTime": pickedTime});
                          } else {
                            EasyLoading.showError("Not in SSO");
                          }
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
              SizedBox(
                height: 20,
              ),
              if (currBorrowItem.borrowUntil != null) StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return (currBorrowItem.borrowUntil!.difference(DateTime.now()).isNegative ) ? Text("Time Limit Exceeded!") : Text("Time Left: ${currBorrowItem.borrowUntil!.difference(DateTime.now()).inHours} : ${currBorrowItem.borrowUntil!.difference(DateTime.now()).inMinutes % 60} : ${currBorrowItem.borrowUntil!.difference(DateTime.now()).inSeconds % 60}");
                },
              ),
              if (currBorrowItem.available && returnBorrowItem.uid == "") Column(
                children: [
                  NumberPicker(axis: Axis.horizontal,
                      minValue: 30,
                      maxValue: 120,
                      step: 10,
                      value: pickedMinute,
                      onChanged: (x) {
                    setState(() {
                      pickedMinute = x;
                    });

                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Borrow for $pickedMinute minutes"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (currBorrowItem.available && returnBorrowItem.uid == "") TextField(
                decoration: InputDecoration(
                  hintText: "Write your notes here",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (s) {
                  notes = s;
                },
                maxLines: 5,
              )
            ],
          ),
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
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              returnBorrowItem.name,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            StreamBuilder(
                                              stream: Stream.periodic(Duration(seconds: 1)),
                                              builder: (context, snapshot) {
                                                Duration diff = returnBorrowItem.borrowUntil!.difference(DateTime.now());
                                                return (diff.isNegative ) ? Text(
                                                    "Time Limit Exceeded!",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[350],
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                ) : Text(
                                                    "Time Left: ${diff.inHours} : ${diff.inMinutes % 60} : ${diff.inSeconds % 60}",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[350],
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
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
                              DateTime? date;
                              date = data["borrowUntil"] != null ? (data["borrowUntil"] as Timestamp).toDate() : null;
                              BorrowItemClass item = BorrowItemClass(name: data["name"], imgUrl: data["imgUrl"], available: data["available"], uid: e.id, borrowUntil: date);
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
