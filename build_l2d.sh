#!/bin/sh
# TODO: Build the love2d package with loverocks
# loverocks deps

# Default values
APP_NAME=${APP_NAME:-"love-build-app"}
LOVE_VERSION=${LOVE_VESION:-"11.3"}


# Generate love file
zip -r "./${APP_NAME}.love" ./*

# Make macos app
wget "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-macos.zip"
unzip "love-${LOVE_VERSION}-macos.zip"
cp Info.plist love.app/Contents/
cp "${APP_NAME}.love" love.app/Contents/Resources/
mv love.app "${APP_NAME}.app"

# Make windows package
wget "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win32.zip"
unzip -j "love-${LOVE_VERSION}-win32.zip" -d "${APP_NAME}_win32"
cat "${APP_NAME}_win32/love.exe" "${APP_NAME}.love" >  "${APP_NAME}_win32/${APP_NAME}.exe"
rm "${APP_NAME}_win32/love.exe"
rm "${APP_NAME}_win32/lovec.exe"
rm "${APP_NAME}_win32/love.ico"
rm "${APP_NAME}_win32/changes.txt"
rm "${APP_NAME}_win32/readme.txt"

#Cleanup
rm ./*.zip

# Setup final archives
zip -ry "${APP_NAME}_macos.zip" "${APP_NAME}.app"
zip -ry "${APP_NAME}_win32.zip" "${APP_NAME}_win32"

# Copy to release dir
mkdir release
mv ./*.zip release
mv ./*.love release

#Cleanupv2
rm -rf "${APP_NAME}.app"
rm -rf "${APP_NAME}_win32"
