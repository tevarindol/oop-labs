import 'package:flutter/material.dart';

Future<int?> showSliderDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _SliderDialog(),
  );
}

class _SliderDialog extends StatefulWidget {
  const _SliderDialog();

  @override
  State<_SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<_SliderDialog> {
  double _value = 1;

  void _onSliderChanged(double newValue) {
    setState(() {
      _value = newValue;
    });
  }

  void _onOkPressed() {
    Navigator.of(context).pop(_value.round());
  }

  void _onCancelPressed() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Робота2'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Значення: ${_value.round()}',
            style: const TextStyle(fontSize: 18),
          ),
          Slider(
            value: _value,
            min: 1,
            max: 100,
            divisions: 99,
            label: _value.round().toString(),
            onChanged: _onSliderChanged,
          ),
        ],
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
