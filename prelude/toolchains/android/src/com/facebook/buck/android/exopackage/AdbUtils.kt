/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is dual-licensed under either the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree or the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree. You may select, at your option, one of the
 * above-listed licenses.
 */

package com.facebook.buck.android.exopackage

import com.facebook.buck.core.util.log.Logger
import java.io.BufferedReader
import java.io.InputStreamReader

data class AdbCommandResult(val exitCode: Int, val output: String, val error: String? = null)

class AdbCommandFailedException(message: String) : Exception(message)

enum class SetDebugAppMode {
  SKIP,
  SET
}

class AdbUtils(val adb: String, val adbServerPort: Int) {

  fun executeAdbShellCommand(
      command: String,
      deviceId: String,
      ignoreFailure: Boolean = false
  ): String {
    return executeAdbCommand("shell $command", deviceId, ignoreFailure)
  }

  fun executeAdbCommand(
      command: String,
      deviceId: String?,
      ignoreFailure: Boolean = false
  ): String {
    val adbCommandResult: AdbCommandResult =
        try {
          runAdbCommand((deviceId?.let { "-s $deviceId " } ?: "") + command)
        } catch (e: Exception) {
          error("Failed to execute adb command 'adb $command' on device $deviceId.\n${e.message}")
        }
    return if (adbCommandResult.exitCode != 0) {
      val error =
          "Executing 'adb $command' on $deviceId failed with code ${adbCommandResult.exitCode}." +
              (adbCommandResult.error?.let { "\nError:\n$it" } ?: "")
      if (!ignoreFailure) {
        LOG.error(error)
        throw AdbCommandFailedException(error)
      } else {
        LOG.warn(error)
        adbCommandResult.output
      }
    } else {
      adbCommandResult.output
    }
  }

  private fun runAdbCommand(input: String): AdbCommandResult {
    val command = "$adb " + (if (adbServerPort != 0) "-P $adbServerPort " else "") + "$input"
    LOG.info("Running command: $command")
    val processBuilder = ProcessBuilder(*command.split(" ").toTypedArray())
    val process = processBuilder.start()
    val output = StringBuilder()
    BufferedReader(InputStreamReader(process.inputStream)).use { reader ->
      var line: String? = reader.readLine()
      while (line != null) {
        output.append(line).append("\n")
        line = reader.readLine()
      }
    }
    val errorOutput = StringBuilder()
    BufferedReader(InputStreamReader(process.errorStream)).use { reader ->
      var line: String? = reader.readLine()
      while (line != null) {
        errorOutput.append(line).append("\n")
        line = reader.readLine()
      }
    }
    val exitCode = process.waitFor()
    return AdbCommandResult(
        exitCode,
        output = output.toString().trim(),
        error = if (errorOutput.isNotEmpty()) errorOutput.toString() else null)
  }

  fun getDevices(): List<AndroidDevice> {
    val devicesOutput: String = executeAdbCommand("devices", null)
    val devices: List<String> = devicesOutput.split("\n").drop(1).filter { it.isNotBlank() }
    return if (devices.isEmpty()) {
      emptyList()
    } else {
      devices.map { AndroidDeviceImpl(it.split("\\s+".toRegex())[0], this) }
    }
  }

  fun restart() {
    executeAdbCommand("kill-server", null)
    executeAdbCommand("start-server", null)
  }

  /**
   * @return Command to register the app being installed as the system's current debug app,
   *   silencing ANRs.
   */
  fun getAmSetDebugAppCommand(packageName: String): String {

    // --persistent allows the developer to bypass ANRs on subsequent runs (i.e. if they resumed
    // debugging later after disconnecting the device and relaunching), and set
    // `Settings.Global.DEBUG_APP`. See: https://developer.android.com/studio/command-line/adb#am
    return "am set-debug-app --persistent $packageName "
  }

  companion object {
    val LOG: Logger = Logger.get(AdbUtils::class.java.name)
  }
}
