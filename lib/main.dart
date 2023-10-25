import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:rentapp/components/Camera.dart';
import 'package:rentapp/components/Success.dart';
import 'package:rentapp/components/cameraAccessDenied.dart';
import 'package:rentapp/login/login.dart';
import 'package:rentapp/mainpage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final locRef = FirebaseFirestore.instance.collection("globals").doc("location");

  final res = await locRef.get();
  final location = res.data() as Map<String, dynamic>;
  EasyLoading.instance
    ..userInteractions = false
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..loadingStyle = EasyLoadingStyle.dark;

  List<CameraDescription> cameras = [];

  runApp(MaterialApp.router(
    builder: EasyLoading.init(),
    debugShowCheckedModeBanner: false,
    routerConfig: GoRouter(
      redirect: (context, state) async {
        if (FirebaseAuth.instance.currentUser == null) {
          return '/';
        }
        if (state.fullPath == '/camera') {
          if (cameras.isEmpty) {
            EasyLoading.show(status: "Initializing Camera");
            cameras = await availableCameras().onError((error, stackTrace) {return [];});
            EasyLoading.dismiss();
            if (cameras.isEmpty) {
              return '/cameraerror';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }
        return null;
      },
      initialLocation: "/",
      routes: [
        GoRoute(
            path: "/",
          builder: (context, state) => const Login()
        ),
        GoRoute(
            path: "/cameraerror",
            builder: (context, state) => const CameraAccessDenied()
        ),
        GoRoute(
            path: "/home",
            builder: (context, state) => MainPage(location: location,)
        ),
        GoRoute(
          path: "/camera",
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return TakePicture(
                borrowItem: extra["item"],
              borrow: extra["borrow"],
              notes: extra["notes"],
              pickedTime: extra["pickedTime"],
              cameras: cameras,
            );
          }
        ),
        GoRoute(
          path: "/success",
          builder: (context, state) {
            final extra = state.extra as bool;
            return SuccessPopup(borrow: extra);
          }
        )
      ],
    ),
  ));
  FlutterNativeSplash.remove();
}