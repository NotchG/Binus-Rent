import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:rentapp/components/Camera.dart';
import 'package:rentapp/components/Success.dart';
import 'package:rentapp/login/login.dart';
import 'package:rentapp/mainpage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  EasyLoading.instance
    ..userInteractions = false
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..loadingStyle = EasyLoadingStyle.dark;

  final cameras = await availableCameras();

  runApp(MaterialApp.router(
    builder: EasyLoading.init(),
    debugShowCheckedModeBanner: false,
    routerConfig: GoRouter(
      initialLocation: "/",
      routes: [
        GoRoute(
            path: "/",
          builder: (context, state) => const Login()
        ),
        GoRoute(
            path: "/home",
            builder: (context, state) => const MainPage()
        ),
        GoRoute(
          path: "/camera",
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return TakePicture(
                borrowItem: extra["item"],
              borrow: extra["borrow"],
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
}