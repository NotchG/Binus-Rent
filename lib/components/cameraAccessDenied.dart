import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentapp/ColorPalette.dart';

class CameraAccessDenied extends StatefulWidget {
  const CameraAccessDenied({super.key});

  @override
  State<CameraAccessDenied> createState() => _CameraAccessDeniedState();
}

class _CameraAccessDeniedState extends State<CameraAccessDenied> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.accentColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                'assets/lottie/CameraError.json',
                repeat: false,
                width: 500,
                height: 500,
                fit: BoxFit.fitWidth
            ),
            const Text(
              "Camera Error",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (kIsWeb) {

                  }
                },
                child: Text("Request Permission")
            )
          ],
        ),
      ),
    );
  }
}
