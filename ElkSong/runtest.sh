#!/bin/bash

# Godot gdUnit4 test runner script
export GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
cd "$(dirname "$0")"

echo "Running gdUnit4 tests..."
"${GODOT_BIN}" --headless --cfg-file ./addons/gdUnit4/runtest.sh
