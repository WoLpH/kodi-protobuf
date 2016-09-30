#!/bin/sh -e

function build(){
    old_pwd="$PWD"
    name="$1"
    package="$2"
    addon="script.module.$name"
    build=build/$addon
    dist=dist/$addon

    function add(){
        cp -v "$@" $dist/
    }

    rm -rf "$dist" "$build"

    pip install --ignore-installed --build $build "$package"
    version=$(find "$build/protobuf/" -name METADATA -exec grep '^Version:' {} \; \
              | awk '{print $2}')

    dest=$addon-$version.zip
    rm -rf "$dest"

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

    mkdir -p $dist/$name
    touch $build/protobuf/google/__init__.py
    rsync -av $build/protobuf/google/ $dist/$name/google/

    add addon.xml
    add icon.png
    add README.rst
    add LICENSE

    # Add the version
    perl -pi -e "s/VERSION/$version/" $dist/addon.xml
    # Set the addon ID
    perl -pi -e "s/ID/$addon/" $dist/addon.xml
    # Update the name
    perl -pi -e "s/NAME/$name/" $dist/addon.xml
    # Update the requirements

    if [ "$name" = "protobuf3" ]; then
        requires='<import addon="script.module.six" version="1.9.0" \/>'
    else
        requires=''
    fi
    perl -pi -e "s/REQUIRES/$requires/" $dist/addon.xml

    cd $dist/..
    zip -r ../$dest $addon
    rm -rf $build

    cd "$old_pwd"
}

build protobuf 'protobuf<3'
build protobuf3 'protobuf<4'

