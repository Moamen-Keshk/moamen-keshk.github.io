import 'package:flutter_academy/infrastructure/courses/model/block.model.dart';

class BlockVM {
  final Block block;
  BlockVM(this.block);

  String get id => block.id;
  String? get note => block.note;
  DateTime get blockDate => block.blockDate;
  DateTime get startDate => block.startDate;
  DateTime get endDate => block.endDate;
  int get startDay => block.startDay;
  int get startMonth => block.startMonth;
  int get startYear => block.startYear;
  int get endDay => block.endDay;
  int get endMonth => block.endMonth;
  int get endYear => block.endYear;
  int get numberOfDays => block.numberOfDays;
  int get propertyID => block.propertyID;
  int get roomID => block.roomID;
}
