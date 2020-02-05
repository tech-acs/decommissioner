#!/bin/bash

uninstall_system_apps () {
    echo "Uninstalling system apps..."
    adb shell pm uninstall -k --user 0 com.abc
    adb shell pm uninstall -k --user 0 com.xyz
    echo "Done!"
}

change_device_name () {
    echo "Assigning device name..."
    adb shell settings put global device_name $1
    echo "Done!"
}

disable_developer_options() {
    adb shell settings put global development_settings_enabled 0
}

start_intent() {
    adb -s $1 shell am start -a $2
    sleep 4
}

tap() {
    adb -s $1 shell input tap $2 $3
    sleep 4
}

type_text() {
    adb -s $1 shell input keyboard text $2
    adb -s $1 shell input keyevent 66
    sleep 4
}

simulate_manual_reset() {
    # Focus on search box
    tap $1 300 66

    # Type "Erase all data"
    type_text $1 "Erase"

    # Select "Erase all data"
    tap $1 300 132

    # Again select "Erase all data"
    tap $1 300 300

    # Press RESET TABLET button
    tap $1 300 945

    # Enter PIN
    type_text $1 "1234"

    # Press ERASE EVERYTHING button
    tap $1 300 215
}

#while true; do

    echo -e "\n======== START =========="

    DEVICES=`adb devices | grep -v devices | grep device | cut -f 1`
    for device in $DEVICES; do

        echo -e "\nCleaning $device..."

        start_intent $device "android.settings.SETTINGS"

        simulate_manual_reset $device &

        echo -e "Done cleaning $device\n"
    done

    #start_intent "android.settings.SETTINGS"

    #simulate_manual_reset

    echo -e "\n======== END =========="
#done