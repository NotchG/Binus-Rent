import 'package:flutter/material.dart';
import 'package:rentapp/Classes/BorrowItemClass.dart';
import 'package:rentapp/ColorPalette.dart';

// COMPONENT OF CATALOG IN HOME PAGE

class BorrowItem extends StatefulWidget {

  final BorrowItemClass item;
  final Function openPanel;

  const BorrowItem({super.key, required this.item, required this.openPanel});

  @override
  State<BorrowItem> createState() => _BorrowItemState();
}

class _BorrowItemState extends State<BorrowItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.openPanel();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ColorPalette.mainColor,
          image: DecorationImage(
              image: NetworkImage(widget.item.imgUrl),
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
                        Colors.black.withOpacity(0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.item.available ? Colors.green : Colors.red
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.item.available ? "Available" : "Unavailable",
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

