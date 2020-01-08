#!/bin/bash

set -e
set -u

cd "`dirname "${BASH_SOURCE[0]}"`"

export LC_ALL=C

readonly TFLIB=../../lib/build/libtensorflow-lite.a

if [ ! -f ${TFLIB} ]; then
  cd ../../lib/tensorflow/
  git checkout 0438fe668efd9c3e3c3d4692f0c4af4f1dff6395 ./tensorflow/lite/tools/make/download_dependencies.sh
  ./tensorflow/lite/tools/make/download_dependencies.sh
  ./tensorflow/lite/tools/make/build_lib.sh
  git checkout HEAD ./tensorflow/lite/tools/make/download_dependencies.sh
  mkdir ../build/
  mv tensorflow/lite/tools/make/gen/*/lib/libtensorflow-lite.a ../build/
  rm -r tensorflow/lite/tools/make/gen/
  cd -
  echo "TFLite build OK!"
fi

mkdir -p ../../bin

g++ -O3 -Werror -Wall -Wextra --std=c++11 -fPIC -pthread \
  -I../../lib/tensorflow/ \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/ \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/eigen \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/absl \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/gemmlowp \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/neon_2_sse \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/farmhash/src \
  -I../../lib/tensorflow/tensorflow/lite/tools/make/downloads/flatbuffers/include \
  -o ../../bin/guess guess.cc ${TFLIB}

echo "Guess build OK!"