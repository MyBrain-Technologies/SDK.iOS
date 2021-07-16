#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"
echo $parent_path
# source "$(dirname "$0")/A.sh"

xcodebuild archive \
-scheme MyBrainTechnologiesSDK \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/MyBrainTechnologiesSDK.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


xcodebuild archive \
-scheme MyBrainTechnologiesSDK \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/MyBrainTechnologiesSDK.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


xcodebuild -create-xcframework \
-framework './build/MyBrainTechnologiesSDK.framework-iphoneos.xcarchive/Products/Frameworks/MyBrainTechnologiesSDK.framework' \
-framework './build/MyBrainTechnologiesSDK.framework-iphonesimulator.xcarchive/Products/Frameworks/MyBrainTechnologiesSDK.framework' \
-output './build/MyBrainTechnologiesSDK.xcframework'

