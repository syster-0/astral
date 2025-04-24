import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimeDisplayBox extends StatefulWidget {
  const TimeDisplayBox({super.key});

  @override
  State<TimeDisplayBox> createState() => _TimeDisplayBoxState();
}

class _TimeDisplayBoxState extends State<TimeDisplayBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late DateTime _currentTime;
  final List<SandParticle> _particles = [];
  final int _particleCount = 50;
  final Size _boxSize = const Size(200, 100); // 明确定义容器大小

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );

    _currentTime = DateTime.now();

    // 创建沙粒子
    _initializeParticles();

    // 使用Ticker而不是直接setState
    _controller.addListener(_onAnimationUpdate);
    _controller.repeat();

    // 每秒更新一次时间
    _startTimer();
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        SandParticle(
          position: Offset(
            math.Random().nextDouble() * _boxSize.width,
            -20 - math.Random().nextDouble() * 50,
          ),
          velocity: Offset(
            math.Random().nextDouble() * 2 - 1,
            math.Random().nextDouble() * 5 + 2,
          ),
          color: Color.fromARGB(
            255,
            200 + math.Random().nextInt(55),
            180 + math.Random().nextInt(75),
            120 + math.Random().nextInt(60),
          ),
          size: 2 + math.Random().nextDouble() * 3,
        ),
      );
    }
  }

  void _onAnimationUpdate() {
    if (!mounted) return;

    for (var particle in _particles) {
      particle.update();

      // 如果粒子落到底部，重新从顶部开始
      if (particle.position.dy > _boxSize.height) {
        particle.position = Offset(
          math.Random().nextDouble() * _boxSize.width,
          -20 - math.Random().nextDouble() * 10,
        );
        particle.velocity = Offset(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 5 + 2,
        );
      }

      // 边界限制
      if (particle.position.dx < 0) {
        particle.position = Offset(0, particle.position.dy);
        particle.velocity = Offset(
          -particle.velocity.dx * 0.5,
          particle.velocity.dy,
        );
      } else if (particle.position.dx > _boxSize.width) {
        particle.position = Offset(_boxSize.width, particle.position.dy);
        particle.velocity = Offset(
          -particle.velocity.dx * 0.5,
          particle.velocity.dy,
        );
      }
    }

    // 使用安全的方式刷新UI
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _startTimer();
      }
    });
  }

  void _onTap(TapDownDetails details) {
    // 使用安全的方式处理点击
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final tapPosition = details.localPosition;
      final newParticles = <SandParticle>[];

      for (int i = 0; i < 10; i++) {
        newParticles.add(
          SandParticle(
            position: tapPosition,
            velocity: Offset(
              math.Random().nextDouble() * 8 - 4,
              math.Random().nextDouble() * -5 - 2,
            ),
            color: Color.fromARGB(
              255,
              220 + math.Random().nextInt(35),
              200 + math.Random().nextInt(55),
              100 + math.Random().nextInt(50),
            ),
            size: 2 + math.Random().nextDouble() * 4,
          ),
        );
      }

      setState(() {
        _particles.addAll(newParticles);
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        "${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}";

    return HomeBox(
      widthSpan: 1,
      isBorder: false,
      child: GestureDetector(
        onTapDown: _onTap,
        child: Container(
          width: double.infinity, // 确保容器有明确的宽度
          height: 120, // 明确设置高度
          decoration: BoxDecoration(
            color: const Color(0xFF3A4C78), // 深蓝色
            border: Border.all(
              color: const Color(0xFF1A2A5A), // 边框颜色
              width: 4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 使用LayoutBuilder获取实际尺寸
              final actualWidth = constraints.maxWidth;
              final actualHeight = constraints.maxHeight;

              return CustomPaint(
                size: Size(actualWidth, actualHeight),
                painter: SandPainter(
                  particles: _particles,
                  time: formattedTime,
                ),
                child: Stack(
                  children: [
                    // 时间文字 - 使用Positioned.fill确保正确定位
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3.0,
                                color: Color.fromARGB(150, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 顶部小装饰
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              3,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// 使用CustomPainter绘制沙粒，避免大量Positioned元素导致的布局问题
class SandPainter extends CustomPainter {
  final List<SandParticle> particles;
  final String time;

  SandPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制所有沙粒
    for (var particle in particles) {
      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(SandPainter oldDelegate) {
    return true; // 由于粒子不断移动，所以每帧都需要重绘
  }
}

class SandParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  SandParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update() {
    // 添加重力和一些随机扰动
    velocity += const Offset(0, 0.1);
    // 添加一点随机横向移动
    velocity += Offset((math.Random().nextDouble() - 0.5) * 0.1, 0);

    position += velocity;
  }
}
