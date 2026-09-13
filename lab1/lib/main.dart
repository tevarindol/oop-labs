import 'package:flutter/material.dart';

import 'module1.dart';
import 'module2.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab1',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _resultText = '';

  Future<void> _onTextInputDialog() async {
    final result = await showTextInputDialog(context);
    if (result != null) {
      setState(() {
        _resultText = result;
      });
    }
  }

  Future<void> _onSliderInputDialog() async {
    final result = await showSliderDialog(context);
    if (result != null) {
      setState(() {
        _resultText = '$result';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab1'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Меню',
            onSelected: (value) {
              if (value == 'robota1') _onTextInputDialog();
              if (value == 'robota2') _onSliderInputDialog();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'robota1', child: Text('Робота1')),
              PopupMenuItem(value: 'robota2', child: Text('Робота2')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _resultText,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
