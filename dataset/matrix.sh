
#!/bin/bash

set -e
set -u

cd "`dirname "${BASH_SOURCE[0]}"`"

export LC_ALL=C

readonly DATASET_FILE_NAME=$1
readonly DATASET_NUM_OUTPUT=$2

bash ./../src/brain/build.sh

do_confusion_matrix() {
  local model=$1
  local i
  for i in `seq ${DATASET_NUM_OUTPUT}` ; do
    awk -v m="${DATASET_NUM_OUTPUT}" '$1 >= m' "${DATASET_FILE_NAME}" \
      | awk -v i="${i}" -v m="${DATASET_NUM_OUTPUT}" '$1 == i - 1 + m || $1 == i - 1 + 2*m' \
      | awk '{for(i=2;i<=NF;i++){if(i>2)printf " ";printf $i} print ""}' \
      | ./../bin/guess "./../models/${model}" \
      | awk '{m=$1;j=1;for(i=j;i<=NF;i++)if($i>m){m=$i;j=i;} for(i=1;i<=NF;i++){if(i>1)printf " ";printf "%d", i==j} print ""}' \
      | awk '{for(i=1;i<=NF;i++)sum[i]+=$i} END {for(j=1;j<i;j++){if(j>1)printf " ";printf "%.2f", sum[j]/NR} print " | " NR}'
  done
}

do_validation() {
  local model=$1
  local i
  for i in `seq ${DATASET_NUM_OUTPUT}` ; do
    awk -v m="${DATASET_NUM_OUTPUT}" '$1 >= m' "${DATASET_FILE_NAME}" \
      | awk -v i="${i}" -v m="${DATASET_NUM_OUTPUT}" '$1 == i - 1 + m || $1 == i - 1 + 2*m' \
      | awk '{for(i=2;i<=NF;i++){if(i>2)printf " ";printf $i} print ""}' \
      | ./../bin/guess "./../models/${model}" \
      | awk -v x="${i}" '{m=$1;j=1;for(i=j;i<=NF;i++)if($i>m){m=$i;j=i;} if(j!=x)print x}'
  done
}

do_all() {
  local title=$1
  local model=$2
  echo "${title} confusion matrix..."
  do_confusion_matrix ${model} 2> >(grep -v "INFO: Initialized TensorFlow Lite runtime.")
  echo "${title} guessed wrong `do_validation ${model} 2> >(grep -v "INFO: Initialized TensorFlow Lite runtime.") | wc -l`..."
}

do_all 'MLP' 'mlp.tflite'
do_all 'CNN' 'cnn.tflite'
do_all 'RNN' 'rnn.tflite'