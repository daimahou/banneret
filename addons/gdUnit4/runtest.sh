#!/bin/bash

# Check for command-line argument
godot_binary=""
filtered_args=""

# Process all arguments with a more compatible approach
while [ $# -gt 0 ]; do
    if [ "$1" = "--godot_binary" ] && [ $# -gt 1 ]; then
        # Get the next argument as the value
        godot_binary="$2"
        shift 2
    else
        # Keep non-godot_binary arguments for passing to Godot
        filtered_args="$filtered_args $1"
        shift
    fi
done

# If --godot_binary wasn't provided, fallback to environment variable
if [ -z "$godot_binary" ]; then
    godot_binary="$GODOT_BIN"
fi

# Check if we have a godot_binary value from any source
if [ -z "$godot_binary" ]; then
    echo "Godot binary path is not specified."
    echo "Please either:"
    echo "  - Set the environment variable: export GODOT_BIN=/path/to/godot"
    echo "  - Or use the --godot_binary argument: --godot_binary /path/to/godot"
    exit 1
fi

# Check if the Godot binary exists and is executable
if [ ! -f "$godot_binary" ]; then
    echo "Error: The specified Godot binary '$godot_binary' does not exist."
    exit 1
fi

if [ ! -x "$godot_binary" ]; then
    echo "Error: The specified Godot binary '$godot_binary' is not executable."
    exit 1
fi

# Get Godot version and check if it's a .NET build
GODOT_VERSION=$("$godot_binary" --version)
if echo "$GODOT_VERSION" | grep -i "mono" > /dev/null; then
    echo "Godot .NET detected"
    echo "Compiling c# classes ... Please Wait"
    dotnet build --debug
    echo "done $?"
fi

# Run the tests with the filtered arguments.
# --remote-debug tcp://127.0.0.1:0 prevents Godot from activating its local interactive
# CLI debugger, which would cause an endless 'debug>' loop on script parse errors.
# Port 0 is used intentionally as it is never bound, so the connection is always refused.
# --headless is this project's, not upstream's: no suite here draws or reads back a frame, and a
# window would take the focus off whatever is in front every time a run starts. gdUnit4 refuses
# headless unless told to, because the OS delivers no InputEvent there — nothing here needs one,
# the input tests drive the `Input` singleton and hand-built events directly. A gdUnit4 upgrade
# overwrites this file, so re-apply both flags then.
"$godot_binary" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode $filtered_args
exit_code=$?
echo "Run tests ends with $exit_code"

# Run the copy log command
"$godot_binary" --headless --path . --quiet -s res://addons/gdUnit4/bin/GdUnitCopyLog.gd $filtered_args > /dev/null
exit_code2=$?
exit $exit_code
