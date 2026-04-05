import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/property_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/amenity_list.vm.dart';
import 'package:flutter_academy/main.dart';
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

  Future<void> _submitWizard() async {
    if (!_formKey.currentState!.validate()) return;

    // NOTE: You will need to update your `addToProperties` method in `PropertyListVM`
    // to accept these new parameters (phone, email, floors, amenityIds).
    final success = await ref.read(propertyListVM.notifier).addToProperties(
          name: _name.text,
          address: _address.text,
          phone: _phone.text,
          email: _email.text,
          floors: _floors,
          amenityIds: _selectedAmenityIds.map((id) => int.parse(id)).toList(),
        );

    if (success) {
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

    return Center(
      child: SizedBox(
        width: 600, // Slightly wider to accommodate the Stepper comfortably
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
                  type: StepperType.horizontal,
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
                            decoration: const InputDecoration(
                                labelText: "Contact Phone"),
                            keyboardType: TextInputType.phone,
                          ),
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                                labelText: "Contact Email"),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Note: You can update these details later in settings.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _floorController,
                                  decoration: const InputDecoration(
                                      labelText: 'Add Floor Number (e.g. 1)'),
                                  keyboardType: TextInputType.number,
                                  onFieldSubmitted: _addFloor,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                color: Theme.of(context).primaryColor,
                                onPressed: () =>
                                    _addFloor(_floorController.text),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
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
                          const Text(
                              "Select basic amenities for your property:"),
                          const SizedBox(height: 10),
                          if (amenities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                  "No amenities available. You can add them later."),
                            )
                          else
                            Wrap(
                              spacing: 8.0,
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
      ),
    );
  }
}
