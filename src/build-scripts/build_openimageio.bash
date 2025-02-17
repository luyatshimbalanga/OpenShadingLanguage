#!/bin/bash

# Copyright Contributors to the Open Shading Language project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/AcademySoftwareFoundation/OpenShadingLanguage

# Install OpenImageIO

# Exit the whole script if any command fails.
set -ex

OPENIMAGEIO_REPO=${OPENIMAGEIO_REPO:=OpenImageIO/oiio}
OPENIMAGEIO_VERSION=${OPENIMAGEIO_VERSION:=master}
LOCAL_DEPS_DIR=${LOCAL_DEPS_DIR:=${PWD}/ext}
OPENIMAGEIO_SRCDIR=${OPENIMAGEIO_SRCDIR:=${LOCAL_DEPS_DIR}/OpenImageIO}
OPENIMAGEIO_BUILD_DIR=${OPENIMAGEIO_BUILD_DIR:=${OPENIMAGEIO_SRCDIR}/build}
OPENIMAGEIO_INSTALLDIR=${OPENIMAGEIO_INSTALLDIR:=${LOCAL_DEPS_DIR}/dist}
OPENIMAGEIO_CMAKE_FLAGS=${OPENIMAGEIO_CMAKE_FLAGS:=""}
OPENIMAGEIO_BUILD_TYPE=${OPENIMAGEIO_BUILD_TYPE:=Release}
OPENIMAGEIO_CXXFLAGS=${OPENIMAGEIO_CXXFLAGS:=""}
BASEDIR=$PWD
CMAKE_GENERATOR=${CMAKE_GENERATOR:="Unix Makefiles"}

if [ ! -e $OPENIMAGEIO_SRCDIR ] ; then
    git clone https://github.com/${OPENIMAGEIO_REPO} $OPENIMAGEIO_SRCDIR
fi


mkdir -p ${OPENIMAGEIO_INSTALLDIR} && true
mkdir -p ${OPENIMAGEIO_BUILD_DIR} && true

pushd $OPENIMAGEIO_SRCDIR
git fetch --all -p
git checkout $OPENIMAGEIO_VERSION --force

if [[ "$USE_SIMD" != "" ]] ; then
    OPENIMAGEIO_CMAKE_FLAGS="$OPENIMAGEIO_CMAKE_FLAGS -DUSE_SIMD=$USE_SIMD"
fi
if [[ "$DEBUG" == "1" ]] ; then
    OPENIMAGEIO_CMAKE_FLAGS="$OPENIMAGEIO_CMAKE_FLAGS -DCMAKE_BUILD_TYPE=Debug"
fi

# if [[ "$ARCH" == "windows64" ]] ; then
pushd ${OPENIMAGEIO_BUILD_DIR}
cmake .. -G "$CMAKE_GENERATOR" \
    -DCMAKE_BUILD_TYPE="$OPENIMAGEIO_BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$OPENIMAGEIO_INSTALLDIR" \
    -DPYTHON_VERSION="$PYTHON_VERSION" \
    -DCMAKE_INSTALL_LIBDIR="$OPENIMAGEIO_INSTALLDIR/lib" \
    -DCMAKE_CXX_STANDARD="$CMAKE_CXX_STANDARD" \
    $OPENIMAGEIO_CMAKE_FLAGS -DVERBOSE=1
echo "Parallel build $CMAKE_BUILD_PARALLEL_LEVEL"
time cmake --build . --target install --config ${OPENIMAGEIO_BUILD_TYPE}
popd

popd

export OpenImageIO_ROOT=$OPENIMAGEIO_INSTALLDIR
export PATH=$OpenImageIO_ROOT/bin:$PATH
export DYLD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$OpenImageIO_ROOT/lib/python${PYTHON_VERSION}/site-packages:$PYTHONPATH

echo "DYLD_LIBRARY_PATH = $DYLD_LIBRARY_PATH"
echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"
echo "OpenImageIO_ROOT $OpenImageIO_ROOT"
# ls -R $OpenImageIO_ROOT
