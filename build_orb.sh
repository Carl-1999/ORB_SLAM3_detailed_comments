echo "Configuring and building ORB_SLAM3 ..."

rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
