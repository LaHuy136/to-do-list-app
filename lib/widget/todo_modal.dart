import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';

class TodoModal extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onDelete;

  const TodoModal({
    super.key,
    required this.title,
    required this.controller,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: title,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MyElevatedButton(onPressed: onSubmit, textButton: title),
          if (onDelete != null) ...[
            const SizedBox(height: 20),
            MyElevatedButton(onPressed: onDelete!, textButton: 'Delete To do'),
          ],
          const SizedBox(height: 20),
          MyElevatedButton(
            onPressed: () => Navigator.pop(context),
            textButton: 'Cancel',
          ),
        ],
      ),
    );
  }
}
