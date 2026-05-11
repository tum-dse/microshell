cmake_minimum_required(VERSION 3.0)
project(test)

set(CYT_DIR ${CMAKE_SOURCE_DIR}/../)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CYT_DIR}/cmake)

find_package(CoyoteHW REQUIRED)

#
# TEST
#

#
# Static
# @brief: Default shell, contains interconnect and memory link testing circuits (perf_local)
#
# @note: Add a target device (FDEV_NAME)
#
# This is what every other shell is built against
#

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

#
# Shells with examples
#

# Application examples, streaming examples
# @brief: Streaming interface example
# The first application is gradient boosting decision trees inference - RTL integration example
# The second one is HyperLogLog cardinality estimation - HLS integration example
#
# @note: Floorplan provided for u55c only -> add manual app floorplans for other devices
#
if(EXAMPLE STREQUAL "streaming")
    message("** Streaming examples: HyperLogLog (cardinality estimation), GBM decision trees (inference) and AES CBC mode")
    set(SHELL_PROBE 1)
    set(FDEV_NAME "u55c")
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(EN_MEM 0)
    set(EN_PR 1)
    set(N_CONFIG 2)
    set(FPLAN_PATH "${CMAKE_SOURCE_DIR}/floorplans/streaming_fplan_u55c.xdc")

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/hyperloglog"    
        VFPGA_C1_0 "apps/gbm_dtrees"    
    )

    create_hw()
endif()

# @brief Shell add app
# This is an example how a previous shell can be extended with additional application on the fly
# This means you don't have to recompile the whole shell, just this new apps will additionally compiled
#
# @note: Need to provide a path to the existing shell build dir ($SHELL_PATH)
#
if(EXAMPLE STREQUAL "streaming_add_aes")
    message("** Streaming examples: Add AES to the previous two apps (app build flow)")
    set(BUILD_APP 1)
    set(BUILD_SHELL 0)
    set(N_CONFIG 1)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/aes_ecb"    
    )

    create_hw()
endif()

# @brief: AES encryption multithreading
# Running multiple threads within one vFPGA
#
#
if(EXAMPLE STREQUAL "multithreading")
    message("** Streaming examples: Multithreading AES CBC")
    set(SHELL_PROBE 2)
    set(FDEV_NAME "u55c")
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(N_STRM_AXI 8)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/aes_cbc"
    )

    create_hw()
endif()

# Application example, KMeans algorithm
# @brief: On-board memory example
#
# @note: Add a target device (FDEV_NAME) -> depending on the device HBM or MIG DRAM will be used (interface is the same)
#
if(EXAMPLE STREQUAL "kmeans")
    message("** K-Means application example")
    set(SHELL_PROBE 3)
    set(N_REGIONS 2)
    set(EN_MEM 1)
    set(N_CARD_AXI 2)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/kmeans"
        VFPGA_C0_1 "apps/kmeans"
    )

    create_hw()
endif()

# GPU example
# @brief: GPU perf test
#
# @note: Add a target device (FDEV_NAME)
#
if(EXAMPLE STREQUAL "perf_gpu")
    message("** GPU perf example")
    set(SHELL_PROBE 4)
    set(N_REGIONS 1)
    set(EN_MEM 1)
    set(N_CARD_AXI 2)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/kmeans"
        VFPGA_C0_1 "apps/kmeans"
    )

    create_hw()
endif()

# Network example, RDMA
# @brief: RDMA with AES encryption example
#
# @note: Add a target device (FDEV_NAME)
#
if(EXAMPLE STREQUAL "rdma_aes")
    message("** RDMA AES-en(de)cryption test")
    set(SHELL_PROBE 5)
    set(N_REGIONS 2)
    set(EN_STRM 1)
    set(EN_MEM 1)
    set(EN_RDMA 1)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/rdma_base"
        VFPGA_C0_1 "apps/rdma_aes"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "rdma_perf")
    message("** RDMA perf test")
    set(SHELL_PROBE 6)
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(EN_RDMA 1)
    set(N_STRM_AXI 2)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/rdma_perf"
    )

    create_hw()
endif()

# Network example, TCP iperf
# @brief: TCP iperf
#
# @note: Add a target device (FDEV_NAME)
#
if(EXAMPLE STREQUAL "tcp_iperf")
    message("** TCP iperf")
    set(SHELL_PROBE 7)
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(EN_TCP 1)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/tcp_iperf"
    )

    create_hw()
endif()

#
# Perf FPGA
# @brief: Link benchmarks, FPGA initiated
#
# @note: Add a target device (FDEV_NAME)
#

if(EXAMPLE STREQUAL "perf_fpga")
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(N_STRM_AXI 2)
    set(EN_MEM 0) # Should work with MEM as well
    set(N_CARD_AXI 2)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/perf_fpga"
    )

    create_hw()
