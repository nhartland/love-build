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
    glb_arch=$1
    glb_root_url="https://github.com/love2d/love/releases/download"
    wget "${glb_root_url}/${INPUT_LOVE_VERSION}/love-${INPUT_LOVE_VERSION}-${glb_arch}.zip"
    unzip "love-${INPUT_LOVE_VERSION}-${glb_arch}.zip" 
    rm "love-${INPUT_LOVE_VERSION}-${glb_arch}.zip" 
}

# Exports a .love file for the application to the
# path specified as an argument. e.g
# build_lovefile /path/to/new/lovefile.love
# Dependencies are handled through loverocks
build_lovefile(){
    blf_target=$1
    blf_build_dir=$(mktemp -d -t love-build-XXXXXX)
    cp -a "${INPUT_SOURCE_DIR}/." "${blf_build_dir}"
    (
        # Change to build dir (subshell to preserve cwd)
        cd "${blf_build_dir}" 
        # If the usingLoveRocks flag is set to true, build loverocks deps
        if [ "${INPUT_ENABLE_LOVEROCKS}" = true ]; then
            loverocks deps
        fi
        zip -r "application.love" ./* -x '*.git*'
    )
    mv "${blf_build_dir}/application.love" "${blf_target}"
    rm -rf "${blf_build_dir}"
}

# Exports a zipped macOS application to the
# result directory.
build_macos(){
    bm_build_dir=$(mktemp -d -t love-build-XXXXXX)
    build_lovefile "${bm_build_dir}/application.love"
    (
        # Change to build dir (subshell to preserve cwd)
        cd "${bm_build_dir}" 
        # Download love for macos
        get_love_binaries "macos"

        # Copy Data
        cp "application.love" "love.app/Contents/Resources/"
        # If a plist file is provided, use that
        if [ -f "${INPUT_SOURCE_DIR}/Info.plist" ]; then
            cp "${INPUT_SOURCE_DIR}/Info.plist" "love.app/Contents/"
        fi

        # Setup final archives
        mv "love.app" "${INPUT_APP_NAME}.app"
        zip -ry "${INPUT_APP_NAME}_macos.zip" "${INPUT_APP_NAME}.app" 
    )
    mv "${bm_build_dir}}/${INPUT_APP_NAME}_macos.zip" "${INPUT_RESULT_DIR}"
    echo "::set-output name=macos-filename::${INPUT_APP_NAME}_macos.zip"
    rm -rf "${bm_build_dir}"
}

# Exports a zipped win32 application to the
# result directory.
build_windows(){
    bw_target="${INPUT_APP_NAME}_win32"
    bw_build_dir=$(mktemp -d -t love-build-XXXXXX)
    build_lovefile "${bw_build_dir}/application.love"
    (
        # Change to build dir (subshell to preserve cwd)
        cd "${bw_build_dir}" 
        # Download love for macos
        get_love_binaries "win32"

        mv "love-${INPUT_LOVE_VERSION}-win32" "${INPUT_APP_NAME}_win32"

        # Copy data
        cat "${bw_target}/love.exe" "application.love" > "${bw_target}/${INPUT_APP_NAME}.exe"
        # Delete unneeded files
        rm "${bw_target}/love.exe"
        rm "${bw_target}/lovec.exe"
        rm "${bw_target}/love.ico"
        rm "${bw_target}/changes.txt"
        rm "${bw_target}/readme.txt"

        # Setup final archive
        zip -ry "${bw_target}.zip" "${bw_target}"
    )
    mv "${bw_build_dir}/${bw_target}.zip" "${INPUT_RESULT_DIR}"/
    echo "::set-output name=win32-filename::${bw_target}.zip"
    rm -rf "${bw_build_dir}"
}

main() {
    
    check_environment    

    echo "-- LOVE build parameters --"
    echo "App name: ${INPUT_APP_NAME}"
    echo "LOVE version: ${INPUT_LOVE_VERSION}"
    echo "---------------------------"
    echo "Source directory: ${INPUT_SOURCE_DIR}"
    echo "Result directory: ${INPUT_RESULT_DIR}"
    echo "---------------------------"
    
    # Make results directory if it does not exist
    mkdir -p "${INPUT_RESULT_DIR}"
    
    ### LOVE build ####################################################
    
    build_lovefile "${INPUT_RESULT_DIR}/${INPUT_APP_NAME}.love"
    echo "::set-output name=love-filename::${INPUT_APP_NAME}.love"
    
    ### macos build ###################################################
    
    build_macos
    build_windows 
}


main "$@"
