#!/bin/bash
pactl set-sink-volume @DEFAULT_SINK@ +5%
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
[ "$vol" -gt 100 ] && pactl set-sink-volume @DEFAULT_SINK@ 100%
