**Міністерство освіти і науки України  
Національний технічний університет України  
«Київський політехнічний інститут імені Ігоря Сікорського»  
Факультет інформатики та обчислювальної техніки  
Кафедра обчислювальної техніки**

**Лабораторна робота №2**

з дисципліни  
«Об’єктно-орієнтоване програмування»

на тему

«Розробка графічного редактора об’єктів»

| Виконав: | Перевірив: |
|---|---|
| студент групи ІМ-55 | Рекечинський Д.О. |
| Стеблевець Олександр Олександрович | |
| Номер в списку - 26 | |

Київ 2026

**Завдання:**

1. Створити у середовищі розробки новий проект з ім’ям Lab2.
2. Скомпілювати проект і отримати виконуваний файл програми.
3. Перевірити роботу програми. За потреби налагодити програму.
4. Проаналізувати та прокоментувати результати та вихідний текст програми.
5. Оформити звіт.

**Завдання згідно варіанту:**

1. У звіті повинна бути схема успадкування класів – діаграма класів.
2. Для вибору типу об’єкта в графічному редакторі Lab2 повинно бути меню "Об’єкти" з чотирма підпунктами. Меню "Об’єкти" повинно бути праворуч меню "Файл" та ліворуч меню "Довідка".
3. Для вибору варіанту використовується Ж – номер студента в журналі.

Для мене (Ж = 26) буде:

- статичний масив для Shape (26 mod 3 = 2) обсягом 126 об’єктів.
- "гумовий" слід (26 mod 4 = 2) – суцільна лінія синього кольору.
- прямокутник: ввід по двом протилежним кутам (26 mod 2 = 0), чорний контур з блакитним заповненням (26 mod 5 = 1, 26 mod 6 = 2).
- еліпс: ввід від центру до одного з кутів (26 mod 2 = 0), чорний контур з білим заповненням (26 mod 5 = 1).
- позначка поточного типу об’єкту: галочкою в меню "Об'єкти" (26 mod 2 = 0).

**Main file: main.dart**

```dart
import 'package:flutter/material.dart';

import 'editor/editor_page.dart';

void main() {
  runApp(const PaintApp());
}

class PaintApp extends StatelessWidget {
  const PaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EditorPage(title: 'Paint'),
    );
  }
}
```

**paint_canvas.dart**

```dart
import 'package:flutter/material.dart';

import 'canvas_shapes.dart';
import 'shape/shape.dart';
import 'shape/shape_type.dart';

class PaintCanvas extends StatefulWidget {
  const PaintCanvas({super.key, required this.selectedTool});

  final ShapeType? selectedTool;

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas> {
  final CanvasShapes _storage = CanvasShapes();

  Offset? _dragStart;
  Offset? _dragCurrent;

  Shape _buildShape(Offset start, Offset end) => Shape.of(widget.selectedTool!, start: start, end: end);

  void _handleTapDown(TapDownDetails details) {
    if (widget.selectedTool != ShapeType.dot) {
      return;
    }
    final position = details.localPosition;
    _storage.add(_buildShape(position, position));
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.selectedTool == ShapeType.dot) {
      return;
    }
    setState(() {
      _dragStart = details.localPosition;
      _dragCurrent = details.localPosition;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.selectedTool == ShapeType.dot) {
      return;
    }
    setState(() {
      _dragCurrent = details.localPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.selectedTool == ShapeType.dot) {
      return;
    }
    final start = _dragStart;
    final current = _dragCurrent;
    setState(() {
      _dragStart = null;
      _dragCurrent = null;
    });
    if (start == null || current == null || _storage.isFull) {
      return;
    }
    _storage.add(_buildShape(start, current));
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.selectedTool;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: ColoredBox(
        color: Colors.white,
        child: CustomPaint(
          painter: _CanvasPainter(
            storage: _storage,
            tool: widget.selectedTool,
            dragStart: _dragStart,
            dragCurrent: _dragCurrent,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  const _CanvasPainter({
    required CanvasShapes storage,
    required this.tool,
    required this.dragStart,
    required this.dragCurrent,
  }) : _storage = storage,
       super(repaint: storage);

  final CanvasShapes _storage;
  final ShapeType? tool;
  final Offset? dragStart;
  final Offset? dragCurrent;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Shape? shape in _storage.shapes) {
      shape?.paint(canvas);
    }
    final start = dragStart;
    final current = dragCurrent;
    if (start == null || current == null || tool == null) {
      return;
    }
    Shape.of(tool!, start: start, end: current).paintPreview(canvas);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) =>
      oldDelegate.dragStart != dragStart || oldDelegate.dragCurrent != dragCurrent;
}
```

**editor_page.dart**

```dart
import 'package:flutter/material.dart';

import 'editor_menu.dart';
import 'paint_canvas.dart';
import 'shape/shape_type.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key, required this.title});

  final String title;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  ShapeType? selectedTool;

  void _selectTool(ShapeType? tool) {
    setState(() => selectedTool = tool);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: EditorMenu(selectedTool: selectedTool, onToolSelected: _selectTool),
          ),
          Expanded(child: PaintCanvas(selectedTool: selectedTool)),
        ],
      ),
    );
  }
}
```

**editor_menu.dart**

