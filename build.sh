#!/bin/sh
set -e

# Check for application name
if [ -z "$INPUT_APP_NAME" ]; then
    echo "\$INPUT_APP_NAME is unspecified"
    exit 1
fi

# Check for love version
if [ -z "$INPUT_LOVE_VERSION" ]; then
    echo "\$INPUT_LOVE_VERSION is unspecified"
    exit 1
fi

# Shorten variables a little
AN=${INPUT_APP_NAME}
LV=${INPUT_LOVE_VERSION}

# Change CWD to the Github Workspace
cd "${GITHUB_WORKSPACE}"

### Dependencies #################################################

# If the usingLoveRocks flag is set to true, build loverocks deps
if [ "${INPUT_ENABLE_LOVEROCKS}" = true ]; then
    loverocks deps
fi

### LOVE build ####################################################

# TODO: Have as input a working directory selector
zip -r "${AN}.love" ./* -x '*.git*'
echo "::set-output name=love-filename::${AN}.love"

### macos build ###################################################

# Download love for macos
wget "https://bitbucket.org/rude/love/downloads/love-${LV}-macos.zip"
unzip "love-${LV}-macos.zip" && rm "love-${LV}-macos.zip"
# Copy Data
cp "${AN}.love" love.app/Contents/Resources/ 
# If a plist file is provided, use that
if [ -f "Info.plist" ]; then
    cp "Info.plist" love.app/Contents/
fi
mv love.app "${AN}.app"
# Setup final archives
zip -ry "${AN}_macos.zip" "${AN}.app" && rm -rf "${AN}.app"
# Export filename
echo "::set-output name=macos-filename::${AN}_macos.zip"

### win32 build ###################################################

# Download love for windows
wget "https://bitbucket.org/rude/love/downloads/love-${LV}-win32.zip"
unzip -j "love-${LV}-win32.zip" -d "${AN}_win32" && rm "love-${LV}-win32.zip" 
# Copy data
cat "${AN}_win32/love.exe" "${AN}.love" > "${AN}_win32/${AN}.exe"
# Delete unneeded files
rm "${AN}_win32/love.exe"
rm "${AN}_win32/lovec.exe"
rm "${AN}_win32/love.ico"
rm "${AN}_win32/changes.txt"
rm "${AN}_win32/readme.txt"
# Setup final archive
zip -ry "${AN}_win32.zip" "${AN}_win32" && rm -rf "${AN}_win32"
# Export filename
echo "::set-output name=win32-filename::${AN}_win32.zip"
