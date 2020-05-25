## Launch a background process and check when it ends
https://unix.stackexchange.com/questions/76717/launch-a-background-process-and-check-when-it-ends

## Result of adb shell command
https://unix.stackexchange.com/questions/386619/how-can-i-evaluate-the-result-of-an-adb-shell-command

## SQLite3
sqlite3 test.db  "create table n (id INTEGER PRIMARY KEY,f TEXT,l TEXT);"
sqlite3 test.db  "insert into n (f,l) values ('john','smith');"
sqlite3 test.db  "select f from n";

## Testing (without any devices)
At line ~132, replace the commented line with the next one
```
#CONNECTED_DEVICES=`adb devices | grep -v devices | grep device | cut -f 1`
CONNECTED_DEVICES=`cut -f 1 devices.txt`
```

Then create a file called devices.txt and type one device_id per line inside it

and then at line ~148, replace the commented line with the next one
```
#simulate_manual_reset $device &
fake_simulate_manual_reset $device &
```

And here is the definition of the fake_... function

```
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
```

## How to detect the coordinates of buttons etc
https://source.android.com/devices/input/getevent
https://gist.github.com/Ademking/e9141c8336de77c3ea1c390dc666bfaa