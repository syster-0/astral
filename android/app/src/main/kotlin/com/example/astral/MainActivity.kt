package com.example.astral

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "astral_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestRoot" -> {
                    val hasRoot = requestRootPermission()
                    result.success(hasRoot)
                }
                "checkRoot" -> {
                    val hasRoot = checkRootAccess()
                    result.success(hasRoot)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkRootAccess(): Boolean {
        return try {
            // 方法1：检查su命令是否存在
            val process = Runtime.getRuntime().exec("which su")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val result = reader.readLine()
            process.waitFor()
            reader.close()
            
            if (result != null && result.isNotEmpty()) {
                // 方法2：尝试执行su命令
                testSuCommand()
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun testSuCommand(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("su -c 'id'")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val result = reader.readLine()
            val exitCode = process.waitFor()
            reader.close()
            
            exitCode == 0 && result != null && result.contains("uid=0")
        } catch (e: Exception) {
            false
        }
    }

    private fun requestRootPermission(): Boolean {
        return try {
            // 首先检查是否已有root权限
            if (checkRootAccess()) {
                return true
            }
            
            // 尝试请求root权限
            val process = Runtime.getRuntime().exec("su")
            val writer = process.outputStream.bufferedWriter()
            writer.write("id\n")
            writer.write("exit\n")
            writer.flush()
            writer.close()
            
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val result = reader.readLine()
            val exitCode = process.waitFor()
            reader.close()
            
            exitCode == 0 && result != null && result.contains("uid=0")
        } catch (e: Exception) {
            false
        }
    }
}
