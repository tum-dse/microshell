cmake_minimum_required(VERSION 3.0)
project(test)

set(CYT_DIR ${CMAKE_SOURCE_DIR}/../)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CYT_DIR}/cmake)

find_package(CoyoteSW REQUIRED)

# Short aliases for the Figure 3 / Figure 11 SW builds. These rewrite
# EXAMPLE before the long-name if-blocks below see it, so a build with
# -DEXAMPLE=audio_direct routes to the audio_processing app, etc.
if(EXAMPLE STREQUAL "audio_direct")
    set(EXAMPLE "audio_processing")
endif()
if(EXAMPLE STREQUAL "digital_direct")
    set(EXAMPLE "digital_signature")
endif()
if(EXAMPLE STREQUAL "secure_direct")
    set(EXAMPLE "secure_storage")
endif()
if(EXAMPLE STREQUAL "signed_direct")
    set(EXAMPLE "signed_compression")
endif()
if(EXAMPLE STREQUAL "speech_direct")
    set(EXAMPLE "speech_recognition")
endif()
if(EXAMPLE STREQUAL "audio_cpu")
    set(EXAMPLE "audio_processing_cpusync")
endif()
if(EXAMPLE STREQUAL "digital_cpu")
    set(EXAMPLE "digital_signature_cpusync")
endif()
if(EXAMPLE STREQUAL "secure_cpu")
    set(EXAMPLE "secure_storage_cpusync")
endif()
if(EXAMPLE STREQUAL "signed_cpu")
    set(EXAMPLE "signed_compression_cpusync")
endif()
if(EXAMPLE STREQUAL "speech_cpu")
    set(EXAMPLE "speech_recognition_cpusync")
endif()

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

# CPU-sync variants for the direct_comm_effectiveness comparison.

if(EXAMPLE STREQUAL "audio_processing_cpusync")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/audio_processing_cpusync")
    message("** Example: Audio Processing (CPU-sync)")
endif()

if(EXAMPLE STREQUAL "digital_signature_cpusync")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/digital_signature_cpusync")
    message("** Example: Digital Signature (CPU-sync)")
endif()

if(EXAMPLE STREQUAL "secure_storage_cpusync")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/secure_storage_cpusync")
    message("** Example: Secure Storage (CPU-sync)")
endif()

if(EXAMPLE STREQUAL "signed_compression_cpusync")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/signed_compression_cpusync")
    message("** Example: Signed Compression (CPU-sync)")
endif()

if(EXAMPLE STREQUAL "speech_recognition_cpusync")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/speech_recognition_cpusync")
    message("** Example: Speech Recognition (CPU-sync)")
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