endif()

#SPEECH
if(EXAMPLE STREQUAL "speech")
	set(N_REGIONS 1)
	set(EN_STRM 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)

	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/speech"
	)

	create_hw()
endif()

#DIGI
if(EXAMPLE STREQUAL "digi")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/digi"
	)

	create_hw()
endif()

#SECURE
if(EXAMPLE STREQUAL "secure")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/secure"
	)

	create_hw()
endif()

#SIGNCOMP
if(EXAMPLE STREQUAL "signcomp")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/signcomp"
	)

	create_hw()
endif()

#AUDIO
if(EXAMPLE STREQUAL "audio")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/audio"
	)

	create_hw()
endif()

# TEST CONFIGURATIONS (EFFECTIVENESS)

#AES_CTR
if(EXAMPLE STREQUAL "aes_ctr")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/aes_ctr"
	)

	create_hw()
endif()

#RSA
if(EXAMPLE STREQUAL "rsa")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/rsa"
	)

	create_hw()
endif()

#FFT
if(EXAMPLE STREQUAL "fft")          
	set(N_REGIONS 1)              
	set(EN_STRM 1)               
	set(N_STRM_AXI 1)           
	set(EN_MEM 0)                
	set(EN_PR 0)

	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/fft"    
	)

	create_hw()
endif()

#SVM
if(EXAMPLE STREQUAL "svm")
	set(N_REGIONS 1)
	set(EN_STRM 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)

	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/svm"
	)

	create_hw()
endif()

#SHA
if(EXAMPLE STREQUAL "sha")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/sha"
	)

	create_hw()
endif()

#QUANT
if(EXAMPLE STREQUAL "quant")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/quant"
	)

	create_hw()
endif()

#RLE
if(EXAMPLE STREQUAL "rle")
	set(EN_STRM 1)
	set(N_REGIONS 1)
	set(N_STRM_AXI 1)
	set(EN_MEM 0)
	set(EN_PR 0)
	
	validation_checks_hw()

	load_apps (
	   VFPGA_C0_0 "apps/rle"
	)

	create_hw()
endif()


# TEST CONFIGURATIONS (SCALABILITY)

if(EXAMPLE STREQUAL "1vfpga")
    set(BUILD_SHELL 1)
    set(BUILD_OPT 1)
    set(N_REGIONS 1)
    set(EN_STRM 1)
    set(EN_MEM 1)
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

# Figure 3 cpu_sync: each pipeline stage on its own vFPGA, host CPU shuttles
# between them. N_STRM_AXI=2 — N=1 triggers a Vivado dataflow-opt segfault
# in the µShell switch fabric (HOptDfg::optimizeMuxSelect2).
if(EXAMPLE STREQUAL "audio_cpu")
    set(EN_STRM 1)
    set(N_REGIONS 3)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/fft"
        VFPGA_C0_1 "apps/quant"
        VFPGA_C0_2 "apps/rle"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "digi_cpu")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/sha2"
        VFPGA_C0_1 "apps/rsa"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "secure_cpu")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/rle"
        VFPGA_C0_1 "apps/aes_ctr"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "signcomp_cpu")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/rle"
        VFPGA_C0_1 "apps/rsa"
    )

    create_hw()
endif()

if(EXAMPLE STREQUAL "speech_cpu")
    set(EN_STRM 1)
    set(N_REGIONS 2)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/fft"
        VFPGA_C0_1 "apps/svm"
    )

    create_hw()
endif()

# Figure 5 (resource_usage_2): 7 modules on 7 vFPGAs in a single shell.
# Used by evaluation/scripts/resource_usage_2/extract_modules.py to pull
# per-module footprints from Vivado's hierarchical utilization report —
# the MODULES table there expects instances inst_fft / inst_quant /
# inst_rle / inst_sha256 / inst_rsa_c0_4 / inst_aes / inst_svm. Region
# order matches that lookup (RSA at C0_4 explains the _c0_4 suffix).
# N_STRM_AXI=2 — N=1 triggers the same Vivado dataflow-opt segfault as
# the cpu_sync builds.
if(EXAMPLE STREQUAL "resource_usage")
    set(EN_STRM 1)
    set(N_REGIONS 7)
    set(N_STRM_AXI 2)
    set(EN_MEM 0)
    set(EN_PR 0)

    validation_checks_hw()

    load_apps (
        VFPGA_C0_0 "apps/fft"
        VFPGA_C0_1 "apps/quant"
        VFPGA_C0_2 "apps/rle"
        VFPGA_C0_3 "apps/sha2"
        VFPGA_C0_4 "apps/rsa"
        VFPGA_C0_5 "apps/aes_ctr"
        VFPGA_C0_6 "apps/svm"
    )

    create_hw()
endif()