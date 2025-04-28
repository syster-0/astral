use std::env;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

pub fn inject_dll_to_pid(pid: &str, dll_path: &Path) {
    if !dll_path.exists() {
        println!("错误: 找不到DLL文件: {:?}", dll_path);
        return;
    }

    let status = Command::new("powershell")
        .args([
            "-Command",
            &format!(
                "Add-Type -TypeDefinition @\" 
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class Injector {{
    [DllImport(\"kernel32.dll\")]
    public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    
    [DllImport(\"kernel32.dll\")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
    
    [DllImport(\"kernel32.dll\")]
    public static extern IntPtr GetModuleHandle(string lpModuleName);
    
    [DllImport(\"kernel32.dll\")]
    public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    
    [DllImport(\"kernel32.dll\")]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out UIntPtr lpNumberOfBytesWritten);
    
    [DllImport(\"kernel32.dll\")]
    public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    
    [DllImport(\"kernel32.dll\")]
    public static extern bool CloseHandle(IntPtr hObject);

    public static void Inject(int pid, string dllPath) {{
        IntPtr hProcess = OpenProcess(0x1F0FFF, false, pid);
        if (hProcess == IntPtr.Zero) {{
            Console.WriteLine(\"无法打开进程 (PID: {{0}})\", pid);
            return;
        }}
        byte[] dllPathBytes = System.Text.Encoding.ASCII.GetBytes(dllPath + \"\\0\");
        IntPtr allocMemAddress = VirtualAllocEx(hProcess, IntPtr.Zero, (uint)dllPathBytes.Length, 0x1000 | 0x2000, 0x40);
        if (allocMemAddress == IntPtr.Zero) {{
            Console.WriteLine(\"内存分配失败\");
            CloseHandle(hProcess);
            return;
        }}
        UIntPtr bytesWritten;
        if (!WriteProcessMemory(hProcess, allocMemAddress, dllPathBytes, (uint)dllPathBytes.Length, out bytesWritten)) {{
            Console.WriteLine(\"写入内存失败\");
            CloseHandle(hProcess);
            return;
        }}
        IntPtr loadLibraryAddr = GetProcAddress(GetModuleHandle(\"kernel32.dll\"), \"LoadLibraryA\");
        if (loadLibraryAddr == IntPtr.Zero) {{
            Console.WriteLine(\"无法获取LoadLibraryA地址\");
            CloseHandle(hProcess);
            return;
        }}
        IntPtr hThread = CreateRemoteThread(hProcess, IntPtr.Zero, 0, loadLibraryAddr, allocMemAddress, 0, IntPtr.Zero);
        if (hThread == IntPtr.Zero) {{
            Console.WriteLine(\"创建远程线程失败\");
            CloseHandle(hProcess);
            return;
        }}
        Console.WriteLine(\"DLL成功注入到进程 {{0}}\", pid);
        CloseHandle(hThread);
        CloseHandle(hProcess);
    }}
}}
\"@; [Injector]::Inject({}, \"{}\")",
                pid,
                dll_path.to_string_lossy().replace("\\", "\\\\")
            )
        ])
        .status()
        .expect("注入命令执行失败");

    if status.success() {
        println!("注入过程已完成");
    } else {
        println!("注入过程失败，退出代码: {:?}", status.code());
    }
}
