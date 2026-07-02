#!/bin/sh
# Launch the app with a UTF-8 locale so CocoaPods' pod install doesn't crash
# on Ruby's "Unicode Normalization not appropriate for ASCII-8BIT" error.
# Usage:  sh run_ios.sh            (runs on the default/attached device)
#         sh run_ios.sh -d <id>    (runs on a specific device)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
exec flutter run "$@"
