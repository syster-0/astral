import 'dart:io';

void registerUriProtocol() {
  // 获取当前exe路径
  String exePath = Platform.resolvedExecutable;

  // 注册URI协议
  Process.run('reg', [
    'add',
    'HKEY_CLASSES_ROOT\\astral',
    '/v',
    'URL Protocol',
    '/t',
    'REG_SZ',
    '/d',
    '',
    '/f',
  ]).then((ProcessResult result) {
    print('Protocol registration result: ${result.stdout}');
  });

  // 设置命令
  Process.run('reg', [
    'add',
    'HKEY_CLASSES_ROOT\\astral\\shell\\open\\command',
    '/ve',
    '/d',
    '"$exePath" "%1"',
    '/f',
  ]).then((ProcessResult result) {
    print('Command registration result: ${result.stdout}');
  });
}
