import 'dart:io';
import 'package:astral/utils/logger.dart';
import 'package:yaml/yaml.dart';

class ConfigManager {
  final String filePath;
  final Map<String, dynamic> defaultConfig;
  late Map<String, dynamic> _config;

  ConfigManager({
    required this.filePath,
    required this.defaultConfig,
  }) : _config = Map.from(defaultConfig);

  /// 加载配置文件（如果不存在则创建默认配置）
  Future<void> load() async {
    final file = File(filePath);

    if (!await file.exists()) {
      await _createDefaultConfig();
      return;
    }

    try {
      final content = await file.readAsString();
      final yamlMap = loadYaml(content);
      _config = _mergeConfigs(_convertYaml(yamlMap));
    } catch (e) {
      // 提供更详细的错误信息并使用默认配置
      Logger.info('配置文件解析失败: $e');
      Logger.info('将使用默认配置继续运行。请检查配置文件格式是否正确。');
      _config = Map.from(defaultConfig);
    }
  }

  /// 保存当前配置到文件
  Future<void> save() async {
    final yamlString = _generateYaml();
    await File(filePath).writeAsString(yamlString);
  }

  /// 获取配置值（支持点分隔符访问嵌套字段）
  T? get<T>(String keyPath) {
    final keys = keyPath.split('.');
    dynamic value = _config;

    for (final key in keys) {
      if (value is Map && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }

    return value is T ? value : null;
  }

  /// 设置配置值（支持点分隔符访问嵌套字段）
  void set<T>(String keyPath, T value) {
    final keys = keyPath.split('.');
    dynamic current = _config;

    for (int i = 0; i < keys.length - 1; i++) {
      final key = keys[i];
      current = current.putIfAbsent(key, () => <String, dynamic>{});
    }

    // 类型转换确保值类型兼容性
    if (value is Map<String, dynamic>) {
      current[keys.last] = Map<String, Object>.from(value);
    } else if (value is List<Map<String, dynamic>>) {
      current[keys.last] =
          value.map((e) => Map<String, Object>.from(e)).toList();
    } else {
      current[keys.last] = value;
    }
  }

  /// 合并用户配置与默认配置
  Map<String, dynamic> _mergeConfigs(Map<String, dynamic> userConfig) {
    return _deepMerge(defaultConfig, userConfig);
  }

  /// 深度合并两个Map
  Map<String, dynamic> _deepMerge(
      Map<String, dynamic> base, Map<String, dynamic> override) {
    final result = Map<String, dynamic>.from(base);

    override.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          result[key] is Map<String, dynamic>) {
        result[key] = _deepMerge(result[key], value);
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  /// 转换YAML结构为Dart Map
  dynamic _convertYaml(dynamic yaml) {
    if (yaml is YamlMap) {
      return yaml.map((k, v) => MapEntry(k.toString(), _convertYaml(v)));
    }
    if (yaml is YamlList) {
      return yaml.map((e) => _convertYaml(e)).toList();
    }
    return yaml;
  }

  /// 生成YAML字符串
  String _generateYaml() {
    final buffer = StringBuffer();
    _writeMap(_config, buffer, 0);
    return buffer.toString();
  }

  /// 递归写入Map结构
  void _writeMap(Map<String, dynamic> map, StringBuffer buffer, int indent) {
    final prefix = '  ' * indent;

    map.forEach((key, value) {
      buffer.write('$prefix$key: ');

      if (value is Map<String, dynamic>) {
        buffer.writeln();
        _writeMap(value, buffer, indent + 1);
      } else if (value is List) {
        _writeList(value, buffer, indent + 1);
      } else {
        buffer.writeln(_formatValue(value));
      }
    });
  }

  /// 处理列表值
  void _writeList(List list, StringBuffer buffer, int indent) {
    final prefix = '  ' * indent;

    if (list.isEmpty) {
      buffer.writeln('[]');
      return;
    }

    buffer.writeln();
    for (final item in list) {
      buffer.write('$prefix- ');
      if (item is Map) {
        if (item.isEmpty) {
          buffer.writeln('{}');
        } else {
          buffer.writeln();
          // 注意这里使用了正确的缩进级别
          _writeMapInList(item.cast<String, dynamic>(), buffer, indent + 1);
        }
      } else if (item is List) {
        _writeList(item, buffer, indent + 1);
      } else {
        buffer.writeln(_formatValue(item));
      }
    }
  }

  /// 专门用于处理列表中的Map项，确保正确缩进
  void _writeMapInList(
      Map<String, dynamic> map, StringBuffer buffer, int indent) {
    final prefix = '  ' * indent;

    map.forEach((key, value) {
      buffer.write('$prefix$key: ');

      if (value is Map<String, dynamic>) {
        buffer.writeln();
        _writeMap(value, buffer, indent + 1);
      } else if (value is List) {
        _writeList(value, buffer, indent + 1);
      } else {
        buffer.writeln(_formatValue(value));
      }
    });
  }

  /// 格式值处理
  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is bool) return value.toString();
    return value.toString();
  }

  /// 创建默认配置文件
  Future<void> _createDefaultConfig() async {
    _config = Map.from(defaultConfig);
    await save();
  }
}
