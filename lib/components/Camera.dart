import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_onedrive/flutter_onedrive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rentapp/Classes/BorrowItemClass.dart';

class TakePicture extends StatefulWidget {
  final BorrowItemClass borrowItem;
  final bool borrow;
  final String? notes;
  final DateTime? pickedTime;
  final List<CameraDescription> cameras;
  const TakePicture({super.key, required this.borrowItem, required this.borrow, required this.cameras, this.notes, this.pickedTime});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {

  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  int currIdx = 0;
  bool loading = true;
  XFile? imagePath;
  bool first = true;
  final User? user = FirebaseAuth.instance.currentUser;
  final storageRef = FirebaseStorage.instance.ref();

  void uploadLoading(TaskSnapshot taskSnapshot, Reference ref, ) {
    final itemsRef = FirebaseFirestore.instance.collection("items").doc(widget.borrowItem.uid);
    final historyRef = FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("history");
    switch (taskSnapshot.state) {
      case TaskState.running:
        final progress =
            100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        EasyLoading.show(status: "Uploading $progress%");
        break;
      case TaskState.paused:
        EasyLoading.show(status: "Uploading is paused");
        break;
      case TaskState.canceled:
        EasyLoading.showError("Upload was cancelled", duration: Duration(seconds: 1));
        break;
      case TaskState.error:
        EasyLoading.showError("An Error Occurred", duration: Duration(seconds: 1));
        break;
      case TaskState.success:
        EasyLoading.show(status: "Getting download url");
        ref.getDownloadURL().then((url) async {
          if (widget.borrow) {
            EasyLoading.show(status: "Saving to database");
            await historyRef.add({
              "name": "Peminjaman ${widget.borrowItem.name}",
              "time": FieldValue.serverTimestamp(),
              "imgUrl": url
            });
            await itemsRef.update({
              "borrowUntil": widget.pickedTime,
              "currBorrow": FirebaseAuth.instance.currentUser!.uid,
              "available": false
            });
            EasyLoading.dismiss();
            context.pushReplacement("/success", extra: true);
          } else {
            await historyRef.add({
              "name": "Pengembalian ${widget.borrowItem.name}",
              "time": FieldValue.serverTimestamp(),
              "imgUrl": url
            });
            await itemsRef.update({
              "borrowUntil": FieldValue.delete(),
              "currBorrow": "",
              "available": true
            });
            EasyLoading.dismiss();
            context.pushReplacement("/success", extra: false);
          }
        });
        break;
    }
  }

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
      floatingActionButton: imagePath == null ? Row(
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
                  imagePath = image;
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
                imagePath = null;
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
              EasyLoading.show(status: "Loading...");
              try {
                // Upload raw data.
                final ref = storageRef.child("${user!.displayName}/images/${widget.borrow ? "Peminjaman" : "Pengembalian"} ${DateFormat('yyyy-MM-dd-hh-mm-ss').format(DateTime.now())}.jpeg");
                print(ref.fullPath);
                final metadata = SettableMetadata(
                  contentType: 'image/jpeg',
                  customMetadata: {'picked-file-path': imagePath!.path},
                );
                if (kIsWeb) {
                  Uint8List res = await imagePath!.readAsBytes();
                  EasyLoading.show(status: "Uploading Data with ${res.length} bytes of data");
                  ref.putData(res, metadata).snapshotEvents.listen((taskSnapshot) {
                    uploadLoading(taskSnapshot, ref);
                  });
                } else {
                  ref.putFile(File(imagePath!.path)).snapshotEvents.listen((taskSnapshot) {
                    uploadLoading(taskSnapshot, ref);
                  });;
                }
              } on FirebaseException catch (e) {
                EasyLoading.showError("Error $e", duration: Duration(seconds: 1));
                print(e.message);
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
              return imagePath == null ? CameraPreview(
                  controller
              ) : (kIsWeb ? Image.network(imagePath!.path) : Image.file(File(imagePath!.path)));
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
