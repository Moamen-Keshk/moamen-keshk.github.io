import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/category_list.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewCategoryView extends ConsumerStatefulWidget {
  const NewCategoryView({super.key});

  @override
  ConsumerState<NewCategoryView> createState() => _NewCategoryViewState();
}

class _NewCategoryViewState extends ConsumerState<NewCategoryView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
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
                "New Category",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "enter name"),
                // Add validation for the name field
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                controller: _description,
                decoration:
                    const InputDecoration(labelText: "enter description"),
                // Add validation for the description field
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  // Only proceed if the form fields pass the validation
                  if (_formKey.currentState!.validate()) {
                    if (await ref.read(categoryListVM.notifier).addToCategories(
                        name: _name.text, description: _description.text)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Category added successfully.')),
                        );
                      }
                      ref.read(routerProvider).replaceAllWith('dashboard');
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('An error occured, try again!')),
                        );
                      }
                    }
                  }
                },
                child: const Text("Add Category"),
              )
            ],
          ),
        ));
  }
}
