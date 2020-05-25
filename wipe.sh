#!/bin/bash

DELAY=4
PIN="1234"
DB="ACTIVITY_LOG.sqlite3"

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

ensure_db_exists(){
    # If DB doesn't exist, create it
    if [ ! -f "$DB" ]; then
        sqlite3 $DB "CREATE TABLE results (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            device TEXT, 
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, 
            result TEXT
        );"
    fi
}

log() {
    # PRAGMA busy_timeout=9000
    # Makes the process sleep (9 seconds in our case) for a specified amount of time when a table is locked. 
    # The handler will sleep multiple times until at least "busy_timeout" milliseconds of sleeping have accumulated
    sqlite3 $DB "PRAGMA busy_timeout=9000; INSERT INTO results (device, result) values ('$1', '$2');" > /dev/null
}

simulate_manual_reset() {
    # Subshell runs similar to try/catch
    (
        # The -e flag will make the subshell exit immedietely on the first error
        set -e

        echo -e "\nResetting device: $1"

        check_screen_status $1
        if [ "$screen_is_on" == 0 ]; then
            turn_screen_on $1
        fi

        disable_screen_rotation $1

        # Open settings screen
        start_intent $1 "android.settings.SETTINGS"

        # Tap on search textbox (give focus)
        tap $1 300 66
        
        # Search 'Erase'
        type_text $1 "Erase"

        # Select "Erase all data" from search results
        tap $1 300 132

        # Again select "Erase all data"
        tap $1 300 300

        # Press RESET TABLET button
        tap $1 300 945

        # Enter PIN
        type_text $1 $PIN

        # Press ERASE EVERYTHING button
        tap $1 300 215
    )

    if [ $? -ne 0 ]; then
        echo -e "\nDevice $1, FAILED TO RESET"
        log $1 "Failed to reset"
    else
        echo -e "\nDevice $1, SUCCESSFULLY RESET"
        log $1 "Successfully reset"
    fi
    exit $?
}

fake_simulate_manual_reset() {
    (
        echo -e "\nResetting device: $1"
        sleep 2
    )
    if [ $? -ne 0 ]; then
        echo -e "\nDevice $1, FAILED TO RESET"
        log $1 "Failed to reset"
    else
        echo -e "\nDevice $1, SUCCESSFULLY RESET"
        log $1 "Successfully reset"
    fi
    exit $?
}

echo -e "\nBATCH RESET: STARTING..."

CONNECTED_DEVICES=`adb devices | grep -v devices | grep device | cut -f 1`

if [ `echo "$CONNECTED_DEVICES" | wc -w` -gt 0 ]; then
    NO_OF_DEVICES=`echo "$CONNECTED_DEVICES" | wc -l`
else
    NO_OF_DEVICES=0
fi

if [ "$NO_OF_DEVICES" -gt 0 ]; then
    echo -e "\nFound $NO_OF_DEVICES connected devices"

    ensure_db_exists

    for device in $CONNECTED_DEVICES; 
    do
        simulate_manual_reset $device &
    done

    wait
    echo -e "\nBATCH RESET: COMPLETE!\n"
else
    echo -e "\nBATCH RESET: NO CONNECTED DEVICES DETECTED!\n"
fi