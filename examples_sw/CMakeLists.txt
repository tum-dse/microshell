cmake_minimum_required(VERSION 3.5)
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

# Shell reconfiguration

if(EXAMPLE STREQUAL "reconfigure_shell")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/reconfigure_shell")
    message("** Shell load")
endif()

# Performance benchmarks

if(EXAMPLE STREQUAL "perf_local")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_local")
    message("** Example: Validation tests - Link perf")
endif()

if(EXAMPLE STREQUAL "perf_mem")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_mem")
    message("** Example: Test using FPGA memory")
endif()

if(EXAMPLE STREQUAL "perf_counter")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_counter")
    message("** Example: Idle-cycle counter test")
endif()

if(EXAMPLE STREQUAL "perf_fpga")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_fpga")
    message("** Example: FPGA perf benchmark")
endif()

if(EXAMPLE STREQUAL "pipeline")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/pipeline")
    message("** Example: vFPGA-to-vFPGA pipeline (µShell)")
endif()

if(EXAMPLE STREQUAL "scheduler")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/scheduler/client")
    message("** Example: Custom scheduler client")
endif()

# Composite pipelines

if(EXAMPLE STREQUAL "audio_processing")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/audio_processing")
    message("** Example: Audio Processing (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "audio_processing_monolithic")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/audio_processing_monolithic")
    message("** Example: Audio Processing Monolithic (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "digital_signature")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/digital_signature")
    message("** Example: Digital Signature (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "digital_signature_monolithic")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/digital_signature_monolithic")
    message("** Example: Digital Signature Monolithic (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "secure_storage")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/secure_storage")
    message("** Example: Secure Storage (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "secure_storage_monolithic")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/secure_storage_monolithic")
    message("** Example: Secure Storage Monolithic (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "signed_compression")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/signed_compression")
    message("** Example: Signed Compression (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "signed_compression_monolithic")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/signed_compression_monolithic")
    message("** Example: Signed Compression Monolithic (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "speech_recognition")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/speech_recognition")
    message("** Example: Speech Recognition (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "speech_recognition_monolithic")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/speech_recognition_monolithic")
    message("** Example: Speech Recognition Monolithic (µShell daemon)")
endif()

# Single-module bring-ups

if(EXAMPLE STREQUAL "aes_ctr")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/aes-ctr")
    message("** Example: AES-CTR (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "fft")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/fft")
    message("** Example: FFT (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "quantize")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/quantize")
    message("** Example: FFT Quantization (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "rle")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/rle")
    message("** Example: RLE (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "rsa")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/rsa")
    message("** Example: RSA (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "sha256")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/sha256")
    message("** Example: SHA256 (µShell daemon)")
endif()

if(EXAMPLE STREQUAL "svm")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/modules/svm")
    message("** Example: SVM (µShell daemon)")
endif()

# Perf services example — drives the §6.3 partial-reconfiguration
# measurement (server publishes a perf_local accelerator; client triggers
# 1–4-component reconfigurations and logs PR timings to journald).
if(EXAMPLE STREQUAL "perf_server")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_service/server")
    message("** Example: perf_local service - Server (µShell daemon)")
    include_directories(${TARGET_DIR}/../include ${TARGET_DIR}/include)
endif()

if(EXAMPLE STREQUAL "perf_client")
    set(TARGET_DIR "${CYT_DIR}/examples_sw/apps/perf_service/client")
    message("** Example: perf_local service - Client")
    include_directories(${TARGET_DIR}/../include)
endif()

# Build target

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
