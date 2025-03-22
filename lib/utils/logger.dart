import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Logger {
  static Logger? _instance;
  late File _logFile;
  late IOSink _logSink;
  static String? _logFilePath;

  // 获取日志文件路径
  static String? get logFilePath => _logFilePath;

  // 私有构造函数
  Logger._();

  // 单例模式获取实例
  static Future<Logger> getInstance() async {
    if (_instance == null) {
      _instance = Logger._();
      await _instance!._init();
    }
    return _instance!;
  }

  // 初始化日志系统
  Future<void> _init() async {
    try {
      // 获取应用文档目录
      Directory appDocDir;
      if (Platform.isAndroid || Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else {
        // 在桌面平台上，使用应用程序的运行目录
        appDocDir = Directory(Platform.resolvedExecutable).parent;
      }

      // 创建log目录
      final logDir = Directory(path.join(appDocDir.path, 'log'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 清理旧日志文件，只保留最近10个
      await _cleanupOldLogs(logDir);

      // 使用当前时间作为文件名
      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
      final fileName = '${formatter.format(now)}.log';

      // 创建日志文件
      _logFile = File(path.join(logDir.path, fileName));
      _logFilePath = _logFile.path;

      // 打开文件流
      _logSink = _logFile.openWrite(mode: FileMode.append);

      // 记录应用启动信息
      log('应用启动', LogLevel.INFO);

      debugPrint('日志文件创建成功: $_logFilePath');
    } catch (e) {
      debugPrint('初始化日志系统失败: $e');
    }
  }

  // 清理旧日志文件，只保留最近的10个
  Future<void> _cleanupOldLogs(Directory logDir) async {
    try {
      final logFiles = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .toList();

      if (logFiles.length > 10) {
        // 按修改时间排序
        logFiles.sort((a, b) {
          return (b as File)
              .lastModifiedSync()
              .compareTo((a as File).lastModifiedSync());
        });

        // 删除旧文件
        for (int i = 10; i < logFiles.length; i++) {
          await (logFiles[i] as File).delete();
          debugPrint('已删除旧日志文件: ${logFiles[i].path}');
        }
      }
    } catch (e) {
      debugPrint('清理旧日志文件失败: $e');
    }
  }

  // 关闭日志
  Future<void> close() async {
    try {
      await _logSink.flush();
      await _logSink.close();
    } catch (e) {
      debugPrint('关闭日志文件失败: $e');
    }
  }

  // 记录日志
  void log(String message, LogLevel level) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final timeString = formatter.format(now);
    final logMessage = '[$timeString][${level.name}] $message';

    // 写入文件
    _logSink.writeln(logMessage);

    // 同时输出到控制台
    debugPrint(logMessage);
  }

  // 静态方法便于调用
  static void info(String message) async {
    final logger = await getInstance();
    logger.log(message, LogLevel.INFO);
  }

  static void debug(String message) async {
    final logger = await getInstance();
    logger.log(message, LogLevel.DEBUG);
  }

  static void warning(String message) async {
    final logger = await getInstance();
    logger.log(message, LogLevel.WARNING);
  }

  static void error(String message) async {
    final logger = await getInstance();
    logger.log(message, LogLevel.ERROR);
  }

  // 记录异常和堆栈跟踪
  static void exception(dynamic exception, [StackTrace? stackTrace]) async {
    final logger = await getInstance();
    logger.log('异常: $exception', LogLevel.ERROR);
    if (stackTrace != null) {
      logger.log('堆栈: $stackTrace', LogLevel.ERROR);
    }
  }
}

// 日志级别枚举
enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
}
