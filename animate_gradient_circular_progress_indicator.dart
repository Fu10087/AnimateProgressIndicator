import 'dart:math';
import 'package:flutter/material.dart';

enum ThumbStyle {
  defaultStyle,
  widget,
  none
}

class AnimateProgressIndicator extends StatefulWidget {

  AnimateProgressIndicator({
    Key key,
    this.stokeWidth = 2.0,
    @required this.radius,
    @required this.colors,
    this.stops,
    this.strokeCapRound = false,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.backgroundBorderColor,
    this.backgroundBorderWidth = 0.5,
    this.totalAngle = 2 * pi,
    this.startAngle = 0,
    this.value = 0,
    this.child,
    this.controller,

    this.thumbStyle = ThumbStyle.defaultStyle,
    this.thumbSize = 14,
    this.thumbGradient,
    this.thumbBoardGradient,
    this.thumbShadowColor,
    this.thumb,

    this.showPercentage = false,
    this.percentageTextStyle,
    this.percentageSignFontSize,

    this.animated = true,
    this.duration = const Duration(milliseconds: 900),
  })
    :
      assert(colors != null),
      assert(colors.length > 0),
      assert(controller != null),
      super(key: key);

  final ProgressController controller;

  final double stokeWidth;
  final double radius;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final double backgroundBorderWidth;
  final Color backgroundBorderColor;
  // default is 2 * pi
  final double totalAngle;
  // -pi ~ pi, default is 0
  final double startAngle;

  final List<Color> colors;
  final List<double> stops;

  final ThumbStyle thumbStyle;
  final double thumbSize;

  // thumbGradient,thumbBoardGradient,thumbShadowColor仅在thumbStyle == defaultStyle时生效
  final Gradient thumbGradient;
  final Gradient thumbBoardGradient;
  final Color thumbShadowColor;
  // 仅在 thumbStyle == widget时生效
  final Widget thumb;

  // when showPercentage == true, ignore child
  // 当 showPercentage == true，设置child无效
  final bool showPercentage;
  final Widget child;
  final bool animated;
  final TextStyle percentageTextStyle;
  final double percentageSignFontSize;

  final Duration duration;

  @override
  AnimateProgressIndicatorState createState() =>
    new AnimateProgressIndicatorState();
}

