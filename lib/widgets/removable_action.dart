import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:removable_trash/screens/home_screen.dart';

const bool cDrag = false;

abstract class RemovableToTrashAction extends StatelessWidget {
  RemovableToTrashAction({
    Key? key,
    required this.animation,
    required this.index,
    required this.opacity,
    required this.radius,
    this.isDrag = cDrag,
    this.alignment = Alignment.center,
  }) : super(key: key);

  final int index;

  final bool isDrag;

  final Alignment alignment;

  final Animation animation;

  final double radius;

  final double opacity;

  void handlerChangePosition(
      BuildContext context, detail, int index, Size size) {
    HomeScreen.of(context)?.checkValues(detail, index, size);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      ignoring: !isDrag,
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: alignment,
          child: GestureDetector(
            onPanUpdate: !isDrag
                ? null
                : (detail) =>
                    handlerChangePosition(context, detail, index, size),
            onPanDown: !isDrag
                ? null
                : (detail) =>
                    handlerChangePosition(context, detail, index, size),
            onPanEnd: !isDrag
                ? null
                : (detail) =>
                    handlerChangePosition(context, detail, index, size),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (rect) => RadialGradient(
                          radius: radius * 2.0,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: [0.0, 1.0, 0.0, 1.0],
                          center: FractionalOffset(0.0, 0.0))
                      .createShader(rect),
                  child: child,
                );
              },
              child: buildAction(context),
            ),
          ),
        ),
      ),
    );
  }

  @protected
  Widget buildAction(BuildContext context);
}

class RemoveAciton extends RemovableToTrashAction {
  RemoveAciton({
    Key? key,
    required this.animation,
    required this.index,
    required this.opacity,
    required this.radius,
    this.isDrag = cDrag,
    required this.alignment,
    required this.child,
  }) : super(
          key: key,
          animation: animation,
          index: index,
          radius: radius,
          opacity: opacity,
          isDrag: isDrag,
          alignment: alignment,
        );

  final int index;

  final Alignment alignment;

  final Animation animation;

  final bool isDrag;

  final double radius;

  final double opacity;

  final Widget child;

  @override
  Widget buildAction(BuildContext context) => child;
}
