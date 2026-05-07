cmake_minimum_required(VERSION 3.0)
project(test)

set(CYT_DIR ${CMAKE_SOURCE_DIR}/../)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CYT_DIR}/cmake)

find_package(CoyoteHW REQUIRED)

# Default 4-region shell: every region runs perf_local.
if(EXAMPLE STREQUAL "static")
    set(BUILD_STATIC 1)
    set(BUILD_SHELL 0)
    set(BUILD_OPT 1)
    set(N_REGIONS 4)
    set(EN_STRM 1)
    set(EN_MEM 1)
    set(HBM_SPLIT 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_local"
        VFPGA_C0_1 "apps/perf_local"
        VFPGA_C0_2 "apps/perf_local"
        VFPGA_C0_3 "apps/perf_local"
    )

    create_hw()
endif()

# Composite pipelines

if(EXAMPLE STREQUAL "audio_processing")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/audio_processing"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "digital_signature")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/digital_signature"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "secure_storage")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/secure_storage"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "signed_compression")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/signed_compression"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "speech_recognition")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/speech_recognition"
    )

    create_hw()
endif()

# Single-module bring-ups

if(EXAMPLE STREQUAL "aes_ctr")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/aes-ctr"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "fft")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/fft"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "quantize")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/quantize"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "rle")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/rle"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "rsa")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/rsa"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "sha256")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/sha256"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "svm")
    set(EN_STRM 1)
    set(N_REGIONS 1)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/svm"
    )

    create_hw()
endif()

# Performance benchmarks

if(EXAMPLE STREQUAL "perf_fpga")
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(N_CARD_AXI 2)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_fpga"
    )

    create_hw()
endif()

# Scalability sweeps

if(EXAMPLE STREQUAL "1vfpga")
    set(BUILD_SHELL 1)
    set(BUILD_OPT 1)
    set(N_REGIONS 1)
    set(EN_STRM 1)
    #set(EN_MEM 1)
    set(HBM_SPLIT 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_local"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "2vfpga")
    set(BUILD_SHELL 1)
    set(BUILD_OPT 1)
    set(N_REGIONS 2)
    set(EN_STRM 1)
    #set(EN_MEM 1)
    set(HBM_SPLIT 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_local"
        VFPGA_C0_1 "apps/perf_local"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "4vfpga")
    set(BUILD_SHELL 1)
    set(BUILD_OPT 1)
    set(N_REGIONS 4)
    set(EN_STRM 1)
    #set(EN_MEM 1)
    set(HBM_SPLIT 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_local"
        VFPGA_C0_1 "apps/perf_local"
        VFPGA_C0_2 "apps/perf_local"
        VFPGA_C0_3 "apps/perf_local"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "8vfpga")
    set(BUILD_SHELL 1)
    set(BUILD_OPT 1)
    set(N_REGIONS 8)
    set(EN_STRM 1)
    #set(EN_MEM 1)
    set(HBM_SPLIT 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_local"
        VFPGA_C0_1 "apps/perf_local"
        VFPGA_C0_2 "apps/perf_local"
        VFPGA_C0_3 "apps/perf_local"
        VFPGA_C0_4 "apps/perf_local"
        VFPGA_C0_5 "apps/perf_local"
        VFPGA_C0_6 "apps/perf_local"
        VFPGA_C0_7 "apps/perf_local"
    )

    create_hw()
endif()

# CPU-sync configurations: each module on its own vFPGA, with the host CPU
# shuttling intermediate buffers between stages. Used by Figure 3
# (direct_comm_effectiveness) to motivate µShell's on-chip data paths.

if(EXAMPLE STREQUAL "audio_processing_cpusync")
    set(EN_STRM 1)
    set(N_REGIONS 3)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/fft"
        VFPGA_C0_1 "apps/modules/quantize"
        VFPGA_C0_2 "apps/modules/rle"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "digital_signature_cpusync")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/sha256"
        VFPGA_C0_1 "apps/modules/rsa"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "secure_storage_cpusync")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/rle"
        VFPGA_C0_1 "apps/modules/aes-ctr"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "signed_compression_cpusync")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/rle"
        VFPGA_C0_1 "apps/modules/rsa"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "speech_recognition_cpusync")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/fft"
        VFPGA_C0_1 "apps/modules/svm"
    )

    create_hw()
endif()

# resource_usage: loads all 7 unique application modules onto separate
# vFPGAs in a single shell so one bitstream + one report_utilization run
# yields per-module LUT/Reg/BRAM/URAM numbers for the resource_efficiency
# and scalability_analysis plots.
if(EXAMPLE STREQUAL "resource_usage")
    set(EN_STRM 1)
    set(N_REGIONS 7)
    set(N_STRM_AXI 1)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/modules/fft"
        VFPGA_C0_1 "apps/modules/quantize"
        VFPGA_C0_2 "apps/modules/rle"
        VFPGA_C0_3 "apps/modules/sha256"
        VFPGA_C0_4 "apps/modules/rsa"
        VFPGA_C0_5 "apps/modules/aes-ctr"
        VFPGA_C0_6 "apps/modules/svm"
    )

    create_hw()
endif()
