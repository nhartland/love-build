#!/bin/sh
set -e

# Debug mode
set -x

: "${INPUT_APP_NAME:?'Error: application name unset'}"
: "${INPUT_LOVE_VERSION:?'Error: love version unset'}"
: "${INPUT_SOURCE_DIR:?'Error: source directory unset'}"
: "${INPUT_BUILD_DIR:?'Error: build directory unset'}"
: "${INPUT_RESULT_DIR:?'Error: result directory unset'}"
: "${INPUT_ENABLE_LOVEROCKS:?'Error: loverocks flag unset'}"

# Shorten variables a little
AN=${INPUT_APP_NAME}
LV=${INPUT_LOVE_VERSION}

echo "GitHub Ref: ${GITHUB_REF}"

echo "-- LOVE build parameters --"
echo "App name: ${AN}"
echo "LOVE version: ${LV}"
echo "---------------------------"
echo "Source directory: ${INPUT_SOURCE_DIR}"
echo "Build directory: ${INPUT_BUILD_DIR}"
echo "Result directory: ${INPUT_RESULT_DIR}"
echo "---------------------------"

# Make results directory if it does not exist
mkdir -p "${INPUT_RESULT_DIR}"

# Change CWD to the build directory and copy source files
mkdir -p "${INPUT_BUILD_DIR}"
cp -a "${INPUT_SOURCE_DIR}/." "${INPUT_BUILD_DIR}"
cd "${INPUT_BUILD_DIR}"

### Dependencies #################################################

# If the usingLoveRocks flag is set to true, build loverocks deps
if [ "${INPUT_ENABLE_LOVEROCKS}" = true ]; then
    loverocks deps
fi

### LOVE build ####################################################

zip -r "${AN}.love" ./* -x '*.git*'
cp "${AN}.love" "${INPUT_RESULT_DIR}"/
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
mv "${AN}_macos.zip" "${INPUT_RESULT_DIR}"/
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
mv "${AN}_win32.zip" "${INPUT_RESULT_DIR}"/
# Export filename
echo "::set-output name=win32-filename::${AN}_win32.zip"
