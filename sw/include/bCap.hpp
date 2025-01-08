#pragma once

#include "cDefs.hpp"

#include <cstdint>
#include <cstdio>
#include <string>
#include <unordered_map>
#include <boost/interprocess/sync/scoped_lock.hpp>
#include <boost/interprocess/sync/named_mutex.hpp>
#ifdef EN_AVX
#include <x86intrin.h>
#include <smmintrin.h>
#include <immintrin.h>
#endif
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

using namespace std;
using namespace boost::interprocess;

namespace fpga {

/**
 * @brief Base Capability class for memory management 
 * Integrates with Coyote's memory system and the memory gateway
 */
class bCap {
protected:
    /* Fpga device */
    int32_t fd = { 0 };
    int32_t vfid = { -1 };
    pid_t hpid = { 0 };
    fCnfg fcnfg;

    /* Locks */
    named_mutex plock;

    /* Memory mapped regions */
#ifdef EN_AVX
    volatile __m256i *cnfg_reg_avx = { 0 };
#endif
    volatile uint64_t *cnfg_reg = { 0 };
    volatile uint64_t *ctrl_reg = { 0 };

    /* Mapped pages tracking */
    std::unordered_map<void*, csAlloc> mapped_pages;

    /* Memory gateway endpoint state */
    struct EndpointState {
        bool valid;
        void* vaddr;
        uint32_t len;
        uint8_t user_logic_id;
        uint8_t app_id;
        uint8_t access_rights;
    };
    std::array<EndpointState, N_ENDPOINTS> endpoints;

    /* Utility */
    void mmapFpga();
    void munmapFpga();

    /**
     * @brief Validate memory access against mapped pages
     * @param vaddr Virtual address to validate
     * @param len Length of memory region to validate
     * @return true if access is valid, false otherwise
     */
    bool validateMemoryAccess(void* vaddr, uint32_t len) {
        auto it = mapped_pages.find(vaddr);
        if(it == mapped_pages.end()) return false;
        return (it->second.size >= len);
    }

    /**
     * @brief Clear endpoint state
     * @param idx Index of endpoint to clear
     */
    void clearEndpoint(uint32_t idx) {
        updateEndpoint(idx, false, nullptr, 0, 0, 0, false);
    }

public:
    /**
     * @brief Ctor, Dtor
     */
    bCap(int32_t vfid, pid_t hpid, uint32_t dev) : 
        vfid(vfid), 
        hpid(hpid),
        plock(string("pLock_" + to_string(vfid)).c_str()) {
        
        // Open device
        fd = open(string("/dev/fpga" + to_string(dev)).c_str(), O_RDWR);
        if(fd < 0) {
            throw runtime_error("Could not open FPGA device file.");
        }

        // Memory map registers
        mmapFpga();
    }

    virtual ~bCap() {
        munmapFpga();
        if(fd) close(fd);
    }

    /**
     * @brief Memory management integrated with gateway
     */
    void userMap(void *vaddr, uint32_t len, bool remote = false) {
        // Map in Coyote
        csAlloc cs_alloc;
        cs_alloc.alloc = useHugePages ? CoyoteAlloc::HPF : CoyoteAlloc::REG;
        cs_alloc.size = len;
        cs_alloc.remote = remote;
        
        // Register with driver
        if(ioctl(fd, IOCTL_MAP_USER, &cs_alloc) < 0) {
            throw runtime_error("Could not map memory region");
        }

        // Track allocation
        mapped_pages[vaddr] = cs_alloc;

        // Register with memory gateway
        uint32_t endpoint = getFreeEndpoint();
        if(endpoint < N_ENDPOINTS) {
            updateEndpoint(endpoint, true, vaddr, len, src_id, app_id, /*write=*/true);
        }
    }

