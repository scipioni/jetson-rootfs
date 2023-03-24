#!/bin/bash

RELEASE=4.5.0

#sudo apt install -y libdc1394-utils libdc1394-22-dev
#sudo apt remove -y libopencv libopencv-dev libopencv-python libopencv-samples

# xavier CUDA_ARCH_BIN=7.2
CUDA="-D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_GENERATION=Auto"


mkdir -p ~/external
cd ~/external

if [ ! -d opencv-$RELEASE ]; then
	[ -f $RELEASE.tar.gz ] || wget https://github.com/opencv/opencv/archive/$RELEASE.tar.gz
	tar zxvf $RELEASE.tar.gz
fi

if [ ! -d opencv_contrib ]; then
	git clone https://github.com/opencv/opencv_contrib.git opencv_contrib
	pushd opencv_contrib
	git checkout tags/4.5.0
	popd
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

cmake \
	-D CMAKE_C_COMPILER="/usr/bin/cc" \
	-D CMAKE_CXX_COMPILER="/usr/bin/c++" \
	${CUDA} \
	-D CUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
	-D CMAKE_BUILD_TYPE=RELEASE \
	-D BUILD_LIST=core,improc,videoio,dnn,python3,cudev,dnn_objdetect,highgui,video \
	-D CMAKE_INSTALL_PREFIX=${VIRTUAL_ENV} \
	-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
	-D WITH_TBB=ON \
	-D ENABLE_PRECOMPILED_HEADERS=OFF \
	-D BUILD_PERF_TESTS=OFF \
	-D CV_TRACE=OFF \
	-D WITH_OPENEXR=OFF \
	.. && \
make -j${JOBS} install/strip

