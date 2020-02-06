#!/bin/bash

DELAY=4
PIN="1234"

start_intent() {
    adb -s $1 shell am start -a $2
    sleep $DELAY
}

tap() {
    adb -s $1 shell input tap $2 $3
    sleep $DELAY
}

type_text() {
    adb -s $1 shell input keyboard text $2
    # Press enter (ok button)
    adb -s $1 shell input keyevent 66
    sleep $DELAY
}

press_power_button() {
    adb -s $1 shell input keyevent 26
}

swipe_up() {
    adb -s $1 shell input touchscreen swipe 300 400 300 0
}

check_screen_status() {
    screen_is_on="$(adb -s $1 shell dumpsys input_method | grep -c "mInteractive=true")"
}

turn_screen_on() {
    press_power_button $1
    swipe_up $1
    type_text $1 $PIN
}

disable_screen_rotation() {
    adb -s $1 shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

simulate_manual_reset() {
    echo -e "\nDevice: $1"

    check_screen_status $1
    if [ "$screen_is_on" == 0 ]; then
        # echo -e "\nTurning screen on."
        turn_screen_on $1
    fi

    disable_screen_rotation $1

    # Open settings screen
    start_intent $1 "android.settings.SETTINGS"

    # Tap on search textbox (give focus)
    tap $1 300 66

    type_text $1 "Erase"

    # Select "Erase all data"
    tap $1 300 132

    # Again select "Erase all data"
    tap $1 300 300

    # Press RESET TABLET button
    tap $1 300 945

    # Enter PIN
    type_text $1 $PIN

    # Press ERASE EVERYTHING button
    tap $1 300 215

    echo -e "Resetting $1\n"
}

#while true; do

    echo -e "\nSTARTING BATCH"

    DEVICES=`adb devices | grep -v devices | grep device | cut -f 1`
    for device in $DEVICES; do
        simulate_manual_reset $device &

        #done="$(turn_screen_on $device && echo SUCCESS || echo FAIL)"
        #echo $done
        #echo "Past done"
    done

#done