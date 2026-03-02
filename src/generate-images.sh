#!/bin/sh

for file in images/*_default.png; do
    new_file=$(echo "$file" | sed 's/_default//')
    convert "$file" -modulate 100,110,110 "$new_file"
done
