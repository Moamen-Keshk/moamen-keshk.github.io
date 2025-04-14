import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class RoomFormRow extends StatelessWidget {
  final Room room;
  final String? categoryId;
  final List<CategoryVM> categories;
  final void Function(String) onCategoryChanged;
  final void Function() onRoomDeleted;

  const RoomFormRow({
    super.key,
    required this.room,
    required this.categoryId,
    required this.categories,
    required this.onCategoryChanged,
    required this.onRoomDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            initialValue: room.roomNumber.toString(),
            decoration: _smallInput("Room No."),
            style: const TextStyle(fontSize: 13),
            validator: (val) =>
                val == null || val.isEmpty ? "Enter room no." : null,
            onSaved: (value) =>
                room.roomNumber = int.tryParse(value ?? '') ?? room.roomNumber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: categoryId,
            isExpanded: true,
            decoration: _smallInput("Category"),
            style: const TextStyle(fontSize: 13),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat.id, child: Text(cat.name));
            }).toList(),
            onChanged: (val) => onCategoryChanged(val!),
            validator: (val) => val == null ? "Select category" : null,
          ),
        ),
        IconButton(
            onPressed: onRoomDeleted,
            icon: const Icon(Icons.delete_outline, size: 20)),
      ]),
    );
  }

  InputDecoration _smallInput(String label) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
    );
  }
}

class CategoryFormRow extends StatelessWidget {
  final List<CategoryVM> categories;
  final void Function(String) onCategoryChanged;

  const CategoryFormRow({
    super.key,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: _smallInput("Category"),
            style: const TextStyle(fontSize: 13),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat.id, child: Text(cat.name));
            }).toList(),
            onChanged: (val) => onCategoryChanged(val!),
            validator: (val) => val == null ? "Select category" : null,
          ),
        )
      ]),
    );
  }

  InputDecoration _smallInput(String label) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
    );
  }
}

class NewRoomRow extends StatelessWidget {
  final int index;
  final List<CategoryVM> categories;
  final void Function(String) onRoomSaved;
  final String? selectedValue;
  final void Function(String?) onCategorySelected;

  const NewRoomRow({
    super.key,
    required this.index,
    required this.categories,
    required this.onRoomSaved,
    required this.selectedValue,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: _smallInput("Room No."),
            style: const TextStyle(fontSize: 13),
            validator: (val) =>
                val == null || val.isEmpty ? "Enter room no." : null,
            onSaved: (val) {
              if (val != null && val.isNotEmpty) onRoomSaved(val);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            isExpanded: true,
            decoration: _smallInput("Category"),
            style: const TextStyle(fontSize: 13),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat.id, child: Text(cat.name));
            }).toList(),
            onChanged: onCategorySelected,
            validator: (val) => val == null ? "Select category" : null,
          ),
        ),
      ]),
    );
  }

  InputDecoration _smallInput(String label) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
    );
  }
}
