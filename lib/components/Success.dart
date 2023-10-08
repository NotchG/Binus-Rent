import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SuccessPopup extends StatefulWidget {
  final bool borrow;
  const SuccessPopup({super.key, required this.borrow});

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff41A4FF),
      body: InkWell(
        onTap: () {
          context.pushReplacement("/home");
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                  'assets/lottie/SuccessCheck.json',
                repeat: false,
                width: 500,
                height: 500,
                fit: BoxFit.fitWidth
              ),
              Text(
                  widget.borrow ? "Successfully Borrowed" : "Successfully Returned",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              Text(
                "Tap To Dismiss",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[300],
                    fontSize: 15
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
