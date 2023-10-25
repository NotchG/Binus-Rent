import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:go_router/go_router.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final User? user = FirebaseAuth.instance.currentUser;

  String NIM = "";
  String Jurusan = "Software Engineering";

  @override
  void initState() {
    super.initState();
    final userDB = FirebaseFirestore.instance.collection("users").doc(user!.uid);
    userDB.get().then((doc) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        NIM = data["NIM"];
        Jurusan = data["Jurusan"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 30,bottom: 30),
            width: MediaQuery.of(context).size.width,
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
            child: Column(
              children: [
                ProfilePicture(
                  name: "${user!.displayName}",
                  radius: 55,
                  fontsize: 27,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${user?.displayName}",
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: TextEditingController()..text = NIM,
                  onChanged: (s) {
                    NIM = s;
                  },
                  decoration: InputDecoration(
                    hintText: "NIM",
                    hintStyle: const TextStyle(
                        color: Colors.black87
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                  ),
                  style: const TextStyle(
                      color: Colors.black87
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButton(
                    value: Jurusan,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.white),
                    items: ["Software Engineering", "Management", "Business Management", "Business Information Technology", "Psychology", "Business Hotel Management", "Accounting"].map((e) {
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
                    final userRef = FirebaseFirestore.instance.collection("users").doc(user!.uid);
                    EasyLoading.show(status: "Loading...");
                    await userRef.update({
                      "NIM": NIM,
                      "Jurusan": Jurusan
                    });
                    EasyLoading.showSuccess("Saved!");
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xff0066C5)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ))
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FirebaseAuth.instance.signOut();
                    context.pushReplacement("/");
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xff41A4FF)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ))
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
