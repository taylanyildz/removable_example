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

  bool isDelete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        if (!isDelete) {
          _dragAlignment = _draggableAnimation.value;
          isDelete = false;
        } else {
          _dragAlignment = Alignment.center;
        }

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
        _checkAnimation(detail, size, index);
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
          _rectRadius -= (_dragAlignment.x + _dragAlignment.y) / 75;
      } else {
        _trashSize = 12;
        _rectRadius += (_dragAlignment.x + _dragAlignment.y) / 75;
      }
    } else {
      _trashSize = 12;
      _rectRadius = 1.0;
    }
  }

  void _checkAnimation(DragEndDetails detail, Size size, int index) {
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
    if (_rectRadius <= 0.1) {
      _opacity = 0;
      // final child = childs.removeAt(index);
      // childs.insert(0, child);
      childs.removeAt(index);
      isDelete = true;
    }
  }

  final childs = <Widget>[
    Container(
      color: Colors.blue,
      width: 200.0,
      height: 200.0,
      child: Center(
        child: Text(
          'Kutlu olsun',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
      ),
    ),
    Container(
      color: Colors.orange,
      width: 200.0,
      height: 200.0,
      child: Center(
        child: Text(
          'Spor Bayramı',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
      ),
    ),
    Container(
      color: Colors.red,
      width: 200.0,
      height: 200.0,
      child: Center(
        child: Text(
          'Gençlik\nve',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(childs.length);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/ataturk.jpg',
              fit: BoxFit.cover,
            ),
          ),
          _Scope(
            state: this,
            child: Stack(
              children: childs
                  .map(
                    (e) => Transform.translate(
                      offset: Offset(
                        childs.indexOf(e).toDouble() * 10,
                        childs.indexOf(e).toDouble() * 10,
                      ),
                      child: RemoveAciton(
                        isDrag: childs.indexOf(e) == childs.length - 1
                            ? true
                            : false,
                        animation: _controller,
                        index: childs.indexOf(e),
                        opacity:
                            childs.indexOf(e) == childs.length ? _opacity : 1,
                        radius: childs.indexOf(e) == childs.length - 1
                            ? _rectRadius
                            : 1,
                        alignment: childs.indexOf(e) == childs.length - 1
                            ? _dragAlignment
                            : Alignment.center,
                        child: e,
                      ),
                    ),
                  )
                  .toList(),
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
          ),
          Positioned(
            left: 0,
            right: 0.0,
            bottom: 100.0,
            child: Center(
              child: Text(
                'MUSTAFA KEMAL ATATURK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
