import 'package:astral/src/rust/api/astral_wfp.dart';
import 'package:astral/src/rust/api/nt.dart';
import 'package:astral/src/rust/lib.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class WfpRuleConfig {
  String name;
  String? appPath;
  String? local;    // 本地IP或网段，格式如192.168.1.1或192.168.1.0/24
  String? remote;   // 远程IP或网段，格式如8.8.8.8或8.8.0.0/16
  String? localPort;
  String? remotePort;
  String? protocol; // 可选: tcp/udp/icmp/null
  String direction; // inbound/outbound/both
  String action;    // allow/block

  WfpRuleConfig({
    this.name = '',
    this.appPath,
    this.local,
    this.remote,
    this.localPort,
    this.remotePort,
    this.protocol,
    this.direction = 'both',
    this.action = 'block',
  });
}

class WfpPage extends StatefulWidget {
  const WfpPage({super.key});

  @override
  State<WfpPage> createState() => _WfpPageState();
}

class _WfpPageState extends State<WfpPage> {
  WfpController? _wfpController;
  bool _isBusy = false;
  List<WfpRuleConfig> _rules = [WfpRuleConfig(name: '默认规则')];

  Future<void> _startWfpController() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      if (_wfpController != null) {
        await _wfpController!.cleanup();
        _wfpController = null;
      }
      final controller = await WfpController.newInstance();
      await controller.initialize();
      final filterRules = <FilterRule>[];
      for (final r in _rules) {
        String? ntPath;
        if (r.appPath != null && r.appPath!.isNotEmpty) {
          ntPath = await getNtPath(dosPath: r.appPath!);
        }
        filterRules.add(
          FilterRule(
            name: r.name,
            appPath: ntPath,
            local: r.local,
            remote: r.remote,
            localPort: r.localPort == null ? null : int.tryParse(r.localPort!),
            remotePort: r.remotePort == null ? null : int.tryParse(r.remotePort!),
            protocol: r.protocol == null || r.protocol!.isEmpty
                ? null
                : r.protocol == 'tcp'
                    ? Protocol.tcp
                    : r.protocol == 'udp'
                        ? Protocol.udp
                        : Protocol.icmp,
            direction: r.direction == 'inbound'
                ? Direction.inbound
                : r.direction == 'outbound'
                    ? Direction.outbound
                    : Direction.both,
            action: r.action == 'allow' ? FilterAction.allow : FilterAction.block,
          ),
        );
      }
      await controller.addAdvancedFilters(rules: filterRules);
      setState(() => _wfpController = controller);
    } catch (error) {
      print('启动失败: $error');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _cleanupWfpController() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      if (_wfpController != null) {
        await _wfpController!.cleanup();
        setState(() => _wfpController = null);
      }
    } catch (error) {
      print('清理失败: $error');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Widget _buildRuleCard(int idx) {
    final rule = _rules[idx];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: rule.name,
              decoration: const InputDecoration(labelText: '规则名称'),
              onChanged: (v) => setState(() => rule.name = v),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: rule.appPath),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: '应用路径(可选)'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['exe'],
                        );
                    if (result != null && result.files.single.path != null) {
                      setState(() => rule.appPath = result.files.single.path);
                    }
                  },
                  child: const Text('选择'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: rule.local,
                    decoration: const InputDecoration(labelText: '本地IP或网段(可选)'),
                    onChanged: (v) => setState(() => rule.local = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: rule.remote,
                    decoration: const InputDecoration(labelText: '远程IP或网段(可选)'),
                    onChanged: (v) => setState(() => rule.remote = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: rule.localPort,
                    decoration: const InputDecoration(labelText: '本地端口(可选)'),
                    onChanged: (v) => setState(() => rule.localPort = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: rule.remotePort,
                    decoration: const InputDecoration(labelText: '远程端口(可选)'),
                    onChanged: (v) => setState(() => rule.remotePort = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                DropdownButton<String?>(
                  value: rule.protocol,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('任意协议')),
                    DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                    DropdownMenuItem(value: 'udp', child: Text('UDP')),
                    DropdownMenuItem(value: 'icmp', child: Text('ICMP')),
                  ],
                  onChanged: (v) => setState(() => rule.protocol = v),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: rule.direction,
                  items: const [
                    DropdownMenuItem(value: 'inbound', child: Text('入站')),
                    DropdownMenuItem(value: 'outbound', child: Text('出站')),
                    DropdownMenuItem(value: 'both', child: Text('双向')),
                  ],
                  onChanged: (v) => setState(() => rule.direction = v!),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: rule.action,
                  items: const [
                    DropdownMenuItem(value: 'allow', child: Text('允许')),
                    DropdownMenuItem(value: 'block', child: Text('阻止')),
                  ],
                  onChanged: (v) => setState(() => rule.action = v!),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      _rules.length > 1
                          ? () => setState(() => _rules.removeAt(idx))
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WFP 规则配置')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isBusy ? null : _startWfpController,
                child: const Text('启动过滤器'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isBusy ? null : _cleanupWfpController,
                child: const Text('清理过滤器'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed:
                    _isBusy
                        ? null
                        : () => setState(
                          () => _rules.add(WfpRuleConfig(name: '新规则')),
                        ),
                child: const Text('添加规则'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _rules.length,
              itemBuilder: (ctx, idx) => _buildRuleCard(idx),
            ),
          ),
        ],
      ),
    );
  }
}
