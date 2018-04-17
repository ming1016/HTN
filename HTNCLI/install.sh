#!/bin/sh
swift package clean
swift build -c release
cp .build/release/CLI /usr/local/bin/htn
