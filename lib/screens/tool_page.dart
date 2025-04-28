import 'dart:io';
import 'dart:math';

import 'package:astral/k/app_s/aps.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({super.key});

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  int _pid = 0;

  void dllje(int pid) {
    final exeDirectory = File(Platform.resolvedExecutable).parent.path;
    final dllPath = '$exeDirectory${Platform.pathSeparator}Ak.dll';
    injectDllToPid(pid: pid.toString(), dllPath: dllPath);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Process ID (PID)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // Store PID value when changed
            setState(() {
              _pid = int.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_pid > 0) {
              dllje(_pid);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Injected DLL to process $_pid')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid PID')),
              );
            }
          },
          child: const Text('Inject DLL'),
        ),
      ],
    );
  }
}