```dart
import 'package:flutter/material.dart';

import 'shape/shape_type.dart';

class EditorMenu extends StatelessWidget {
  const EditorMenu({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
  });

  final ShapeType? selectedTool;
  final ValueChanged<ShapeType?> onToolSelected;

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: const [],
          child: const Text('Файл'),
        ),
        SubmenuButton(
          menuChildren: [
            for (final ShapeType tool in ShapeType.values)
              CheckboxMenuButton(
                value: selectedTool == tool,
                onChanged: (bool? selected) => onToolSelected(selected == true ? tool : null),
                child: Text(tool.label),
              ),
          ],
          child: const Text('Об\'єкти'),
        ),
        SubmenuButton(
          menuChildren: const [],
          child: const Text('Довідка'),
        ),
      ],
    );
  }
}
```

**canvas_shapes.dart**

```dart
import 'package:flutter/foundation.dart';

import 'shape/shape.dart';

class CanvasShapes extends ChangeNotifier {
  final List<Shape?> shapes = List.filled(126, null, growable: false);
  int _count = 0;

  bool get isFull => _count >= shapes.length;

  int get count => _count;

  void add(Shape shape) {
    if (isFull) {
      return;
    }
    shapes[_count++] = shape;
    notifyListeners();
  }
}
```

**shape_type.dart**

```dart
enum ShapeType { dot, line, rectangle, ellipse }

extension ShapeTypeLabel on ShapeType {
  String get label => switch (this) {
    ShapeType.dot => 'Крапка',
    ShapeType.line => 'Лінія',
    ShapeType.rectangle => 'Прямокутник',
    ShapeType.ellipse => 'Еліпс',
  };
}
```

**shape.dart**

```dart
import 'package:flutter/material.dart';

import 'dot_shape.dart';
import 'ellipse_shape.dart';
import 'line_shape.dart';
import 'rectangle_shape.dart';
import 'shape_type.dart';

abstract class Shape {
  const Shape({required this.start, required this.end});

  final Offset start;
  final Offset end;

  factory Shape.of(ShapeType type, {required Offset start, Offset? end}) =>
      switch (type) {
        ShapeType.dot => DotShape(start: start),
        ShapeType.line => LineShape(start: start, end: end ?? start),
        ShapeType.rectangle => RectangleShape(start: start, end: end ?? start),
        ShapeType.ellipse => EllipseShape(start: start, end: end ?? start),
      };

  void paint(Canvas canvas);

  void paintPreview(Canvas canvas);
}
```

**rectangle_shape.dart**

```dart
import 'package:flutter/material.dart';

import 'shape.dart';

class RectangleShape extends Shape {
  const RectangleShape({required super.start, required super.end});

  Rect get _rect => Rect.fromPoints(start, end);

  Paint get _fill => Paint()..color = Colors.lightBlue;

  Paint _stroke(Color color) =>
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(_rect, _fill);
    canvas.drawRect(_rect, _stroke(Colors.black));
  }

  @override
  void paintPreview(Canvas canvas) {
    canvas.drawRect(_rect, _stroke(Colors.blue));
  }
}
```

**line_shape.dart**

```dart
import 'package:flutter/material.dart';

import 'shape.dart';

class LineShape extends Shape {
  const LineShape({required super.start, required super.end});

  @override
  void paint(Canvas canvas) {
    canvas.drawLine(start, end, _stroke(Colors.black));
  }

  @override
  void paintPreview(Canvas canvas) {
    canvas.drawLine(start, end, _stroke(Colors.blue));
  }

  static Paint _stroke(Color color) =>
      Paint()
        ..color = color
        ..strokeWidth = 2;
}
```

**ellipse_shape.dart**

```dart
import 'package:flutter/material.dart';

import 'shape.dart';

class EllipseShape extends Shape {
  const EllipseShape({required super.start, required super.end});

  Rect get _rect => Rect.fromCenter(
    center: start,
    width: (end.dx - start.dx).abs() * 2,
    height: (end.dy - start.dy).abs() * 2,
  );

  Paint get _fill => Paint()..color = Colors.white;

  Paint _stroke(Color color) =>
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

  @override
  void paint(Canvas canvas) {
    canvas.drawOval(_rect, _fill);
    canvas.drawOval(_rect, _stroke(Colors.black));
  }

  @override
  void paintPreview(Canvas canvas) {
    canvas.drawOval(_rect, _stroke(Colors.blue));
  }
}
```

**dot_shape.dart**

```dart
import 'package:flutter/material.dart';

import 'shape.dart';

class EllipseShape extends Shape {
  const EllipseShape({required super.start, required super.end});

  Rect get _rect => Rect.fromCenter(
    center: start,
    width: (end.dx - start.dx).abs() * 2,
    height: (end.dy - start.dy).abs() * 2,
  );

  Paint get _fill => Paint()..color = Colors.white;

  Paint _stroke(Color color) =>
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

  @override
  void paint(Canvas canvas) {
    canvas.drawOval(_rect, _fill);
    canvas.drawOval(_rect, _stroke(Colors.black));
  }

  @override
  void paintPreview(Canvas canvas) {
    canvas.drawOval(_rect, _stroke(Colors.blue));
  }
}
```

Діаграма

Скріншоти

**Висновки:**

У лабораторній роботі отримав досвід роботи з приватними методами і полями в класах і об’єктах в мові Dart. Також отримав досвід роботи з віджетами для меню, полотна  і чекбоксів в фреймворку Flutter. Почав розробляти проєкт з функціоналом схожим на графічний редактор.
