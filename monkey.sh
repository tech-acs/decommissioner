#!/bin/bash

monkeyrunner <<EOL
# Imports the monkeyrunner modules used by this program
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# Connects to the current device, returning a MonkeyDevice object
device = MonkeyRunner.waitForConnection()

# 
result = device.shell("am start -a android.settings.SETTINGS")

EOL