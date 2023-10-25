class HistoryItemClass {
  String name = "";
  DateTime time = DateTime.now();
  String? notes;
  String? imgUrl;

  HistoryItemClass.empty(): name = "";
  HistoryItemClass(name, time, notes, imgUrl);
}