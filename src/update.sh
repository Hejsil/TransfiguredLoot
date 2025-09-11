#!/bin/sh

zig build
sleep 5

up="103:1 103:0"
down="108:1 108:0"
left="105:1 105:0"
right="106:1 106:0"
enter="28:1 28:0"

# Menu menu -> options
ydotool key $down $down $down $down $up $enter
sleep 1

# Menu options -> mods
ydotool key $left $down $enter
sleep 1

# Menu disable, enable then apply
ydotool key $enter $right $right $enter $left $left $left $left $enter
sleep 10

# Press any key
ydotool key $enter
sleep 1

# Menu menu -> options
ydotool key $down $down $down $down $up $enter
sleep 1

# Menu options -> mods
ydotool key $left $down $enter
sleep 1

last_mod=24
seq 0 "$last_mod" | while read -r i; do
    echo "$i/$last_mod" >&2

    # Start at first mod
    ydotool key $left $left

    # Go down to mod
    yes $down | head -n$i | tr '\n' ' ' | xargs -r ydotool key

    # Enter mod
    ydotool key $enter
    sleep 1

    # Go down to upload button and hold it
    ydotool key $right $right $right $right $right $right $right $right $right $right $right $right $left
    ydotool key -d 2100 $enter
    sleep 4
done
