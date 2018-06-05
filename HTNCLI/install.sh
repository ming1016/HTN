#!/bin/sh
swift package clean
swift build -c release
cp .build/release/htn /usr/local/bin/htn
