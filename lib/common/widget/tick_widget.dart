import 'package:flutter/material.dart';

class TickWidget extends StatefulWidget {
  final Duration tickTime;
  final VoidCallback onTickEnd;
  final Widget Function(Duration) childBuilder;

  TickWidget({Key key, this.tickTime, this.onTickEnd, this.childBuilder}) : super(key: key);

  @override
  _BreakTimeState createState() => _BreakTimeState();
}

class _BreakTimeState extends State<TickWidget> with TickerProviderStateMixin {
  Widget child;
  Tween<Duration> tween;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  void didUpdateWidget(TickWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickTime == widget.tickTime) return;
    controller.reset();
    initAnimation();
  }

  void initAnimation() {
    controller = AnimationController(vsync: this, duration: widget.tickTime);
    tween = Tween(begin: Duration.zero, end: widget.tickTime);
    Animation<Duration> animation = tween.animate(controller);
    if (widget.onTickEnd != null) {
      controller.addStatusListener(
            (status) {
          if (status == AnimationStatus.completed) widget.onTickEnd();
        },
      );
    }
    controller.addListener(() {
      setState(() {
        child = widget
            .childBuilder(Duration(milliseconds: widget.tickTime.inMilliseconds - animation.value.inMilliseconds));
      });
    });
    child = widget.childBuilder(Duration.zero);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