class AnimateProgressIndicatorState extends
State<AnimateProgressIndicator>
  with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  Animation<double> _animation;

  double value;
  double thumbAddingSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget child) {
            return Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(thumbAddingSize/2),
                  child: GradientCircularProgressIndicator(
                    stokeWidth: widget.stokeWidth,
                    radius: widget.radius,
                    backgroundColor: widget.backgroundColor,
                    backgroundBorderColor: widget.backgroundBorderColor,
                    backgroundBorderWidth: widget.backgroundBorderWidth,
                    colors: widget.colors,
                    stops: widget.stops,
                    value: _animation.value,
                    strokeCapRound: widget.strokeCapRound,
                    totalAngle: widget.totalAngle,
                    startAngle: widget.startAngle,
                  ),
                ),
                _buildThumbWidget()
              ],
            );
          },
        ),
        widget.showPercentage ? _buildPercentageWidget() :
        Offstage(
          offstage: widget.child == null,
          child: Container(
            width: thumbAddingSize + widget.radius * 2,
            height: thumbAddingSize + widget.radius * 2,
            alignment: Alignment.center,
            child: widget.child ?? Container()
          ),
        )
      ],
    );
  }

  Widget _buildPercentageWidget() {
    return Container(
      width: thumbAddingSize + widget.radius * 2,
      height: thumbAddingSize + widget.radius * 2,
      alignment: Alignment.center,
      child:
      RichText(
        text: TextSpan(
          text: '${(_animation.value * 100).toStringAsFixed(0)}',
          style:
          widget.percentageTextStyle ??
            TextStyle(
              color: widget.colors[0],
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
          children: [
            TextSpan(text: ' ', style: TextStyle(fontSize: 10)),
            TextSpan(
              text: '%',
              style: TextStyle(
                fontSize: widget.percentageSignFontSize ?? null,
              )
            )
          ]
        ),
      )
    );
  }

  Widget _buildThumbWidget() {

    if (widget.thumbStyle == ThumbStyle.none) {
      return Offstage();
    } else if (widget.thumbStyle == ThumbStyle.defaultStyle) {
      return Positioned(
        top: widget.radius + thumbAddingSize / 2 - widget.thumbSize / 2 -
          cos(_animation.value * widget.totalAngle + widget.startAngle) *
            (widget.radius - widget.stokeWidth / 2),
        left: widget.radius + thumbAddingSize / 2 - widget.thumbSize / 2 +
          sin(_animation.value * widget.totalAngle + widget.startAngle) *
            (widget.radius - widget.stokeWidth / 2),
        child: Offstage(
          offstage: (widget?.controller?.value ?? (widget.value ?? 0)) == 0,
          child: Container(
            width: widget.thumbSize,
            height: widget.thumbSize,
            decoration: BoxDecoration(
              gradient: widget.thumbBoardGradient ??
                LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              borderRadius: BorderRadius.circular(widget.thumbSize / 2),
              boxShadow: [
                BoxShadow(
                  color: widget.thumbShadowColor ?? Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ]
            ),
            child: Center(
              child: Container(
                width: widget.thumbSize - 2,
                height: widget.thumbSize - 2,
                decoration: BoxDecoration(
                  gradient: widget.thumbGradient ?? LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(widget.thumbSize / 2 - 1),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        top: widget.radius + thumbAddingSize / 2 - widget.thumbSize / 2 - cos(_animation.value *
          widget.totalAngle) * (widget.radius - widget.stokeWidth / 2),
        left: widget.radius + thumbAddingSize / 2 - widget.thumbSize / 2 +
          sin(_animation.value * widget.totalAngle) * (widget.radius - widget.stokeWidth / 2),
        child: Offstage(
          offstage: (widget?.controller?.value ?? (widget.value ?? 0)) == 0,
          child: Container(
            width: widget.thumbSize,
            height: widget.thumbSize,
            alignment: Alignment.center,
            child: widget.thumb ?? Container(),
          )
        ),
      );
    }
  }

  setAnimations() {
    final Animation curve = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    setState(() {
      _animation = Tween(begin: 0.0, end: value).animate(curve)
        ..addListener(() {
          setState(() {});
        });
    });
    if (widget.animated) {
      _animationController.reverse().then((value) => _animationController.forward());
    }
  }

  @override
  void initState() {
    super.initState();
    thumbAddingSize = max(widget.thumbSize - widget.stokeWidth, 0);
    widget.controller.value = widget.value ?? 0;
    value = widget.controller.value;
    _animationController = AnimationController(vsync: this, duration:
    widget.animated ? widget.duration : Duration(milliseconds: 0),
      reverseDuration: Duration(milliseconds: 0));
    final Animation curve = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animation = Tween(begin: 0.0, end: value).animate(curve)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();
    if (widget.controller != null) {
      widget.controller.addListener(_listenPercentageChanged);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animation = null;
    widget?.controller?.removeListener(_listenPercentageChanged);
    super.dispose();
  }

  void _listenPercentageChanged() {
    value = widget.controller.value;
    setAnimations();
  }
}

class ProgressController extends ValueNotifier<double> {
  ProgressController() : super(0.0);

  double get percentage => value;

  void changeValueTo(double percentage) {
    if (value == percentage) {
      value = 0;
    }
    value = percentage;
  }
}

/// 静态GradientCircularProgressIndicator来自flukit，有修改
/// flukit: ^1.0.2
/// https://github.com/flutterchina/flukit
class GradientCircularProgressIndicator extends StatelessWidget {
  GradientCircularProgressIndicator({
    Key key,
    this.stokeWidth = 2.0,
    @required this.radius,
    @required this.colors,
    this.stops,
    this.strokeCapRound = false,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.backgroundBorderColor,
    this.backgroundBorderWidth = 0.5,
    this.totalAngle = 2 * pi,
    this.startAngle = 0,
    this.value,
  }) :super(key: key);
  final double stokeWidth;
  final double radius;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final double backgroundBorderWidth;
  final Color backgroundBorderColor;
  final double totalAngle;
  final double startAngle;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    double _offset = .0;
    if (strokeCapRound) {
      _offset = asin(stokeWidth / (radius * 2 - stokeWidth));
    }
    var _colors = colors;
    if (_colors == null) {
      Color color = Theme
        .of(context)
        .accentColor;
      _colors = [color, color];
    }
    return Transform.rotate(
      angle: -pi / 2.0 - _offset + startAngle,
      child: CustomPaint(
        size: Size.fromRadius(radius),
        painter: _GradientCircularProgressPainter(
          stokeWidth: stokeWidth,
          strokeCapRound: strokeCapRound,
          backgroundColor: backgroundColor,
          backgroundBorderColor: backgroundBorderColor,
          backgroundBorderWidth: backgroundBorderWidth,
          value: value,
          total: totalAngle,
          radius: radius,
          colors: _colors,
        )),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter({this.stokeWidth: 10.0,
    this.strokeCapRound: false,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.backgroundBorderWidth,
    this.backgroundBorderColor,
    this.radius,
    this.total = 2 * pi,
    @required this.colors,
    this.stops,
    this.value});

  final double stokeWidth;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final List<Color> colors;
  final double total;
  final double radius;
  final List<double> stops;
  final double backgroundBorderWidth;
  final Color backgroundBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius != null) {
      size = Size.fromRadius(radius);
    }
    double _offset = stokeWidth / 2.0;
    double _value = (value ?? .0);
    _value = _value.clamp(.0, 1.0) * total;
    double _start = .0;

    if (strokeCapRound) {
      _start = asin(stokeWidth / (size.width - stokeWidth));
    }

    Rect rect = Offset(_offset, _offset) &
    Size(size.width - stokeWidth, size.height - stokeWidth);

    var paint = Paint()
      ..strokeCap = strokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = stokeWidth;

    // draw background arc
    if (backgroundBorderWidth != 0 && backgroundBorderColor != null) {
      paint.color = backgroundBorderColor;
      canvas.drawArc(rect, _start, total, false, paint);

      paint.color = backgroundColor;
      paint.strokeWidth = paint.strokeWidth - backgroundBorderWidth * 2;
      canvas.drawArc(rect, _start, total, false, paint);

      paint.strokeWidth = paint.strokeWidth + backgroundBorderWidth * 2;
    } else if (backgroundColor != Colors.transparent) {
      paint.color = backgroundColor;
      canvas.drawArc(rect, _start, total, false, paint);
    }

    // draw foreground arc.
    // apply gradient
    if (_value > 0) {
      paint.shader = SweepGradient(
        startAngle: 0.0,
        endAngle: _value,
        colors: colors,
        stops: stops,
      ).createShader(rect);

      canvas.drawArc(rect, _start, _value, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}