    void userUnmap(void *vaddr) {
        // Find mapped allocation
        auto it = mapped_pages.find(vaddr);
        if(it != mapped_pages.end()) {
            // Unmap from Coyote
            if(ioctl(fd, IOCTL_UNMAP_USER, &it->second) < 0) {
                throw runtime_error("Could not unmap memory region");
            }
            mapped_pages.erase(it);

            // Remove from gateway endpoints
            for(uint32_t i = 0; i < N_ENDPOINTS; i++) {
                if(endpoints[i].valid && endpoints[i].vaddr == vaddr) {
                    clearEndpoint(i);
                }
            }
        }
    }

protected:
    /**
     * @brief Memory gateway interface
     */
    uint32_t getFreeEndpoint() {
        for(uint32_t i = 0; i < N_ENDPOINTS; i++) {
            if(!endpoints[i].valid) return i;
        }
        return N_ENDPOINTS;
    }

    void updateEndpoint(uint32_t idx, bool valid, void* vaddr, uint32_t len,
                       uint8_t user_logic_id, uint8_t app_id, bool write) {
        // Bounds check
        if(idx >= N_ENDPOINTS) {
            throw runtime_error("Endpoint index out of bounds");
        }

        // If valid, validate memory access
        if(valid && vaddr != nullptr) {
            if(!validateMemoryAccess(vaddr, len)) {
                throw runtime_error("Invalid memory access parameters for endpoint");
            }
        }

        // Update local state
        endpoints[idx].valid = valid;
        endpoints[idx].vaddr = vaddr;
        endpoints[idx].len = len;
        endpoints[idx].user_logic_id = user_logic_id;
        endpoints[idx].app_id = app_id;
        endpoints[idx].access_rights = write ? 0x3 : 0x1;

        // Update gateway registers
        uint64_t config = (valid ? 1UL << 31 : 0) |
                         (user_logic_id << 24) |
                         (app_id << 20);
        uint64_t base = reinterpret_cast<uint64_t>(vaddr);
        uint64_t bound = base + len;

        ctrl_reg[idx*4 + 0] = config;
        ctrl_reg[idx*4 + 1] = base;
        ctrl_reg[idx*4 + 2] = bound;
        ctrl_reg[idx*4 + 3] = endpoints[idx].access_rights;
    }

    /**
     * @brief Memory mapping
     */
    void mmapFpga() {
#ifdef EN_AVX
        cnfg_reg_avx = static_cast<volatile __m256i*>(
            mmap(NULL, cnfgAvxRegionSize, PROT_READ | PROT_WRITE, 
                MAP_SHARED, fd, mmapCnfgAvx)
        );
        if(cnfg_reg_avx == MAP_FAILED) {
            throw runtime_error("Could not mmap config registers");
        }
#else
        cnfg_reg = static_cast<volatile uint64_t*>(
            mmap(NULL, cnfgRegionSize, PROT_READ | PROT_WRITE,
                MAP_SHARED, fd, mmapCnfg)
        );
        if(cnfg_reg == MAP_FAILED) {
            throw runtime_error("Could not mmap config registers");
        }
#endif
        ctrl_reg = static_cast<volatile uint64_t*>(
            mmap(NULL, ctrlRegionSize, PROT_READ | PROT_WRITE,
                MAP_SHARED, fd, mmapCtrl)
        );
        if(ctrl_reg == MAP_FAILED) {
            throw runtime_error("Could not mmap control registers"); 
        }
    }

    void munmapFpga() {
#ifdef EN_AVX
        if(cnfg_reg_avx) munmap((void*)cnfg_reg_avx, cnfgAvxRegionSize);
#else
        if(cnfg_reg) munmap((void*)cnfg_reg, cnfgRegionSize);
#endif
        if(ctrl_reg) munmap((void*)ctrl_reg, ctrlRegionSize);
    }

    /**
     * @brief Getters
     */
    inline auto getVfid() const { return vfid; }
    inline auto getHpid() const { return hpid; }
};

} /* namespace fpga */