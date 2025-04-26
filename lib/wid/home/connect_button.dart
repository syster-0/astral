import 'dart:math';
import 'package:flutter/material.dart';

enum ConnectionState { idle, connecting, connected }

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  ConnectionState _state = ConnectionState.idle;
  late AnimationController _animationController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startConnection() {
    if (_state != ConnectionState.idle) return;

    setState(() {
      _state = ConnectionState.connecting;
      _progress = 0.0;
    });

    // 模拟连接过程
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _state = ConnectionState.connected;
        });
      }
    });
  }

  void _disconnect() {
    setState(() {
      _state = ConnectionState.idle;
    });
  }

  void _toggleConnection() {
    if (_state == ConnectionState.idle) {
      _startConnection();
    } else if (_state == ConnectionState.connected) {
      _disconnect();
    }
  }

  Widget _getButtonIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.idle:
        return Icon(
          Icons.power_settings_new_rounded,
          key: const ValueKey('idle_icon'),
        );
      case ConnectionState.connecting:
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * 2 * pi,
              child: const Icon(
                Icons.sync_rounded,
                key: ValueKey('connecting_icon'),
              ),
            );
          },
        );
      case ConnectionState.connected:
        return Icon(Icons.link_rounded, key: const ValueKey('connected_icon'));
    }
  }

  Widget _getButtonLabel(ConnectionState state) {
    final String text;
    switch (state) {
      case ConnectionState.idle:
        text = '连接';
      case ConnectionState.connecting:
        text = '连接中...';
      case ConnectionState.connected:
        text = '已连接';
    }

    return Text(
      text,
      key: ValueKey('label_$state'),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    );
  }

  Color _getButtonColor(ConnectionState state, ColorScheme colorScheme) {
    switch (state) {
      case ConnectionState.idle:
        return colorScheme.primary;
      case ConnectionState.connecting:
        return colorScheme.surfaceVariant;
      case ConnectionState.connected:
        return colorScheme.tertiary;
    }
  }

  Color _getButtonForegroundColor(
    ConnectionState state,
    ColorScheme colorScheme,
  ) {
    switch (state) {
      case ConnectionState.idle:
        return colorScheme.onPrimary;
      case ConnectionState.connecting:
        return colorScheme.onSurfaceVariant;
      case ConnectionState.connected:
        return colorScheme.onTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 14, // 固定高度，包含进度条高度(6px)和底部边距(8px)
            width: 180, // 固定宽度与按钮一致
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset:
                  _state == ConnectionState.connecting
                      ? Offset.zero
                      : const Offset(0, 1.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _state == ConnectionState.connecting ? 1.0 : 0.0,
                child: Container(
                  width: 180,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(
                      'progress_${_state == ConnectionState.connecting}',
                    ),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 10), // 10秒完成动画
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      // 更新进度值
                      _progress = value * 100;
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.tertiary,
                                colorScheme.primary,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 按钮
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _state != ConnectionState.idle ? 180 : 100,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed:
                    _state == ConnectionState.connecting
                        ? null
                        : _toggleConnection,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 2),
                splashColor:
                    _state != ConnectionState.idle
                        ? colorScheme.onTertiary.withAlpha(51)
                        : colorScheme.onPrimary.withAlpha(51),
                highlightElevation: 6,
                elevation: 2,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _getButtonIcon(_state),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutQuad,
                  switchOutCurve: Curves.easeInQuad,
                  child: _getButtonLabel(_state),
                ),
                backgroundColor: _getButtonColor(_state, colorScheme),
                foregroundColor: _getButtonForegroundColor(_state, colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
