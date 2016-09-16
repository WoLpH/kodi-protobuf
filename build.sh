#!/bin/sh

function build(){
    old_pwd="$PWD"
    addon="$1"
    package="$2"
    build=build/$addon
    dist=dist/$addon
    dest=$addon-$VERSION.zip

    function add(){
        cp -v "$@" $dist/
    }

    rm -rf "$dest" "$dist" "$build"

    pip install --ignore-installed --build $build "$package"
    version=$(find "$build/protobuf/" -name METADATA -exec grep '^Version:' {} \; \
              | awk '{print $2}')

    find $build \( \
        -iname '*.egg' \
        -or -iname '*.pyc' \
        -or -iname '*.pyo' \
        -or -iname '*.pth' \
        -or -iname '*.txt' \
        -or -iname '__pycache__' \
        -or -iname '*.egg-info' \
        -or -iname '*.$dist-info' \
    \) -print0 | xargs -0 rm -rf

    mkdir -p $dist/protobuf
    rsync -av $build/protobuf/google/ $dist/protobuf/google/

    add addon.xml
    add icon.png
    add README.rst
    add LICENSE

    # Add the version
    perl -pi -e "s/VERSION/$version/" $dist/addon.xml
    # Set the addon ID
    perl -pi -e "s/ID/$addon/" $dist/addon.xml

    cd $dist/..
    zip -r ../$dest $addon
    rm -rf $build

    cd "$old_pwd"
}

build script.module.protobuf 'protobuf<3'
build script.module.protobuf3 'protobuf<4'

