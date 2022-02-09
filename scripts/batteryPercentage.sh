#!/bin/bash
acpi -b | head -n1 | awk 'match($0, /([0-9]+)%/) { print substr($0, RSTART, RLENGTH) }'
