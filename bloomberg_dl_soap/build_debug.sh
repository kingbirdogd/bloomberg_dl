#!/bin/bash
root_path=$(dirname $(realpath $0))
source_path="${root_path}";
build_path="${root_path}/build_debug";
cmake -DCMAKE_BUILD_TYPE=Debug "${source_path}" -B "${build_path}";
cd "${build_path}";
make;
cd -;

