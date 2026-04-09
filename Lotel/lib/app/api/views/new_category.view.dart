import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/main.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';

class NewCategoryView extends ConsumerStatefulWidget {
  const NewCategoryView({super.key});

  @override
  ConsumerState<NewCategoryView> createState() => _NewCategoryViewState();
}

class _NewCategoryViewState extends ConsumerState<NewCategoryView> {
  final _formKey = GlobalKey<FormState>();
  String name = '';

  @override
  Widget build(BuildContext context) {
    final categoryVM = ref.read(categoryListVM.notifier);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Single Room, Double Room, Suite',
                  ),
                  onChanged: (val) => name = val,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Create Category'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await categoryVM.addCategory(
                        name: name.trim(),
                        capacity: 1,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Category created successfully')),
                        );
                        ref
                            .read(routerProvider)
                            .pop(); // Go back to management list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not create category')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
