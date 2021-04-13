#!/bin/bash
root_path=$(dirname $(realpath $0))
source_path="${root_path}";
build_path="${root_path}/build";
cmake "${source_path}" -B "${build_path}";
cd "${build_path}";
make;
cd -;

