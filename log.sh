#!/bin/bash

# adb shell 'input keyboard text "1234" && echo SUCCESS || echo FAIL'
# https://unix.stackexchange.com/questions/386619/how-can-i-evaluate-the-result-of-an-adb-shell-command

# echo "$var" | wc -l
# this will count lines in $var

#sqlite3 test.db  "create table n (id INTEGER PRIMARY KEY,f TEXT,l TEXT);"
#sqlite3 test.db  "insert into n (f,l) values ('john','smith');"
#sqlite3 test.db  "select f from n";






adb shell 'input keyboard text "1234" && echo SUCCESS || echo FAIL'