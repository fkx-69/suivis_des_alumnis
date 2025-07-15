// lib/widgets/group/input_message.dart

import 'package:flutter/material.dart';

class InputMessage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const InputMessage({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Écrire un message…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
