#!/bin/sh
set -e # Exit whenever a single command fails

# Get parameters from environment
APP_NAME=${INPUT_APPLICATIONNAME:-"love-build-app"}
LOVE_VERSION=${INPUT_LOVEVERSION:-"11.3"}

# Change CWD to the Github Workspace
cd "${GITHUB_WORKSPACE}"

# If a conf.lua exists in the workspace, build dependencies with loverocks
if [ -f "conf.lua" ]; then
    loverocks deps
fi

# Generate love file
# TODO: Have as input a working directory selector
zip -r "${APP_NAME}.love" ./* -x '*.git*'
echo "::set-output name=love-filename::${APP_NAME}.love"

### macos
# Download love for macos
wget "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-macos.zip"
unzip "love-${LOVE_VERSION}-macos.zip" && rm "love-${LOVE_VERSION}-macos.zip"
# Copy Data
cp "${APP_NAME}.love" love.app/Contents/Resources/ 
# If a plist file is provided, use that
if [ -f "Info.plist" ]; then
    cp "Info.plist" love.app/Contents/
fi
mv love.app "${APP_NAME}.app"
# Setup final archives
zip -ry "${APP_NAME}_macos.zip" "${APP_NAME}.app" && rm -rf "${APP_NAME}.app"
# Export filename
echo "::set-output name=macos-filename::${APP_NAME}_macos.zip"


### Windows
# Download love for windows
wget "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win32.zip"
unzip -j "love-${LOVE_VERSION}-win32.zip" -d "${APP_NAME}_win32" && rm "love-${LOVE_VERSION}-win32.zip" 
# Copy data
cat "${APP_NAME}_win32/love.exe" "${APP_NAME}.love" > "${APP_NAME}_win32/${APP_NAME}.exe"
# Delete unneeded files
rm "${APP_NAME}_win32/love.exe"
rm "${APP_NAME}_win32/lovec.exe"
rm "${APP_NAME}_win32/love.ico"
rm "${APP_NAME}_win32/changes.txt"
rm "${APP_NAME}_win32/readme.txt"
# Setup final archive
zip -ry "${APP_NAME}_win32.zip" "${APP_NAME}_win32" && rm -rf "${APP_NAME}_win32"
# Export filename
echo "::set-output name=win32-filename::${APP_NAME}_win32.zip"
