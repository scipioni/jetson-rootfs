#!/bin/bash

# https://github.com/AastaNV/JEP/blob/master/script/install_opencv4.6.0_Jetson.sh

RELEASE=4.6.0
BUILD=/usr/local/src/opencv

#sudo apt install -y libdc1394-utils libdc1394-22-dev
#sudo apt remove -y libopencv libopencv-dev libopencv-python libopencv-samples

# xavier CUDA_ARCH_BIN=7.2
#CUDA="-D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_GENERATION=Auto"


mkdir -p $BUILD
cd $BUILD

if [ ! -d opencv-$RELEASE ]; then
	[ -f opencv-$RELEASE.tar.gz ] || curl -L https://github.com/opencv/opencv/archive/${RELEASE}.tar.gz -o opencv-${RELEASE}.tar.gz
	tar zxvf opencv-$RELEASE.tar.gz
fi

if [ ! -d opencv_contrib-$RELEASE ]; then
	curl -L https://github.com/opencv/opencv_contrib/archive/${RELEASE}.tar.gz -o opencv_contrib-${RELEASE}.tar.gz
	tar zxvf opencv_contrib-${RELEASE}.tar.gz
fi


cd opencv-$RELEASE
# patch -p0 --forward <<EOF
# --- cmake/FindCUDNN.cmake.orig  2020-05-21 14:37:59.191735376 +0200
# +++ cmake/FindCUDNN.cmake       2020-05-21 15:00:02.341647867 +0200
# @@ -67,6 +67,13 @@
#  if(CUDNN_INCLUDE_DIR)
#    file(READ "${CUDNN_INCLUDE_DIR}/cudnn.h" CUDNN_H_CONTENTS)
 
# +  # recent versions use a seperate version header
# +  if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version.h")
# +    file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version.h" CUDNN_VERSION_H_CONTENTS)
# +    string(APPEND CUDNN_H_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
# +    unset(CUDNN_VERSION_H_CONTENTS)
# +  endif()
# +
#    string(REGEX MATCH "define CUDNN_MAJOR ([0-9]+)" _ "${CUDNN_H_CONTENTS}")
#    set(CUDNN_MAJOR_VERSION ${CMAKE_MATCH_1} CACHE INTERNAL "")
#    string(REGEX MATCH "define CUDNN_MINOR ([0-9]+)" _ "${CUDNN_H_CONTENTS}")
# EOF

rm -fR release
mkdir -p release
cd release


JOBS=$(getconf _NPROCESSORS_ONLN)
JOBS=$(($JOBS - 1)) 

# with CUDA 10 disable cudacodec
# -D BUILD_opencv_cudacodec=OFF

# 2023
cmake \
	-D BUILD_LIST=core,improc,videoio,dnn,python3,cudev,dnn_objdetect,highgui,video \
	-D WITH_CUDA=ON \
	-D WITH_CUDNN=ON \
	-D CUDA_ARCH_BIN="7.2,8.7" \
	-D CUDA_ARCH_PTX="" \
	-D OPENCV_GENERATE_PKGCONFIG=ON \
	-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${RELEASE}/modules \
	-D WITH_GSTREAMER=ON \
	-D WITH_LIBV4L=ON \
	-D BUILD_opencv_python3=ON \
	-D BUILD_TESTS=OFF \
	-D BUILD_PERF_TESTS=OFF \
	-D BUILD_EXAMPLES=OFF \
	-D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local ..

# 2020
#cmake \
#	-D CMAKE_C_COMPILER="/usr/bin/cc" \
#	-D CMAKE_CXX_COMPILER="/usr/bin/c++" \
#	${CUDA} \
#	-D CUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
#	-D CMAKE_BUILD_TYPE=RELEASE \
#	-D BUILD_LIST=core,improc,videoio,dnn,python3,cudev,dnn_objdetect,highgui,video \
#	-D CMAKE_INSTALL_PREFIX=${VIRTUAL_ENV} \
#	-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
#	-D WITH_TBB=ON \
#	-D ENABLE_PRECOMPILED_HEADERS=OFF \
#	-D BUILD_PERF_TESTS=OFF \
#	-D CV_TRACE=OFF \
#	-D WITH_OPENEXR=OFF \
#	-D BUILD_EXAMPLES=OFF \
#	-D WITH_DC1394=OFF \
#	.. && \

make -j${JOBS} install/strip

