import 'package:flutter/material.dart';

Future<String?> showTextInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _TextInputDialog(),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog();

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onOkPressed() {
    Navigator.of(context).pop(_controller.text);
  }

  void _onCancelPressed() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Робота1'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Текст:',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancelPressed,
          child: const Text('Відміна'),
        ),
        ElevatedButton(
          onPressed: _onOkPressed,
          child: const Text('Так'),
        ),
      ],
    );
  }
}
