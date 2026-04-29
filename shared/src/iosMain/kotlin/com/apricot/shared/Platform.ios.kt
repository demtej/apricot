package com.apricot.shared

import platform.UIKit.UIDevice

actual fun platformName(): String =
    UIDevice.currentDevice.systemName + " " + UIDevice.currentDevice.systemVersion
