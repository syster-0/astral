import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';

class VirtualIpBoxMC extends StatelessWidget {
  const VirtualIpBoxMC({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBox(
      widthSpan: 1,
      isBorder: false,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8EBF42), // 草绿色
          border: Border.all(
            color: Color(0xFF5E7C16), // 深绿色边框
            width: 4,
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key, size: 20, color: Color(0xFF5E7C16)),
                SizedBox(width: 8),
                // 新增像素方块装饰
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF5E7C16), width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '虚拟 IP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PressStart2P', // 需在pubspec.yaml引入像素字体
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '192.168.1.1',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PressStart2P',
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
