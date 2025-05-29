; 脚本由 Inno Setup 脚本向导生成。
; 有关创建 Inno Setup 脚本文件的详细信息，请参阅帮助文档！

#define MyAppName "Astral"
#define MyAppVersion "2.0.0-beta.83"
#define MyAppPublisher "kevin"
#define MyAppURL "https://astral.fan/"
#define MyAppExeName "astral.exe"
#define MyAppAssocName MyAppName + "文件"
#define MyAppAssocExt ".Astral"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; 注意：AppId 的值唯一标识此应用程序。不要在其他应用程序的安装程序中使用相同的 AppId 值。
; (若要生成新的 GUID，请在 IDE 中单击 "工具|生成 GUID"。)
AppId={9A41EC10-FBE6-4B63-8B18-A466907374B5}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
; "ArchitecturesAllowed=x64compatible" 指定安装程序无法运行
; 除 Arm 上的 x64 和 Windows 11 之外的任何平台上。
ArchitecturesAllowed=x64compatible
; "ArchitecturesInstallIn64BitMode=x64compatible" 要求
; 安装可以在 x64 或 Arm 上的 Windows 11 上以"64 位模式"完成，
; 这意味着它应该使用本机 64 位 Program Files 目录和
; 注册表的 64 位视图。
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
; 取消注释以下行以在非管理安装模式下运行 (仅为当前用户安装)。
;PrivilegesRequired=lowest
OutputBaseFilename=Astralsetup
SolidCompression=yes
WizardStyle=modern
; 支持静默安装的关键配置
DisableWelcomePage=yes
DisableReadyPage=yes
DisableFinishedPage=yes
DisableDirPage=yes
DisableReadyMemo=yes
AllowNoIcons=yes
; 支持命令行参数
SetupLogging=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "E:\astral\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\Ak.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\app_links_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\flutter_localization_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\isar.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\isar_flutter_libs_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\Packet.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\rust_lib_astral.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\sentry.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\system_tray_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\wintun.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\astral\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意：不要在任何共享系统文件上使用 "Flags: ignoreversion" 

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
