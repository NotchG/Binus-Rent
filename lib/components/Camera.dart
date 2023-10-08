import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:rentapp/Classes/BorrowItemClass.dart';

class TakePicture extends StatefulWidget {
  final BorrowItemClass borrowItem;
  final bool borrow;
  final List<CameraDescription> cameras;
  const TakePicture({super.key, required this.borrowItem, required this.borrow, required this.cameras});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {

  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  int currIdx = 0;
  bool loading = true;
  String imagePath = "";
  bool first = true;
  final User? user = FirebaseAuth.instance.currentUser;

  void load() async {
    setState(() {
      loading = true;
    });
    first ? null : await controller.dispose();
    controller = CameraController(
        widget.cameras[currIdx],
        ResolutionPreset.max,
      enableAudio: false,
    );

    first = false;

    _initializeControllerFuture = controller.initialize();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: imagePath == "" ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Close",
            onPressed: () {
              context.pop();
            },
            child: const Icon(Icons.close),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "switchCamera",
            onPressed: loading ? null : () {
                if (widget.cameras.length - 1 == currIdx) {
                  currIdx = 0;
                } else {
                  currIdx++;
                }
                load();
            },
            child: const Icon(Icons.switch_camera),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "camera",
            onPressed: loading ? null : () async {
              try {
                EasyLoading.show(status: "loading...");
                await _initializeControllerFuture;

                final image = await controller.takePicture();

                if(!mounted) return;

                setState(() {
                  imagePath = image.path;
                });
                EasyLoading.dismiss();
              } catch (e) {
                EasyLoading.showError(e.toString());
              }
            },
            child: const Icon(Icons.camera),
          ),
        ],
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "close",
            onPressed: () {
              context.pop();
            },
            child: const Icon(Icons.close),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "retakeCamera",
            onPressed: loading ? null : () {
              setState(() {
                imagePath = "";
                load();
              });
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "complete",
            onPressed: loading ? null : () async {
              final itemsRef = FirebaseFirestore.instance.collection("items").doc(widget.borrowItem.uid);
              final historyRef = FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("history");
              if (widget.borrow) {
                await historyRef.add({
                  "name": "Peminjaman ${widget.borrowItem.name}",
                  "time": FieldValue.serverTimestamp()
                });
                itemsRef.update({
                  "currBorrow": FirebaseAuth.instance.currentUser!.uid,
                  "available": false
                }).then((value) => context.pushReplacement("/success", extra: true));
              } else {
                await historyRef.add({
                  "name": "Pengembalian ${widget.borrowItem.name}",
                  "time": FieldValue.serverTimestamp()
                });
                itemsRef.update({
                  "currBorrow": "",
                  "available": true
                }).then((value) => context.pushReplacement("/success", extra: false));
              }
            },
            child: const Icon(Icons.check),
          ),
        ],
      ),
      body: !loading ? SizedBox(
        height: MediaQuery.of(context).size.height * 4/5,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<void> (
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              return imagePath == "" ? CameraPreview(
                  controller
              ) : (kIsWeb ? Image.network(imagePath) : Image.file(File(imagePath)));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ) : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
