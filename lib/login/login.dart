import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

// LOGIN PAGE WITH MICROSOFT LOGIN

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  bool displayForm = false;

  Future<UserCredential> signInWithMicrosoft() async {
    final microsoftProvider = MicrosoftAuthProvider();
    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
    } else {
      return await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
    }
  }

  void checkInformation() {
    if (FirebaseAuth.instance.currentUser == null) {
      EasyLoading.dismiss();
      return;
    }
    EasyLoading.show(status: "Loading...");
    db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      if (value.exists) {
        context.go("/home");
      } else {
        setState(() {
          displayForm = true;
        });
        EasyLoading.dismiss();
      }
    });

  }

  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: "loading...");
    checkInformation();

  }

  void submit(Map<String, dynamic> s) async {
    await db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
      "NIM": s["NIM"],
      "Jurusan": s["Jurusan"]
    });
    checkInformation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0066C5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: !displayForm ? Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Let's Get Started",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: Colors.white
                ),
              ),
              Lottie.asset(
                  'assets/lottie/Login.json',
                  repeat: true,
                  width: 500,
                  height: 500,
                  fit: BoxFit.fitWidth
              ),
              ElevatedButton(
                onPressed: () async {
                  signInWithMicrosoft().then((value) => checkInformation()).onError((error, stackTrace) => checkInformation());
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ))
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: min(MediaQuery.of(context).size.width, 500),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                              "assets/images/microsoft.png",
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "Login with microsoft",
                            style: TextStyle(
                              color: Color(0xff282a41),
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ) : SizedBox(
          height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CompleteForm(
              submit: (s) {
                submit(s);
              },
            )
        ),
      ),
    );
  }
}

// IF LOGIN USER LOGINS FOR THE FIRST TIME, USER WILL BE REDIRECTED TO THIS FORM PAGE
class CompleteForm extends StatefulWidget {
  final Function(Map<String, dynamic> s) submit;
  const CompleteForm({super.key, required this.submit});

  @override
  State<CompleteForm> createState() => _CompleteFormState();
}

class _CompleteFormState extends State<CompleteForm> {

  String NIM = "";
  String Jurusan = "Software Engineering";
  Map<String, String> JURUSAN = {
    "Software Engineering": "Jurusan Software Eng.",
    "Management": "Jurusan Management",
    "Business Management": "Jurusan Business",
    "Business Information Technology": "Jurusan Business Tech",
    "Psychology": "Jurusan Psychology",
    "Business Hotel Management": "Jurusan Business Hotel",
    "Accounting": "Jurusan Accounting"
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Please fill out these details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
        const SizedBox(
          height: 30,
        ),
        TextField(
          onChanged: (s) {
            NIM = s;
          },
          decoration: const InputDecoration(
            hintText: "NIM",
            hintStyle: TextStyle(
                color: Colors.white
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(
            color: Colors.white
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        DropdownButton(
            value: Jurusan,
            icon: const Icon(Icons.arrow_drop_down,color: Colors.white,),
            style: const TextStyle(color: Colors.white),
            selectedItemBuilder: (context) {
              return JURUSAN.values.map((e) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                );
              }).toList();
            },
            items: JURUSAN.keys.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                    e,
                  style: const TextStyle(
                    color: Colors.black87
                  ),
                ),
              );
            }).toList(),
            onChanged: (s) {
              setState(() {
                Jurusan = s!;
              });
            }
        ),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: () async {
            widget.submit({
              "NIM": NIM,
              "Jurusan": Jurusan
            });
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ))
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                "Complete Form",
                style: TextStyle(
                    color: Color(0xff282a41),
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        )
      ]
    );
  }
}

