import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPropertyVM = StateProvider<int>((ref) => 0);

final selectedMonthVM = StateProvider<DateTime>((ref) => DateTime.now());
