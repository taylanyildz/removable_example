import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:removable_trash/custom/cusom_icon.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key? key,
    this.title,
  }) : super(key: key);

  final String? title;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Alignment> _draggableAnimation;

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

  void setPosition(DragUpdateDetails detail, Size size) {
    print(_opacity);
    setState(() {
      _dragAlignment += Alignment(
        detail.delta.dx / (size.width / 3),
        detail.delta.dy / (size.height / 3),
      );
    });
    setState(() {
      if (_dragAlignment.x > 0.4) {
        if (_trashSize <= 18.0) {
          _trashSize = _trashSize + _dragAlignment.x;
        }
        if (_rectRadius > 0) {
          _rectRadius = _rectRadius - 0.01;
          if (_rectRadius <= 0.1) _opacity = 0;
        }
      } else if (_dragAlignment.x < 0.4 && _dragAlignment.x > 0) {
        if (_trashSize > 12.0) {
          _trashSize = _trashSize - _dragAlignment.x;
        }
        if (_rectRadius < 1) {
          _rectRadius = _rectRadius + 0.01;
        }
      }
    });
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

    _controller.animateWith(simulation);
  }

  void _removeWidget() {}

  @override
  Widget build(BuildContext context) {
    print(_dragAlignment);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: _opacity,
            child: Align(
              alignment: _dragAlignment,
              child: GestureDetector(
                onPanUpdate: (detail) => setPosition(detail, size),
                onPanEnd: (detail) => _checkAnimation(detail, size),
                onPanDown: (detail) => _controller.stop(),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (rect) => RadialGradient(
                        radius: _rectRadius * 2,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                          Colors.transparent
                        ],
                        stops: [0.0, 1.0, 0.0, 0.0],
                        center: FractionalOffset(0.0, 0.0),
                      ).createShader(rect),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 200.0,
                    width: 200.0,
                    color: Colors.blue,
                  ),
                ),
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
