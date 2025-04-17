import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RateInputDialog extends StatefulWidget {
  final DateTime date;
  final double? initialPrice;

  const RateInputDialog({
    super.key,
    required this.date,
    this.initialPrice,
  });

  @override
  State<RateInputDialog> createState() => _RateInputDialogState();
}

class _RateInputDialogState extends State<RateInputDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice?.toStringAsFixed(2) ?? '',
    );
  }

  void _onSave() {
    final value = double.tryParse(_controller.text);
    if (value == null || value < 0) {
      setState(() => _errorText = 'Please enter a valid rate');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Set Rate for ${DateFormat.yMMMMd().format(widget.date)}"),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: "Rate",
          prefixText: '\$',
          errorText: _errorText,
        ),
        autofocus: true,
        onSubmitted: (_) => _onSave(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
