import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingCard extends StatefulWidget {
  final ColorScheme colorScheme;
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final double hoverElevation;
  final double? maxWidth; // 添加最大宽度参数
  final double? height; // 添加最大宽度参数
  final bool enable3DEffect; // 是否启用3D效果
  final double maxRotationDegree; // 最大旋转角度
  final bool enableTranslateEffect; // 是否启用偏移效果
  final double maxTranslateDistance; // 最大偏移距离
  final double zTranslation; // Z轴偏移距离
  final bool riseOnHover; // 控制悬浮时是升起还是降下

  const FloatingCard({
    super.key,
    required this.colorScheme,
    required this.child,
    this.elevation = 4,
    this.padding = const EdgeInsets.all(16.0),
    this.duration = const Duration(milliseconds: 200),
    this.hoverElevation = 8,
    this.maxWidth,
    this.height,
    this.enable3DEffect = true, // 默认启用3D效果
    this.maxRotationDegree = 10, // 默认最大旋转角度为10度
    this.enableTranslateEffect = true, // 默认启用偏移效果
    this.maxTranslateDistance = 5, // 默认最大偏移距离为5
    this.zTranslation = 10, // 默认Z轴偏移距离为20
    this.riseOnHover = true, // 默认悬浮时升起
  });

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> {
  bool isHovered = false;
  Offset mousePosition = Offset.zero;
  final GlobalKey _cardKey = GlobalKey();

  // 获取卡片的尺寸和位置
  Rect? _getCardRect() {
    final RenderBox? renderBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        position.dx, position.dy, renderBox.size.width, renderBox.size.height);
  }

  // 计算旋转角度
  (double, double) _calculateRotation() {
    final rect = _getCardRect();
    if (rect == null) return (0, 0);

    // 计算鼠标相对于卡片中心的位置
    final centerX = rect.width / 2;
    final centerY = rect.height / 2;
    final deltaX = (mousePosition.dx - centerX) / centerX;
    final deltaY = (mousePosition.dy - centerY) / centerY;

    // 计算旋转角度，鼠标在右侧时向左倾斜（Y轴正向旋转），鼠标在下方时向上倾斜（X轴负向旋转）
    final rotateY = deltaX * widget.maxRotationDegree;
    final rotateX = -deltaY * widget.maxRotationDegree;

    return (rotateX, rotateY);
  }

  @override
  Widget build(BuildContext context) {
    // 根据是否启用3D效果计算旋转角度
    final (rotateX, rotateY) =
        isHovered && widget.enable3DEffect ? _calculateRotation() : (0.0, 0.0);

    // 根据是否启用偏移效果计算偏移距离
    final translateX = isHovered && widget.enableTranslateEffect
        ? rotateY * widget.maxTranslateDistance
        : 0.0;
    final translateY = isHovered && widget.enableTranslateEffect
        ? rotateX * widget.maxTranslateDistance
        : 0.0;

    // 根据riseOnHover决定Z轴偏移方向
    final zDirection = widget.riseOnHover ? 1.0 : -1.0;
    final translateZ = isHovered && widget.enableTranslateEffect
        ? widget.zTranslation * zDirection
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      onHover: (event) {
        if (widget.enable3DEffect || widget.enableTranslateEffect) {
          setState(() {
            mousePosition = event.localPosition;
          });
        }
      },
      cursor: SystemMouseCursors.click,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth ?? double.infinity,
          ),
          child: AnimatedContainer(
            key: _cardKey,
            duration: widget.duration,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透视效果
              // 仅当启用3D效果时应用旋转
              ..rotateX(widget.enable3DEffect ? rotateX * math.pi / 180 : 0)
              ..rotateY(widget.enable3DEffect ? rotateY * math.pi / 180 : 0)
              // 仅当启用偏移效果时应用偏移
              ..translate(translateX, translateY, translateZ),
            transformAlignment: Alignment.center,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isHovered ? widget.hoverElevation : widget.elevation,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: widget.colorScheme.primary.withOpacity(0.1),
                  hoverColor: widget.colorScheme.primary.withOpacity(0.05),
                  onTap: () {
                    // 可以添加点击事件处理
                  },
                  child: Padding(
                      padding: widget.padding,
                      child: SizedBox(
                        height: widget.height,
                        child: widget.child,
                      )),
                )),
          ),
        ),
      ),
    );
  }
}
