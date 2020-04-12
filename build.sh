#!/bin/sh
set -e

# Debug mode
if [ "${GITHUB_REPOSITORY}" = "nhartland/love-build" ]; then
    set -x
fi

check_environment() {
    : "${INPUT_APP_NAME:?'Error: application name unset'}"
    : "${INPUT_LOVE_VERSION:?'Error: love version unset'}"
    : "${INPUT_SOURCE_DIR:?'Error: source directory unset'}"
    : "${INPUT_RESULT_DIR:?'Error: result directory unset'}"
    : "${INPUT_ENABLE_LOVEROCKS:?'Error: loverocks flag unset'}"
}

get_love_binaries() {
    version=$1
    arch=$2
    root_url="https://github.com/love2d/love/releases/download"
    wget "${root_url}/${version}/love-${version}-${arch}.zip"
    unzip "love-${version}-${arch}.zip" -d "love_${arch}"
    rm "love-${version}-${arch}.zip" 
}

# Exports a .love file for the application to the
# path specified as an argument. e.g
# build_lovefile /path/to/new/lovefile.love
# Dependencies are handled through loverocks
build_lovefile(){
    target=$1
    build_dir=$(mktemp -d -t love-build-XXXXXX)
    cp -a "${INPUT_SOURCE_DIR}/." "${build_dir}"
    (
        # Change to build dir (subshell to preserve cwd)
        cd "${build_dir}" 
        # If the usingLoveRocks flag is set to true, build loverocks deps
        if [ "${INPUT_ENABLE_LOVEROCKS}" = true ]; then
            loverocks deps
        fi
        zip -r "application.love" ./* -x '*.git*'
    )
    mv "${build_dir}/application.love" "${target}"
    rm -rf "${build_dir}"
}

# Exports a zipped macOS application to the
# result directory.
build_macos(){
    build_dir=$(mktemp -d -t love-build-XXXXXX)
    build_lovefile "${build_dir}/application.love"
    (
        # Change to build dir (subshell to preserve cwd)
        cd "${build_dir}" 
        # Download love for macos
        get_love_binaries "${INPUT_LOVE_VERSION}" "macos"
        # Copy Data
        cp "application.love" "love_macos/Contents/Resources/ "
        # If a plist file is provided, use that
        if [ -f "${INPUT_SOURCE_DIR}/Info.plist" ]; then
            cp "${INPUT_SOURCE_DIR}/Info.plist" "love_macos/Contents/"
        fi
        # Setup final archives
        mv "love_macos" "${INPUT_APP_NAME}.app"
        zip -ry "${INPUT_APP_NAME}_macos.zip" "${INPUT_APP_NAME}.app" 
        mv "${INPUT_APP_NAME}_macos.zip" "${INPUT_RESULT_DIR}"
    )
    # Cleanup build directory
    rm -rf "${build_dir}"
    # Export filename
    echo "::set-output name=macos-filename::${AN}_macos.zip"
}

main() {
    
    check_environment    

    # Shorten variables a little
    AN=${INPUT_APP_NAME}
    LV=${INPUT_LOVE_VERSION}
    
    echo "-- LOVE build parameters --"
    echo "App name: ${AN}"
    echo "LOVE version: ${LV}"
    echo "---------------------------"
    echo "Source directory: ${INPUT_SOURCE_DIR}"
    echo "Result directory: ${INPUT_RESULT_DIR}"
    echo "---------------------------"
    
    # Make results directory if it does not exist
    mkdir -p "${INPUT_RESULT_DIR}"
    
    # Change CWD to the build directory and copy source files
    BUILD_DIR=$(mktemp -d -t love-build-XXXXXX)
    cd "${BUILD_DIR}"
    
    ### LOVE build ####################################################
    
    build_lovefile "${AN}.love"
    cp "${AN}.love" "${INPUT_RESULT_DIR}"/
    echo "::set-output name=love-filename::${AN}.love"
    
    ### macos build ###################################################
    
    build_macos
    
    ### win32 build ###################################################
    
    # Download love for windows
    get_love_binaries "${LV}" "win32"
    mv "love_win32" "${AN}_win32"
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
}


main "$@"
