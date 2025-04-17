import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/property_list.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPropertyView extends StatefulWidget {
  const NewPropertyView({super.key});

  @override
  State<NewPropertyView> createState() => _NewPropertyViewState();
}

class _NewPropertyViewState extends State<NewPropertyView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();

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
                "New Property",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "enter name"),
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: "enter address"),
              ),
              const SizedBox(height: 20.0),
              Consumer(builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    if (await ref.read(propertyListVM.notifier).addToProperties(
                        name: _name.text, address: _address.text)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Property added successfully.')),
                        );
                      }
                      ref.read(routerProvider).replaceAllWith('dashboard');
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('An error occured, try again!')),
                        );
                      }
                    }
                  },
                  child: const Text("Add Property"),
                );
              })
            ],
          ),
        ));
  }
}
