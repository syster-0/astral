import 'package:astral/k/app_s/Aps.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('网络设置'),
              ),
              SwitchListTile(
                title: const Text('是否启用加密'),
                subtitle: const Text('会自动设置MTU'),
                value: Aps().enableEncryption.watch(context),
                onChanged: (value) {
                  Aps().updateEnableEncryption(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
