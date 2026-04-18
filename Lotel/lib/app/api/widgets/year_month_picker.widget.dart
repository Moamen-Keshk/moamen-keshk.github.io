import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:month_year_picker/month_year_picker.dart';

class YearMonthPickerDemo extends StatefulWidget {
  const YearMonthPickerDemo({super.key});

  @override
  State<YearMonthPickerDemo> createState() => _YearMonthPickerDemoState();
}

class _YearMonthPickerDemoState extends State<YearMonthPickerDemo> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.showCompactLayout;
    return Center(
      child: SizedBox(
        width: isCompact ? double.infinity : null,
        child: ElevatedButton(
          onPressed: () async {
            selectedDate = await showMonthYearPicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(20),
              lastDate: DateTime(2027),
            );
            setState(() {});
          },
          child: Text(
            selectedDate != null
                ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}'
                : '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: isCompact ? 16 : 18),
          ),
        ),
      ),
    );
  }
}
