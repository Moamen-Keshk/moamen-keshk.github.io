import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/main.dart';

class NewCategoryView extends StatefulWidget {
  const NewCategoryView({super.key});

  @override
  State<NewCategoryView> createState() => _NewCategoryViewState();
}

class _NewCategoryViewState extends State<NewCategoryView> {
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
              ),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                controller: _description,
                decoration:
                    const InputDecoration(labelText: "enter description"),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (await CategoryListVM().addToCategories(
                      name: _name.text, description: _description.text)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Category added successfully.')),
                      );
                    }
                    routerDelegate.replaceAllWith('dashboard');
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occured, try again!')),
                      );
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
