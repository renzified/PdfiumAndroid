#!/bin/bash -i

export BUILD_ROOT="builddir"
export OUTPUT_ROOT="output"

rm -frv ${BUILD_ROOT}
rm -frv ${OUTPUT_ROOT}


# LIST OF ARCHS TO BE BUILT.
if [ -z "${BUILD_ARCHS}" ]; then
    # If no environment variable is defined, use all archs.
    BUILD_ARCHS="x86 armeabi-v7a x86_64 arm64-v8a"
fi

rm -fr libpng
git clone https://github.com/pnggroup/libpng
cd libpng
git checkout v1.6.44
cd ..

for ABI in ${BUILD_ARCHS}; do
    export BUILD_DIR=${BUILD_ROOT}/libpng/${ABI}
    rm -fr ${BUILD_DIR} &&
    cmake -B ${BUILD_DIR} -S libpng \
        -DCMAKE_ANDROID_NDK=${NDK_ROOT} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_ANDROID_ARCH_ABI=${ABI} \
        -DBUILD_SHARED_LIBS:BOOL=true \
        -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
        -DANDROID_ABI=${ABI} \
        -DCMAKE_SYSTEM_NAME=Android
    cmake --build ${BUILD_DIR} -j10

    ls -lh ${BUILD_DIR}/*.so
    mkdir -p ${OUTPUT_ROOT}/${ABI}
    cp ${BUILD_DIR}//libpng16.so output/${ABI}/libmodpng.so
done




rm -fr freetype-2.10.0.tar.gz freetype-2.10.0
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.gz
tar -xvzf freetype-2.10.0.tar.gz
export SRC_DIR=freetype-2.10.0

for ABI in ${BUILD_ARCHS}; do
    export BUILD_DIR=${BUILD_ROOT}/${SRC_DIR}/${ABI}
    rm -fr ${BUILD_DIR} &&
    cmake -B ${BUILD_DIR} -S ${SRC_DIR} \
        -DCMAKE_ANDROID_NDK=${NDK_ROOT} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_ANDROID_ARCH_ABI=${ABI} \
        -DBUILD_SHARED_LIBS:BOOL=true \
        -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
        -DANDROID_ABI=${ABI} \
        -DCMAKE_SYSTEM_NAME=Android
    cmake --build ${BUILD_DIR} -j10

    ls -lh ${BUILD_DIR}/*.so
    mkdir -p ${OUTPUT_ROOT}/${ABI}
    cp ${BUILD_DIR}/libfreetype.so output/${ABI}/libmodft2.so
done

