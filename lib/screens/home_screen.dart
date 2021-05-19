import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:removable_trash/custom/cusom_icon.dart';
import 'package:removable_trash/widgets/removable_action.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key? key,
    this.title,
  }) : super(key: key);

  static _HomeScreenState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Scope>()?.state;

  final String? title;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _Scope extends InheritedWidget {
  _Scope({
    Key? key,
    required Widget child,
    required this.state,
  }) : super(key: key, child: child);

  final _HomeScreenState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return (oldWidget as _Scope).state != state;
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Alignment> _draggableAnimation;

  late Animation<double> _dragShaderAnimation;

  Alignment _dragAlignment = Alignment.center;

  double _trashSize = 12.0;

  double _rectRadius = 1.0;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _draggableAnimation.value;
        _trashSize = 12.0;
        _rectRadius = 1.0;
      });
    });
  }

  void checkValues(detail, int index, Size size) {
    switch (detail.runtimeType) {
      case DragUpdateDetails:
        setPosition(detail, size);
        break;
      case DragDownDetails:
        _controller.stop();
        break;
      case DragEndDetails:
        _checkAnimation(detail, size);
        break;
    }
  }

  void setPosition(DragUpdateDetails detail, Size size) {
    setState(() {
      _dragAlignment += Alignment(
        detail.delta.dx / (size.width / 3),
        detail.delta.dy / (size.height / 3),
      );
    });
    if (_dragAlignment.x >= 0 && _dragAlignment.y >= 0) {
      if (_dragAlignment.x >= 0.5 && _dragAlignment.y >= 0.7) {
        if (_trashSize <= 18.0) {
          _trashSize = _trashSize + (_dragAlignment.x + _dragAlignment.y) / 2;
        }
        if (_rectRadius > 0.1)
          _rectRadius -= (_dragAlignment.x + _dragAlignment.y) / 25;
      } else {
        _trashSize = 12;
        _opacity = 1;
        _rectRadius += (_dragAlignment.x + _dragAlignment.y) / 25;
      }
    } else {
      _trashSize = 12;
      _opacity = 1;
      _rectRadius = 1.0;
    }
  }

  void _checkAnimation(DragEndDetails detail, Size size) {
    _draggableAnimation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final pixelPerSecond = detail.velocity.pixelsPerSecond;

    final unitsPerSecondX = pixelPerSecond.dx / size.width;

    final unitsPerSecondY = pixelPerSecond.dy / size.height;

    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);

    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );
    final simulation = SpringSimulation(
      spring,
      0,
      1,
      -unitVelocity,
    );
    if (_rectRadius <= 0.1) {
      setState(() {
        _opacity = 0;
      });
    }
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _Scope(
            state: this,
            child: RemoveAciton(
              isDrag: true,
              animation: _controller,
              index: 0,
              opacity: _opacity,
              radius: _rectRadius,
              alignment: _dragAlignment,
              child: Container(
                width: 200.0,
                height: 200.0,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            right: 30.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              padding: EdgeInsets.all(_trashSize),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CustomIcon.ic_trash,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
