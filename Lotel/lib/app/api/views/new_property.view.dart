import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/property_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/amenity_list.vm.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPropertyView extends ConsumerStatefulWidget {
  const NewPropertyView({super.key});

  @override
  ConsumerState<NewPropertyView> createState() => _NewPropertyViewState();
}

class _NewPropertyViewState extends ConsumerState<NewPropertyView> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1: Basic Details
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _timezone = TextEditingController(text: 'UTC');
  final TextEditingController _currency = TextEditingController(text: 'USD');
  final TextEditingController _taxRate = TextEditingController(text: '0');
  final TextEditingController _checkInTime =
      TextEditingController(text: '15:00');
  final TextEditingController _checkOutTime =
      TextEditingController(text: '11:00');

  // Step 2: Floors
  final List<int> _floors = [];
  final TextEditingController _floorController = TextEditingController();

  // Step 3: Amenities
  final List<String> _selectedAmenityIds = [];

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _timezone.dispose();
    _currency.dispose();
    _taxRate.dispose();
    _checkInTime.dispose();
    _checkOutTime.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _addFloor(String value) {
    if (value.isNotEmpty) {
      final floorNum = int.tryParse(value);
      if (floorNum != null && !_floors.contains(floorNum)) {
        setState(() {
          _floors.add(floorNum);
          _floorController.clear();
        });
      }
    }
  }

  Future<void> _pickTime(
      BuildContext context, TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 12,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selected != null) {
      final formatted =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      controller.text = formatted;
    }
  }

  Future<void> _submitWizard() async {
    if (!_formKey.currentState!.validate()) return;

    final createdProperty = await ref
        .read(propertyListVM.notifier)
        .addToProperties(
          name: _name.text,
          address: _address.text,
          phone: _phone.text,
          email: _email.text,
          timezone: _timezone.text,
          currency: _currency.text,
          taxRate: double.tryParse(_taxRate.text) ?? 0,
          defaultCheckInTime: _checkInTime.text,
          defaultCheckOutTime: _checkOutTime.text,
          floors: _floors,
          amenityIds: _selectedAmenityIds.map((id) => int.parse(id)).toList(),
        );

    if (createdProperty != null) {
      final propertyId = int.tryParse(createdProperty.id);
      if (propertyId != null) {
        ref.read(selectedPropertyVM.notifier).updateProperty(propertyId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully.')),
        );
      }
      ref.read(routerProvider).replaceAllWith('dashboard');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred, try again!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amenities = ref.watch(amenityListVM);
    final isCompact = context.showCompactLayout;

    return ResponsiveFormCard(
      maxWidth: 760,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Setup New Property",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: Stepper(
                type: isCompact ? StepperType.vertical : StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep += 1);
                  } else {
                    _submitWizard();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child:
                              Text(_currentStep == 2 ? 'Finish' : 'Continue'),
                        ),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Basic Info'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                              labelText: "Property Name *"),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        TextFormField(
                          controller: _address,
                          decoration:
                              const InputDecoration(labelText: "Address *"),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        TextFormField(
                          controller: _phone,
                          decoration:
                              const InputDecoration(labelText: "Contact Phone"),
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: _email,
                          decoration:
                              const InputDecoration(labelText: "Contact Email"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            return value.contains('@')
                                ? null
                                : 'Use a valid email address';
                          },
                        ),
                        TextFormField(
                          controller: _timezone,
                          decoration:
                              const InputDecoration(labelText: "Timezone *"),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        TextFormField(
                          controller: _currency,
                          decoration:
                              const InputDecoration(labelText: "Currency *"),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.length != 3) {
                              return 'Use a 3-letter code';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _taxRate,
                          decoration:
                              const InputDecoration(labelText: "Tax Rate %"),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed < 0 || parsed > 100) {
                              return 'Use a value between 0 and 100';
                            }
                            return null;
                          },
                        ),
                        ResponsiveFormRow(
                          children: [
                            TextFormField(
                              controller: _checkInTime,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Default Check-In *",
                              ),
                              onTap: () => _pickTime(context, _checkInTime),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                            TextFormField(
                              controller: _checkOutTime,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Default Check-Out *",
                              ),
                              onTap: () => _pickTime(context, _checkOutTime),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Note: You can update these details later in settings.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Floors'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveFormRow(
                          children: [
                            TextFormField(
                              controller: _floorController,
                              decoration: const InputDecoration(
                                labelText: 'Add Floor Number (e.g. 1)',
                              ),
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: _addFloor,
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: IconButton(
                                icon: const Icon(Icons.add_circle),
                                color: Theme.of(context).primaryColor,
                                onPressed: () =>
                                    _addFloor(_floorController.text),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _floors
                              .map((f) => Chip(
                                    label: Text('Floor $f'),
                                    onDeleted: () {
                                      setState(() => _floors.remove(f));
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Amenities'),
                    isActive: _currentStep >= 2,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select basic amenities for your property:"),
                        const SizedBox(height: 10),
                        if (amenities.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No amenities available. You can add them later.",
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: amenities.map((amenity) {
                              final isSelected =
                                  _selectedAmenityIds.contains(amenity.id);
                              return FilterChip(
                                label: Text(amenity.name),
                                selected: isSelected,
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedAmenityIds.add(amenity.id);
                                    } else {
                                      _selectedAmenityIds.remove(amenity.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    ),
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
