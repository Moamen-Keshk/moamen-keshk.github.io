import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/property_list.vm.dart';
import 'package:flutter_academy/main.dart';

class NewFloorView extends StatefulWidget {
  const NewFloorView({super.key});

  @override
  State<NewFloorView> createState() => _NewFloorViewState();
}

class _NewFloorViewState extends State<NewFloorView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  List<DropdownData> floorDropdownItems = [
      DropdownData(-1, 'B'),
      DropdownData(0, 'G'),
      DropdownData(1, '1'),
      DropdownData(2, '2'),
      DropdownData(3, '3'),
      DropdownData(4, '4'),
      DropdownData(5, '5'),
      DropdownData(6, '6'),
      DropdownData(7, '7'),
      DropdownData(8, '8'),
      DropdownData(9, '9')
    ];
  List<DropdownData> roomsDropdownItems = [
      DropdownData(1, '1'),
      DropdownData(2, '2'),
      DropdownData(3, '3'),
      DropdownData(4, '4'),
      DropdownData(5, '5'),
      DropdownData(6, '6'),
      DropdownData(7, '7'),
      DropdownData(8, '8'),
      DropdownData(9, '9'),
      DropdownData(0, 'None')
    ];
  List<DropdownData> categoryDropdownItems = [
      DropdownData(1, 'Single'),
      DropdownData(2, 'Double'),
      DropdownData(3, 'Triple'),
      DropdownData(4, 'Quadruple'),
      DropdownData(5, 'Family')
    ];
  int? floorSelectedValue;
  int? floorInitialSelection;
  int? roomsSelectedValue = 0;
  int? roomsInitialSelection;
  int? categorySelectedValue;
  int? categoryInitialSelection;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
                            Text(
                "New Floor",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
                DropdownMenu<int>(
                  initialSelection: floorInitialSelection,
                  requestFocusOnTap: true,
                label: const Text('Floor No.', style: TextStyle(fontSize: 13)),
                onSelected: (int? value) {
                  setState(() {
                    floorSelectedValue = value;
                    return;
                  });
                },
                  dropdownMenuEntries: floorDropdownItems.map<DropdownMenuEntry<int>>((DropdownData data) {
                  return DropdownMenuEntry<int>(
                    value: data.value,
                    label: data.label,
                    style: MenuItemButton.styleFrom(),
                  );
                }).toList()

    ),
    const SizedBox(height: 20.0),
    DropdownMenu<int>(
                  initialSelection: roomsInitialSelection,
                  requestFocusOnTap: true,
                label: const Text('No. of Rooms', style: TextStyle(fontSize: 13)),
                onSelected: (int? value) {
                  setState(() {
                    roomsSelectedValue = value;
                    return;
                  });
                },
                  dropdownMenuEntries: roomsDropdownItems.map<DropdownMenuEntry<int>>((DropdownData data) {
                  return DropdownMenuEntry<int>(
                    value: data.value,
                    label: data.label,
                    style: MenuItemButton.styleFrom(),
                  );
                }).toList()

    ),
              const SizedBox(height: 20.0),
              Container(child: 
              roomsSelectedValue == 0 ? null : Table(
      columnWidths: {
        0: FixedColumnWidth(100.0), // Width of the first column
        1: FlexColumnWidth(), // Remaining space split equally
      },
      children: 
        List.generate(roomsSelectedValue!, (i) => i).map((int roomsSelectedValue) {
                  return TableRow(
          children: [
            Padding(padding: EdgeInsets.only(right:7, bottom:7),
            child: TextFormField(
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Room No.',
    labelStyle: TextStyle(fontSize: 13)
  ),
)),
Padding(padding: EdgeInsets.only(bottom:7),
child: DropdownMenu<int>(
                  initialSelection: categoryInitialSelection,
                  requestFocusOnTap: true,
                label: const Text('Category', style: TextStyle(fontSize: 13)),
                onSelected: (int? value) {
                  setState(() {
                    categorySelectedValue = value;
                    return;
                  });
                },
                  dropdownMenuEntries: categoryDropdownItems.map<DropdownMenuEntry<int>>((DropdownData data) {
                  return DropdownMenuEntry<int>(
                    value: data.value,
                    label: data.label,
                    style: MenuItemButton.styleFrom(),
                  );
                }).toList()
    ))
          ],
        );
                }).toList(),
    )),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                    if (await PropertyListVM().addToProperties(
                          name: _name.text,
                          address: _address.text)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Property added successfully.')
                        ),
                      );
                            }
                      routerDelegate.go('/');
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An error occured, try again!')
                        ),
                      );
                      }
                    }
                },
                child: const Text("Add Floor"),
              )
            ],
          ),
        ));
  }
}

class DropdownData {
  final int value;
  final String label;
  DropdownData(this.value, this.label);
}
