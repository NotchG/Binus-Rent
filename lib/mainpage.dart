import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:rentapp/History/history.dart';
import 'package:rentapp/home/home.dart';
import 'package:rentapp/profile/profile.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';

// MAIN PAGE OF BINUS RENT WITH BOTTOM NAVIGATION DRAWER

class MainPage extends StatefulWidget {
  final Map<String, dynamic> location;
  const MainPage({super.key, required this.location});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int currPageIdx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 50,
        backgroundColor: const Color(0xff0066C5),
        onDestinationSelected: (i) {
          setState(() {
            currPageIdx = i;
          });
        },
        indicatorColor: Colors.white,
        selectedIndex: currPageIdx,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Color(0xff0066C5),
            ),
              icon: Icon(
                  Icons.home,
                color: Colors.white,
              ),
              label: 'Home'
          ),
          NavigationDestination(
              selectedIcon: Icon(
                Icons.history,
                color: Color(0xff0066C5),
              ),
              icon: Icon(
                Icons.history,
                color: Colors.white,
              ),
              label: 'Home'
          ),
          NavigationDestination(
              selectedIcon: Icon(
                Icons.person,
                color: Color(0xff0066C5),
              ),
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: 'Home'
          )
        ],
      ),
      body: ColorfulSafeArea(
        color: const Color(0xff0066C5),
        child: FadeIndexedStack(
          beginOpacity: 0.5,
          endOpacity: 1.0,
          curve: Curves.bounceInOut,
          duration: const Duration(milliseconds: 250),
          index: currPageIdx,
          children: [Home(location: widget.location,), History(), Profile()],
        ),
      ),
    );
  }
}
