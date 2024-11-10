#pragma once
#include <string>
#include <vector>
#include "cSched.hpp"
#include "bFunc.hpp"
#include "cThread.hpp"
#include "cDefs.hpp"

namespace fpga {

class cCapability : public cSched {
protected:
    static cCapability* ccapability;
    int32_t vfid;
    uint32_t dev;
    cThread<std::any>* thread;
    
    struct RegInfo {
        std::string name;
        uint32_t addr;
        uint32_t value;
        bool readable;
        bool writable;
    };
    std::vector<RegInfo> registers;

    cCapability(string name, int32_t vfid, uint32_t dev, bool priority = true) 
        : cSched(vfid, dev, priority, false)
        , vfid(vfid)
        , dev(dev)
    {
        try {
            std::cout << "Creating thread..." << std::endl;
            thread = new cThread<std::any>(vfid, getpid(), dev);
            
            std::cout << "Starting thread..." << std::endl;
            thread->start();

            // Basic register definitions without initialization
            defineRegister("CTRL", static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG), true, true);
            defineRegister("ISR", static_cast<uint32_t>(CnfgAvxRegs::ISR_REG), true, true);
            defineRegister("STAT_0", static_cast<uint32_t>(CnfgAvxRegs::STAT_REG_0), true, false);
            defineRegister("STAT_1", static_cast<uint32_t>(CnfgAvxRegs::STAT_REG_1), true, false);
            
            std::cout << "Initialization complete" << std::endl;
        } catch (const std::exception& e) {
            std::cerr << "Error in constructor: " << e.what() << std::endl;
            throw;
        }
    }
    	
    void writeReg(uint32_t addr, uint32_t value) {
        if (!thread) throw std::runtime_error("No active thread for register write");
        thread->setCSR(value, addr);
    }

    uint32_t readReg(uint32_t addr) {
        if (!thread) throw std::runtime_error("No active thread for register read");
        return thread->getCSR(addr);
    }
    
public:
    static cCapability* getInstance(string name, int32_t vfid, uint32_t dev, bool priority = true) {
        if(ccapability == nullptr) {
            std::cout << "Creating cCapability instance..." << std::endl;
            ccapability = new cCapability(name, vfid, dev, priority);
        }
        return ccapability;
    }
    
    void verifyRegisters() {
	    if (!thread) {
		throw std::runtime_error("No thread available for register verification");
	    }

	    std::cout << "\nRegister Access Test:" << std::endl;
	    std::cout << "--------------------------------" << std::endl;

	    // Try writing and reading back a test pattern
	    const uint32_t test_pattern = 0xA5A5A5A5;
	    uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
	    
	    std::cout << "Testing CTRL_REG (addr 0x" << std::hex << addr << ")" << std::dec << std::endl;
	    std::cout << "Original value: 0x" << std::hex << thread->getCSR(addr) << std::dec << std::endl;
	    
	    // Attempt to write test pattern
	    thread->setCSR(test_pattern, addr);
	    uint32_t readback = thread->getCSR(addr);
	    
	    std::cout << "Wrote test pattern: 0x" << std::hex << test_pattern << std::dec << std::endl;
	    std::cout << "Read back value: 0x" << std::hex << readback << std::dec << std::endl;

	    if (readback == 0xFFFFFFFF) {
		std::cout << "\nDiagnostic Information:" << std::endl;
		std::cout << "--------------------------------" << std::endl;
		std::cout << "1. Memory mapping status:" << std::endl;
		std::cout << "   - Page size: " << std::dec << pageSize << " bytes" << std::endl;
		std::cout << "   - Control region size: " << ctrlRegionSize << " bytes" << std::endl;
		std::cout << "   - Config region size: " << cnfgRegionSize << " bytes" << std::endl;
		
		// Get thread info
		std::cout << "2. Thread configuration:" << std::endl;
		std::cout << "   - VFID: " << thread->getVfid() << std::endl;
		std::cout << "   - CTID: " << thread->getCtid() << std::endl;
		std::cout << "   - HPID: " << thread->getHpid() << std::endl;

		// Check device file
		std::string dev_path = "/dev/fpga_" + std::to_string(dev) + "_v" + std::to_string(vfid);
		struct stat st;
		if (stat(dev_path.c_str(), &st) == 0) {
		    std::cout << "3. Device file info for " << dev_path << ":" << std::endl;
		    std::cout << "   - File exists" << std::endl;
		    std::cout << "   - Permissions: " << std::oct << (st.st_mode & 0777) << std::dec << std::endl;
		    std::cout << "   - Owner UID: " << st.st_uid << std::endl;
		    std::cout << "   - Owner GID: " << st.st_gid << std::endl;
		} else {
		    std::cout << "3. Device file " << dev_path << " does not exist!" << std::endl;
		    std::cout << "Please check if:" << std::endl;
		    std::cout << "1. The Coyote driver is loaded (sudo modprobe coyote)" << std::endl;
		    std::cout << "2. You have the correct device number and VFID" << std::endl;
		    std::cout << "3. The FPGA is properly configured" << std::endl;
		}
	    }
    }
    
