
class BorrowItemClass {
  String name = "";
  bool available = false;
  DateTime? borrowUntil;
  String imgUrl = "";
  String uid = "";

  BorrowItemClass.empty(): name = "", available = false, imgUrl = "", uid = "";

  BorrowItemClass({required this.name, required this.imgUrl, required this.available, required this.uid, this.borrowUntil});




}