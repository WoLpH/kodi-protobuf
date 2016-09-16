#!/bin/sh

BUILD=build
ADDON=$(grep 'id=' addon.xml | perl -p -e 's/.*id="([^"]+)"/\1/')
DIST=dist/$ADDON
DEST=$ADDON-$VERSION.zip

rm -f $DEST
rm -rf $DIST
rm -rf $BUILD

function add(){
    cp -v "$@" $DIST/
}

pip install --ignore-installed --$BUILD $BUILD protobuf
VERSION=$(grep __version__ $BUILD/protobuf/google/protobuf/__init__.py \
          | awk -F "'" '{print $2}')

find $BUILD \( \
    -iname '*.egg' \
    -or -iname '*.pyc' \
    -or -iname '*.pyo' \
    -or -iname '*.pth' \
    -or -iname '*.txt' \
    -or -iname '__pycache__' \
    -or -iname '*.egg-info' \
    -or -iname '*.$DIST-info' \
\) -print0 | xargs -0 rm -rf

mkdir -p $DIST/protobuf
rsync -av $BUILD/protobuf/google/ $DIST/protobuf/google/

add addon.xml
add icon.png
add README.rst
add LICENSE

perl -pi -e "s/VERSION/$VERSION/" $DIST/addon.xml

cd $DIST/..
zip -r ../$DEST $ADDON
rm -rf $BUILD

