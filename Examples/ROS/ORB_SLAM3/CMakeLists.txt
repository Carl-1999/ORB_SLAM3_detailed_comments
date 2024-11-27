cmake_minimum_required(VERSION 2.4.6)
project(ORB_SLAM3)

# Include rosbuild
# include($ENV{ROS_ROOT}/core/rosbuild/rosbuild.cmake)

# Initialize the ROS build environment
# rosbuild_init()

# Set default build type to Release if not specified
if(NOT ROS_BUILD_TYPE)
  set(ROS_BUILD_TYPE Release)
endif()

message("Build type: ${ROS_BUILD_TYPE}")

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O3 -march=native")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O3 -march=native")

# Check for C++11 support
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++11" COMPILER_SUPPORTS_CXX11)
check_cxx_compiler_flag("-std=c++0x" COMPILER_SUPPORTS_CXX0X)

if(COMPILER_SUPPORTS_CXX11)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  add_definitions(-DCOMPILEDWITHC11)
  message(STATUS "Using flag -std=c++11.")
elseif(COMPILER_SUPPORTS_CXX0X)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
  add_definitions(-DCOMPILEDWITHC0X)
  message(STATUS "Using flag -std=c++0x.")
else()
  message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

# Add custom module paths
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../../../cmake_modules)

# Find dependencies
find_package(OpenCV 3.2 REQUIRED)
if(NOT OpenCV_FOUND)
  message(FATAL_ERROR "OpenCV >= 3.2 not found.")
endif()

find_package(Eigen3 REQUIRED)
find_package(Pangolin REQUIRED)

find_package(catkin REQUIRED COMPONENTS
    rospy
    roscpp
    std_msgs
    sensor_msgs
    geometry_msgs
    nav_msgs
    cv_bridge
    tf
    tf_conversions  
)

# Include directories
include_directories(
  ${PROJECT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/../../../
  ${PROJECT_SOURCE_DIR}/../../../include
  ${PROJECT_SOURCE_DIR}/../../../include/CameraModels
  ${PROJECT_SOURCE_DIR}/../../../Thirdparty/Sophus
  ${Pangolin_INCLUDE_DIRS}
  ${catkin_INCLUDE_DIRS}
)

# Libraries to link
set(LIBS 
  ${OpenCV_LIBS}
  ${EIGEN3_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/../../../Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/../../../Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_SOURCE_DIR}/../../../lib/libORB_SLAM3.so
  -lboost_system
  ${catkin_LIBRARIES}
)

# Build ROS nodes

## Monocular camera node
add_executable(Mono src/ros_mono.cc)
target_link_libraries(Mono ${LIBS})

## Stereo camera node
add_executable(Stereo src/ros_stereo.cc)
target_link_libraries(Stereo ${LIBS})

## RGB-D camera node
add_executable(RGBD src/ros_rgbd.cc)
target_link_libraries(RGBD ${LIBS})

## Monocular-inertial camera node
add_executable(Mono_Inertial src/ros_mono_inertial.cc)
target_link_libraries(Mono_Inertial ${LIBS})

## Stereo-inertial camera node
add_executable(Stereo_Inertial src/ros_stereo_inertial.cc)
target_link_libraries(Stereo_Inertial ${LIBS})

# Uncomment the AR demo node if needed
# add_executable(MonoAR
#   src/AR/ros_mono_ar.cc
#   src/AR/ViewerAR.h
#   src/AR/ViewerAR.cc
# )
# target_link_libraries(MonoAR ${LIBS})
