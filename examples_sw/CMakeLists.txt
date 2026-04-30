cmake_minimum_required(VERSION 3.0)
project(test)

set(CYT_DIR ${CMAKE_SOURCE_DIR}/../)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CYT_DIR}/cmake)

find_package(CoyoteSW REQUIRED)

set(VERBOSITY OFF CACHE BOOL "Enable VERBOSITY for compilation")

if (VERBOSITY)
    message("You selected VERBOSITY for compilation")
    add_compile_definitions(VERBOSE)
else()
    message("VERBOSITY is not selected for compilation")
endif()

# Performance benchmarks

if(EXAMPLE STREQUAL "perf_local")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_local")
    message("** Example: Validation tests - Link perf")
endif()

if(EXAMPLE STREQUAL "perf_fpga")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_fpga")
    message("** Example: FPGA perf benchmark")
endif()

# Composite pipelines

if(EXAMPLE STREQUAL "audio_processing")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/audio_processing")
    message("** Example: Audio Processing")
endif()

if(EXAMPLE STREQUAL "digital_signature")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/digital_signature")
    message("** Example: Digital Signature")
endif()

if(EXAMPLE STREQUAL "secure_storage")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/secure_storage")
    message("** Example: Secure Storage")
endif()

if(EXAMPLE STREQUAL "signed_compression")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/signed_compression")
    message("** Example: Signed Compression")
endif()

if(EXAMPLE STREQUAL "speech_recognition")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/speech_recognition")
    message("** Example: Speech Recognition")
endif()

# Single-module bring-ups

if(EXAMPLE STREQUAL "aes_ctr")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/aes-ctr")
    message("** Example: AES-CTR")
endif()

if(EXAMPLE STREQUAL "fft")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/fft")
    message("** Example: FFT")
endif()

if(EXAMPLE STREQUAL "quantize")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/quantize")
    message("** Example: Quantize")
endif()

if(EXAMPLE STREQUAL "rle")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/rle")
    message("** Example: RLE")
endif()

if(EXAMPLE STREQUAL "rsa")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/rsa")
    message("** Example: RSA")
endif()

if(EXAMPLE STREQUAL "sha256")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/sha256")
    message("** Example: SHA256")
endif()

if(EXAMPLE STREQUAL "svm")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/svm")
    message("** Example: SVM")
endif()

set(EXEC test)
add_executable(${EXEC} ${TARGET_DIR}/main.cpp)
target_link_libraries(${EXEC} PUBLIC Coyote)
target_link_directories(${EXEC} PUBLIC /usr/local/lib)

if(EN_GPU)
    set(AMD_GPU "gfx908" CACHE STRING "AMD GPU device to use")
    set_property(TARGET ${EXEC} PROPERTY HIP_ARCHITECTURES ${AMD_GPU})
    set_target_properties(${EXEC} PROPERTIES LINKER_LANGUAGE CXX)
    target_link_libraries(${EXEC} PUBLIC hip::device numa pthread drm drm_amdgpu rt dl hsa-runtime64 hsakmt)
endif()