    void setOpcode(uint32_t opcode) {
        uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
        uint32_t value = readReg(addr);
        value &= ~(CTRL_OPCODE_MASK << CTRL_OPCODE_OFFS);
        value |= ((opcode & CTRL_OPCODE_MASK) << CTRL_OPCODE_OFFS);
        writeReg(addr, value);
    }

    void setStream(uint32_t stream) {
        uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
        uint32_t value = readReg(addr);
        value &= ~(CTRL_STRM_MASK << CTRL_STRM_OFFS);
        value |= ((stream & CTRL_STRM_MASK) << CTRL_STRM_OFFS);
        writeReg(addr, value);
    }

    void setPid(uint32_t pid) {
        uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
        uint32_t value = readReg(addr);
        value &= ~(CTRL_PID_MASK << CTRL_PID_OFFS);
        value |= ((pid & CTRL_PID_MASK) << CTRL_PID_OFFS);
        writeReg(addr, value);
    }

    void setStart(bool start) {
        if(start) {
            uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
            uint32_t value = readReg(addr);
            value |= CTRL_START;
            writeReg(addr, value);
        }
    }

    void clearStatus() {
        uint32_t addr = static_cast<uint32_t>(CnfgAvxRegs::CTRL_REG);
        uint32_t value = readReg(addr);
        value |= CTRL_CLR_STAT;
        writeReg(addr, value);
        // Clear the CLR_STAT bit
        value &= ~CTRL_CLR_STAT;
        writeReg(addr, value);
    }

    void writeRegister(const string& name, uint32_t value) {
        for(const auto& reg : registers) {
            if(reg.name == name) {
                if(!reg.writable) throw std::runtime_error("Register " + name + " is not writable");
                writeReg(reg.addr, value);
                return;
            }
        }
        throw std::runtime_error("Register " + name + " not defined");
    }

    uint32_t readRegister(const string& name) {
        for(const auto& reg : registers) {
            if(reg.name == name) {
                if(!reg.readable) throw std::runtime_error("Register " + name + " is not readable");
                return readReg(reg.addr);
            }
        }
        throw std::runtime_error("Register " + name + " not defined");
    }

    void defineRegister(const string& name, uint32_t addr, bool readable, bool writable) {
        for(const auto& reg : registers) {
            if(reg.name == name) throw std::runtime_error("Register " + name + " already defined");
        }
        registers.push_back({name, addr, 0, readable, writable});
    }

    ~cCapability() {
        if(thread) {
            try {
                delete thread;
                thread = nullptr;
            } catch(...) {}
        }
    }
};

// Define static member
cCapability* cCapability::ccapability = nullptr;

} // namespace fpga
