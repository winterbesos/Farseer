#!/bin/sh

set -e

if [ ! -n "$1" ]; then 
echo "Run script need scheme format is : ./script FarseerBase_iOS OUTPUT_PATH" 
exit 0 
fi 

if [ ! -n "$2" ]; then
echo "Run script need scheme format is : ./script FarseerBase_iOS OUTPUT_PATH" 
exit 0
fi

SCRIPT_DIR=$(cd `dirname $0`; pwd)
SCHEME=$1
PROJECT="$SCRIPT_DIR/Farseer_Project/SLFarseer.xcodeproj"
OUTPUT=$2

BUILD_DIR='/tmp/xcodebuild_farseer'
CONFIGURATION='Release'
SIMULATOR_SDK='iphonesimulator9.2'
DEVICE_SDK='iphoneos9.2'
SIMULATOR_VALID_ARCHS="i386 x86_64"

cd Farseer_Project
if [ ! -d "$myPath"]; then
mkdir $BUILD_DIR 
else
rm -rf $BUILD_DIR
mkdir $BUILD_DIR
fi

cd $BUILD_DIR
mkdir x86_64
mkdir i386
mkdir arm64
mkdir armv7

X86_64_BUILD_PRODUCT_DIR="$BUILD_DIR/x86_64"
xcodebuild -project $PROJECT -sdk $SIMULATOR_SDK -scheme $SCHEME -arch 'x86_64' VALID_ARCHS="$SIMULATOR_VALID_ARCHS" -configuration $CONFIGURATION TARGET_BUILD_DIR=$X86_64_BUILD_PRODUCT_DIR BUILT_PRODUCTS_DIR=$X86_64_BUILD_PRODUCT_DIR

I386_BUILD_PRODUCT_DIR="$BUILD_DIR/i386"
xcodebuild -project $PROJECT -sdk $SIMULATOR_SDK -scheme $SCHEME -arch 'i386' VALID_ARCHS="$SIMULATOR_VALID_ARCHS" -configuration $CONFIGURATION TARGET_BUILD_DIR=$I386_BUILD_PRODUCT_DIR BUILT_PRODUCTS_DIR=$I386_BUILD_PRODUCT_DIR

ARM64_BUILD_PRODUCT_DIR="$BUILD_DIR/arm64"
xcodebuild -project $PROJECT -sdk $DEVICE_SDK -scheme $SCHEME -arch 'arm64' -configuration $CONFIGURATION TARGET_BUILD_DIR=$ARM64_BUILD_PRODUCT_DIR BUILT_PRODUCTS_DIR=$ARM64_BUILD_PRODUCT_DIR

ARMV7_BUILD_PRODUCT_DIR="$BUILD_DIR/armv7"
xcodebuild -project $PROJECT -sdk $DEVICE_SDK -scheme $SCHEME -arch 'armv7' -configuration $CONFIGURATION TARGET_BUILD_DIR=$ARMV7_BUILD_PRODUCT_DIR BUILT_PRODUCTS_DIR=$ARMV7_BUILD_PRODUCT_DIR

cp -r $ARM64_BUILD_PRODUCT_DIR/${SCHEME}.framework $BUILD_DIR/${SCHEME}.framework

LIB_DIR="${SCHEME}.framework/${SCHEME}"
X86_64="$X86_64_BUILD_PRODUCT_DIR/${LIB_DIR}"
I386="$I386_BUILD_PRODUCT_DIR/${LIB_DIR}"
ARMV7="$ARMV7_BUILD_PRODUCT_DIR/${LIB_DIR}"
ARM64="$ARM64_BUILD_PRODUCT_DIR/${LIB_DIR}"
FAT_LIB_DIR="$BUILD_DIR/${SCHEME}.framework"


lipo -create $X86_64 $I386 $ARMV7 $ARM64 -output "$FAT_LIB_DIR/$SCHEME"
mv $FAT_LIB_DIR $OUTPUT
rm -rf $BUILD_DIR
