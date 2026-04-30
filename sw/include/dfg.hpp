#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <memory>
#include <atomic>
#include <any>
#include <chrono>
#include <functional>

#include "cDefs.hpp"
#include "cThread.hpp"
#include "cBench.hpp"

namespace dfg {

using namespace fpga;

class DFG;
class Node;
class Buffer;
class Capability;

enum StreamMode {
    HOST_STREAM = 1,
    CARD_STREAM = 0
};

enum CapabilityPermission {
    READ = 1,
    WRITE = 2,
    EXECUTE = 4,
    DELEGATE = 8,
    TRANSITIVE_DELEGATE = 16
};

// ================================================================
// Capability
// ================================================================
class Capability {
private:
    std::string cap_id;
    uint32_t permissions;
    void* resource = nullptr;
    size_t resource_size = 0;
    Capability* parent = nullptr;
    std::vector<Capability*> children;
    cThread<std::any>* thread = nullptr;
    bool owns_resource = false;
    std::chrono::time_point<std::chrono::system_clock> expiry_time;
    bool has_expiry = false;

public:
    Capability(const std::string& id, uint32_t perms, cThread<std::any>* thread_ptr = nullptr,
               void* res = nullptr, size_t size = 0, Capability* parent_cap = nullptr,
               bool owns_res = false)
        : cap_id(id), permissions(perms), thread(thread_ptr), resource(res),
          resource_size(size), parent(parent_cap), owns_resource(owns_res) {
        if (parent) {
            parent->add_child(this);
        }
    }

    void add_child(Capability* child) {
        if (child) children.push_back(child);
    }

    bool remove_child(const std::string& child_id) {
        auto it = std::find_if(children.begin(), children.end(),
            [&child_id](Capability* cap) {
                return cap && cap->get_id() == child_id;
            });
        if (it != children.end()) {
            children.erase(it);
            return true;
        }
        return false;
    }

    bool has_permission(CapabilityPermission perm) const {
        if (has_expiry && std::chrono::system_clock::now() > expiry_time) return false;
        return (permissions & perm) != 0;
    }

    bool has_permissions(uint32_t required_perms) const {
        if (has_expiry && std::chrono::system_clock::now() > expiry_time) return false;
        return (permissions & required_perms) == required_perms;
    }

    void print_tree(int depth = 0) const {
        for (int i = 0; i < depth; i++) std::cout << "  ";
        std::cout << cap_id << " (Perms: " << permissions << ")";
        if (has_expiry) {
            auto now = std::chrono::system_clock::now();
            if (now > expiry_time) {
                std::cout << " [EXPIRED]";
            } else {
                auto remaining = std::chrono::duration_cast<std::chrono::seconds>(expiry_time - now).count();
                std::cout << " [Expires in " << remaining << "s]";
            }
        }
        std::cout << std::endl;
        for (auto child : children) {
            if (child) child->print_tree(depth + 1);
        }
    }

    void set_expiry(std::chrono::seconds timeout) {
        expiry_time = std::chrono::system_clock::now() + timeout;
        has_expiry = true;
    }

    bool is_expired() const {
        if (!has_expiry) return false;
        return std::chrono::system_clock::now() > expiry_time;
    }

    std::string get_id() const { return cap_id; }
    uint32_t get_permissions() const { return permissions; }
    void* get_resource() const { return resource; }
    size_t get_resource_size() const { return resource_size; }
    Capability* get_parent() const { return parent; }
    const std::vector<Capability*>& get_children() const { return children; }
    cThread<std::any>* get_thread() const { return thread; }
    bool get_owns_resource() const { return owns_resource; }

    void set_thread(cThread<std::any>* thread_ptr) { thread = thread_ptr; }

    // Permissive during init when resource/thread are null on either side.
    bool is_for_resource(const void* res) const {
        if (resource == nullptr || res == nullptr) return true;
        return resource == res;
    }

    bool is_for_thread(cThread<std::any>* thread_ptr) const {
        if (thread == nullptr || thread_ptr == nullptr) return true;
        return thread == thread_ptr;
    }

    Capability* delegate(const std::string& new_id, uint32_t requested_perms) {
        if (!has_permission(CapabilityPermission::DELEGATE)) {
            std::cerr << "Error: Capability " << cap_id
                      << " lacks DELEGATE permission required for delegation" << std::endl;
            return nullptr;
        }

        // Delegating DELEGATE itself requires TRANSITIVE_DELEGATE on the parent.
        if ((requested_perms & CapabilityPermission::DELEGATE) &&
            !has_permission(CapabilityPermission::TRANSITIVE_DELEGATE)) {
            std::cerr << "Error: Capability " << cap_id
                      << " lacks TRANSITIVE_DELEGATE permission required for delegating DELEGATE permission" << std::endl;
            return nullptr;
        }

        uint32_t allowed_perms = permissions & requested_perms;
        if (allowed_perms != requested_perms) {
            std::cerr << "Error: Requested permissions not a subset of parent permissions" << std::endl;
            return nullptr;
        }

        return new Capability(new_id, allowed_perms, thread, resource, resource_size, this, false);
    }

    bool can_delegate_delegation() const {
        return has_permission(CapabilityPermission::DELEGATE) &&
               has_permission(CapabilityPermission::TRANSITIVE_DELEGATE);
    }
};

// RAII guard: validates capability/resource/perm match at construction.
template<typename T>
class CapabilityGuard {
private:
    T* resource;
    Capability* capability;
    uint32_t required_permissions;
    bool valid;

public:
    CapabilityGuard(T* res, Capability* cap, uint32_t perms)
        : resource(res), capability(cap), required_permissions(perms), valid(false) {
        if (res && cap && !cap->is_expired() &&
            cap->is_for_resource(res) &&
            cap->has_permissions(perms)) {
            valid = true;
        }
    }

    bool is_valid() const { return valid; }
    T* get() const { return valid ? resource : nullptr; }
    operator bool() const { return valid; }
};

class Node;

// ================================================================
// Buffer
// ================================================================
class Buffer {
private:
    std::string buffer_id;
    DFG* parent_dfg;
    void* memory;
    size_t size;

public:
    Buffer(const std::string& buffer_id, DFG* parent_dfg, void* memory, size_t size)
        : buffer_id(buffer_id), parent_dfg(parent_dfg), memory(memory), size(size) {}

    std::string get_id() const { return buffer_id; }

    void* get_memory(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_memory on buffer " << buffer_id << std::endl;
            return nullptr;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_memory on buffer " << buffer_id << std::endl;
            return nullptr;
        }
        return memory;
    }

    bool write_data(void* data, size_t data_size, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for write_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for write_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (!data) {
            std::cerr << "Error: Null data for write_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (data_size > size) {
            std::cerr << "Error: Data size " << data_size << " exceeds buffer size "
                      << size << " for buffer " << buffer_id << std::endl;
            return false;
        }

        try {
            memcpy(memory, data, data_size);
            return true;
        } catch (const std::exception& e) {
            std::cerr << "Exception during write_data on buffer " << buffer_id
                      << ": " << e.what() << std::endl;
            return false;
        }
    }

    bool read_data(void* dest, size_t data_size, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for read_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for read_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (!dest) {
            std::cerr << "Error: Null destination for read_data on buffer " << buffer_id << std::endl;
            return false;
        }
        if (data_size > size) {
            std::cerr << "Error: Data size " << data_size << " exceeds buffer size "
                      << size << " for buffer " << buffer_id << std::endl;
            return false;
        }

        try {
            memcpy(dest, memory, data_size);
            return true;
        } catch (const std::exception& e) {
            std::cerr << "Exception during read_data on buffer " << buffer_id
                      << ": " << e.what() << std::endl;
            return false;
        }
    }

    size_t get_size(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_size on buffer " << buffer_id << std::endl;
            return 0;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_size on buffer " << buffer_id << std::endl;
            return 0;
        }
        return size;
    }

    DFG* get_parent_dfg() const { return parent_dfg; }
};

// ================================================================
// Node
// ================================================================
class Node {
private:
    std::string node_id;
    int vfid;
    DFG* parent_dfg;
    std::shared_ptr<cThread<std::any>> thread;
    CoyoteOper operation = CoyoteOper::LOCAL_TRANSFER;

public:
    Node(const std::string& node_id, DFG* parent_dfg, int vfid);

    void set_thread(std::shared_ptr<cThread<std::any>> thread_ptr) { thread = thread_ptr; }

    void set_io_switch(IODevs io_switch, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for set_io_switch on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for set_io_switch on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        try {
            thread->ioSwitch(io_switch);
        } catch (const std::exception& e) {
            std::cerr << "Exception during set_io_switch on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    void clear_completed(Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for clear_completed on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for clear_completed on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        try {
            thread->clearCompleted();
        } catch (const std::exception& e) {
            std::cerr << "Exception during clear_completed on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    uint32_t check_completed(Capability* cap, CoyoteOper oper) {
        if (!cap) {
            std::cerr << "Error: Null capability for check_completed on node " << node_id << std::endl;
            return 0;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for check_completed on node " << node_id << std::endl;
            return 0;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return 0;
        }
        try {
            return thread->checkCompleted(oper);
        } catch (const std::exception& e) {
            std::cerr << "Exception during check_completed on node " << node_id
                      << ": " << e.what() << std::endl;
            return 0;
        }
    }

    void print_debug(Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for print_debug on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for print_debug on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        try {
            thread->printDebug();
        } catch (const std::exception& e) {
            std::cerr << "Exception during print_debug on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    std::string get_id() const { return node_id; }
    int get_vfid() const { return vfid; }

    cThread<std::any>* get_thread(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_thread on node " << node_id << std::endl;
            return nullptr;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_thread on node " << node_id << std::endl;
            return nullptr;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return nullptr;
        }
        return thread.get();
    }

    // Bypasses capability checks; only safe during initialization.
    cThread<std::any>* get_thread_direct() const { return thread.get(); }

    void* get_mem(size_t size, Capability* cap);

    void free_mem(void* memory, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for free_mem on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for free_mem on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        if (!memory) {
            std::cerr << "Warning: Null memory to free for node " << node_id << std::endl;
            return;
        }
        try {
            thread->freeMem(memory);
        } catch (const std::exception& e) {
            std::cerr << "Exception during free_mem on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    void connect_edges(uint32_t read_offset, uint32_t write_offset, Capability* cap, bool suppress_perm_errors = true) {
        if (!cap) {
            std::cerr << "Error: Null capability for connect_edges on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            if (!suppress_perm_errors) {
                std::cerr << "Error: Insufficient WRITE permission for connect_edges on node " << node_id << std::endl;
            }
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        // Hardware-side connection happens elsewhere; this is just the cap check today.
    }

    void set_operation(CoyoteOper oper, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for set_operation on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for set_operation on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        operation = oper;
    }

    CoyoteOper get_operation(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_operation on node " << node_id << std::endl;
            return CoyoteOper::LOCAL_TRANSFER;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_operation on node " << node_id << std::endl;
            return CoyoteOper::LOCAL_TRANSFER;
        }
        return operation;
    }

    void execute_with_sg(sgEntry* sg, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for execute_with_sg on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::EXECUTE)) {
            std::cerr << "Error: Insufficient EXECUTE permission for execute_with_sg on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        if (!sg) {
            std::cerr << "Error: Null SG entry for execute_with_sg on node " << node_id << std::endl;
            return;
        }
        try {
            thread->invoke(operation, sg, {true, true, true});
        } catch (const std::exception& e) {
            std::cerr << "Exception during execute_with_sg on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    void start_with_sg(sgEntry* sg, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for start_with_sg on node " << node_id << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::EXECUTE)) {
            std::cerr << "Error: Insufficient EXECUTE permission for start_with_sg on node " << node_id << std::endl;
            return;
        }
        if (!thread) {
            std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
            return;
        }
        if (!sg) {
            std::cerr << "Error: Null SG entry for start_with_sg on node " << node_id << std::endl;
            return;
        }
        try {
            thread->invoke(operation, sg, {true, true, false});
        } catch (const std::exception& e) {
            std::cerr << "Exception during start_with_sg on node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    DFG* get_parent_dfg() const { return parent_dfg; }
};

// ================================================================
// DFG
// ================================================================
class DFG {
private:
    std::string app_id;
    std::unordered_map<std::string, std::shared_ptr<Node>> nodes;
    std::unordered_map<std::string, std::shared_ptr<Buffer>> buffers;
    std::unordered_map<std::string, Capability*> capabilities;
    uint32_t device_id;
    bool use_huge_pages;
    StreamMode stream_mode;
    std::atomic<bool> stalled;
    Capability* root_capability = nullptr;

    static std::atomic<int> node_counter;
    static std::atomic<int> buffer_counter;

public:
    DFG(const std::string& app_id, uint32_t device_id, bool use_huge_pages, StreamMode stream_mode)
        : app_id(app_id), device_id(device_id), use_huge_pages(use_huge_pages),
          stream_mode(stream_mode), stalled(false) {
        root_capability = new Capability(app_id + "_root",
            CapabilityPermission::READ | CapabilityPermission::WRITE |
            CapabilityPermission::EXECUTE | CapabilityPermission::DELEGATE |
            CapabilityPermission::TRANSITIVE_DELEGATE,
            nullptr, this, sizeof(DFG), nullptr);
        capabilities[root_capability->get_id()] = root_capability;
    }

    ~DFG() {
        if (root_capability) release_resources(root_capability);
    }

    std::shared_ptr<Node> create_node(Capability* cap, int vfid) {
        std::string node_id = "node_" + std::to_string(node_counter++);
        return create_node(cap, vfid, node_id);
    }

    std::shared_ptr<Node> create_node(Capability* cap, int vfid, const std::string& custom_id);

    std::shared_ptr<Node> get_node(const std::string& node_id, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for get_node" << std::endl;
            return nullptr;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_node" << std::endl;
            return nullptr;
        }
        auto it = nodes.find(node_id);
        if (it != nodes.end()) return it->second;
        return nullptr;
    }

    std::shared_ptr<Buffer> create_buffer(Capability* cap, size_t size) {
        std::string buffer_id = "buffer_" + std::to_string(buffer_counter++);
        return create_buffer(cap, size, buffer_id);
    }

    std::shared_ptr<Buffer> create_buffer(Capability* cap, size_t size, const std::string& custom_id);

    std::shared_ptr<Buffer> get_buffer(const std::string& buffer_id, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for get_buffer" << std::endl;
            return nullptr;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_buffer" << std::endl;
            return nullptr;
        }
        auto it = buffers.find(buffer_id);
        if (it != buffers.end()) return it->second;
        std::cerr << "Error: Buffer not found: " << buffer_id << std::endl;
        return nullptr;
    }

    void set_stalled(bool state, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for set_stalled" << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for set_stalled" << std::endl;
            return;
        }
        stalled.store(state);
    }

    bool is_stalled(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for is_stalled" << std::endl;
            return false;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for is_stalled" << std::endl;
            return false;
        }
        return stalled.load();
    }

    uint32_t get_device_id(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_device_id" << std::endl;
            return 0;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_device_id" << std::endl;
            return 0;
        }
        return device_id;
    }

    StreamMode get_stream_mode(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for get_stream_mode" << std::endl;
            return HOST_STREAM;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for get_stream_mode" << std::endl;
            return HOST_STREAM;
        }
        return stream_mode;
    }

    void set_stream_mode(StreamMode mode, Capability* cap) {
        if (!cap) {
            std::cerr << "Error: Null capability for set_stream_mode" << std::endl;
            return;
        }
        if (!cap->has_permission(CapabilityPermission::WRITE)) {
            std::cerr << "Error: Insufficient WRITE permission for set_stream_mode" << std::endl;
            return;
        }
        stream_mode = mode;
    }

    bool is_using_huge_pages(Capability* cap) const {
        if (!cap) {
            std::cerr << "Error: Null capability for is_using_huge_pages" << std::endl;
            return false;
        }
        if (!cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Insufficient READ permission for is_using_huge_pages" << std::endl;
            return false;
        }
        return use_huge_pages;
    }

    void release_resources(Capability* cap);
    void execute_graph(Node** nodes, int num_nodes, sgEntry* sg_entries, Capability* cap);
    void benchmark_graph(int num_runs, Capability* cap);

    Capability* get_root_capability() const { return root_capability; }
    const std::unordered_map<std::string, std::shared_ptr<Node>>& get_all_nodes() const { return nodes; }
    const std::unordered_map<std::string, Capability*>& get_all_capabilities() const { return capabilities; }

    // ----------------------------------------------------------------
    // Capability management
    // ----------------------------------------------------------------

    Capability* create_root_capability(const std::string& cap_space_id,
                                       uint32_t access,
                                       void* resource = nullptr,
                                       size_t resource_size = 0,
                                       cThread<std::any>* thread = nullptr) {
        if (cap_space_id.empty()) {
            std::cerr << "Error: Empty capability ID for create_root_capability" << std::endl;
            return nullptr;
        }
        if (capabilities.find(cap_space_id) != capabilities.end()) {
            std::cerr << "Error: Capability ID " << cap_space_id << " already exists" << std::endl;
            return nullptr;
        }
        if (!resource) {
            resource = this;
            resource_size = sizeof(DFG);
        }

        Capability* new_cap = root_capability->delegate(cap_space_id, access);
        if (!new_cap) {
            std::cerr << "Error: Failed to delegate from root capability for " << cap_space_id << std::endl;
            return nullptr;
        }
        if (thread) new_cap->set_thread(thread);
        capabilities[cap_space_id] = new_cap;
        return new_cap;
    }

    Capability* delegate_capability(Capability* parent_cap,
                                    const std::string& cap_id,
                                    uint32_t access) {
        if (!parent_cap) {
            std::cerr << "Error: Null parent capability for delegation" << std::endl;
            return nullptr;
        }
        if (cap_id.empty()) {
            std::cerr << "Error: Empty capability ID for delegation" << std::endl;
            return nullptr;
        }
        if (capabilities.find(cap_id) != capabilities.end()) {
            std::cerr << "Error: Capability ID " << cap_id << " already exists" << std::endl;
            return nullptr;
        }

        Capability* new_cap = parent_cap->delegate(cap_id, access);
        if (!new_cap) {
            std::cerr << "Error: Failed to delegate capability " << cap_id
                      << " from parent " << parent_cap->get_id() << std::endl;
            return nullptr;
        }
        capabilities[cap_id] = new_cap;
        return new_cap;
    }

    bool revoke_capability(Capability* cap_to_revoke, Capability* admin_cap) {
        if (!cap_to_revoke) {
            std::cerr << "Error: Null capability to revoke" << std::endl;
            return false;
        }
        if (!admin_cap) {
            std::cerr << "Error: Null administrative capability for revocation" << std::endl;
            return false;
        }
        if (!admin_cap->has_permission(CapabilityPermission::DELEGATE)) {
            std::cerr << "Error: Administrative capability lacks DELEGATE permission for revocation" << std::endl;
            return false;
        }
        if (cap_to_revoke == root_capability) {
            std::cerr << "Error: Cannot revoke root capability" << std::endl;
            return false;
        }

        std::function<void(Capability*)> revoke_recursive;
        revoke_recursive = [this, &revoke_recursive](Capability* cap) {
            if (!cap) return;
            std::vector<Capability*> children = cap->get_children();
            for (auto child : children) {
                if (child) revoke_recursive(child);
            }
            std::string cap_id = cap->get_id();
            capabilities.erase(cap_id);
            Capability* parent = cap->get_parent();
            if (parent) parent->remove_child(cap_id);
            delete cap;
        };

        revoke_recursive(cap_to_revoke);
        return true;
    }

    bool expire_capability(Capability* cap, Capability* admin_cap, uint32_t timeout) {
        if (!cap) {
            std::cerr << "Error: Null capability for expiration" << std::endl;
            return false;
        }
        if (!admin_cap) {
            std::cerr << "Error: Null administrative capability for expiration" << std::endl;
            return false;
        }
        if (!admin_cap->has_permission(CapabilityPermission::DELEGATE)) {
            std::cerr << "Error: Administrative capability lacks DELEGATE permission for expiration" << std::endl;
            return false;
        }
        cap->set_expiry(std::chrono::seconds(timeout));
        return true;
    }

    Capability* find_capability(const std::string& cap_id, Capability* admin_cap) {
        if (cap_id.empty()) {
            std::cerr << "Error: Empty capability ID for find_capability" << std::endl;
            return nullptr;
        }
        if (!admin_cap) {
            std::cerr << "Error: Null administrative capability for find_capability" << std::endl;
            return nullptr;
        }
        if (!admin_cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Administrative capability lacks READ permission for capability lookup" << std::endl;
            return nullptr;
        }
        auto it = capabilities.find(cap_id);
        if (it != capabilities.end()) return it->second;
        return nullptr;
    }

    void print_capability_tree(Capability* admin_cap) const {
        if (!admin_cap) {
            std::cerr << "Error: Null administrative capability for print_capability_tree" << std::endl;
            return;
        }
        if (!admin_cap->has_permission(CapabilityPermission::READ)) {
            std::cerr << "Error: Administrative capability lacks read permission for printing capability tree" << std::endl;
            return;
        }
        if (root_capability) {
            std::cout << "Capability Tree:" << std::endl;
            root_capability->print_tree();
        } else {
            std::cout << "No root capability found." << std::endl;
        }
    }
};

std::atomic<int> DFG::node_counter{0};
std::atomic<int> DFG::buffer_counter{0};

// ================================================================
// Out-of-line implementations
// ================================================================

void* Node::get_mem(size_t size, Capability* cap) {
    if (!cap) {
        std::cerr << "Error: Null capability for get_mem on node " << node_id << std::endl;
        return nullptr;
    }
    if (!cap->has_permission(CapabilityPermission::WRITE)) {
        std::cerr << "Error: Insufficient WRITE permission for get_mem on node " << node_id << std::endl;
        return nullptr;
    }
    if (!thread) {
        std::cerr << "Error: Thread not initialized for node " << node_id << std::endl;
        return nullptr;
    }

    CoyoteAlloc alloc_type = CoyoteAlloc::HPF;
    if (parent_dfg) {
        Capability* root_cap = parent_dfg->get_root_capability();
        if (root_cap && !parent_dfg->is_using_huge_pages(root_cap)) {
            alloc_type = CoyoteAlloc::REG;
        }
    }

    try {
        size_t aligned_size = (size + 63) & ~63;
        void* memory = thread->getMem({alloc_type, static_cast<uint32_t>(aligned_size)});
        if (!memory) {
            std::cerr << "Error: Failed to allocate memory of size " << aligned_size
                      << " for node " << node_id << std::endl;
        }
        return memory;
    } catch (const std::exception& e) {
        std::cerr << "Exception during memory allocation for node " << node_id
                  << ": " << e.what() << std::endl;
        return nullptr;
    }
}

Node::Node(const std::string& node_id, DFG* parent_dfg, int vfid)
    : node_id(node_id), vfid(vfid), parent_dfg(parent_dfg) {
    try {
        uint32_t device_id = 0;
        if (parent_dfg) {
            Capability* root_cap = parent_dfg->get_root_capability();
            if (root_cap) device_id = parent_dfg->get_device_id(root_cap);
        }
        thread = std::make_shared<cThread<std::any>>(vfid, getpid(), device_id);
        if (!thread) throw std::runtime_error("Failed to create thread for node " + node_id);
    } catch (const std::exception& e) {
        std::cerr << "Exception during thread creation for node " << node_id << ": " << e.what() << std::endl;
        // Node still exists; thread stays null and gets checked in every method.
    }
}

std::shared_ptr<Node> DFG::create_node(Capability* cap, int vfid, const std::string& custom_id) {
    if (custom_id.empty()) {
        std::cerr << "Error: Empty node ID for create_node" << std::endl;
        return nullptr;
    }
    if (!cap) {
        std::cerr << "Error: Null capability for create_node" << std::endl;
        return nullptr;
    }
    if (!cap->has_permission(CapabilityPermission::WRITE)) {
        std::cerr << "Error: Insufficient WRITE permission for create_node" << std::endl;
        return nullptr;
    }
    if (nodes.find(custom_id) != nodes.end()) {
        std::cerr << "Error: Node " << custom_id << " already exists" << std::endl;
        return nullptr;
    }

    try {
        auto node = std::make_shared<Node>(custom_id, this, vfid);
        if (!node) throw std::runtime_error("Failed to create node object");

        cThread<std::any>* thread_ptr = node->get_thread_direct();
        if (!thread_ptr) throw std::runtime_error("Node created but thread initialization failed");

        nodes[custom_id] = node;

        std::string node_cap_id = custom_id + "_cap";
        Capability* node_cap = create_root_capability(
            node_cap_id,
            CapabilityPermission::READ | CapabilityPermission::WRITE |
            CapabilityPermission::EXECUTE | CapabilityPermission::DELEGATE |
            CapabilityPermission::TRANSITIVE_DELEGATE,
            node.get(), sizeof(Node), thread_ptr);

        if (!node_cap) {
            nodes.erase(custom_id);
            throw std::runtime_error("Failed to create capability for node");
        }

        std::cout << "Successfully created node " << custom_id << " with thread "
                  << thread_ptr << " and capability " << node_cap_id << std::endl;
        return node;
    } catch (const std::exception& e) {
        std::cerr << "Exception during node creation: " << e.what() << std::endl;
        return nullptr;
    }
}

std::shared_ptr<Buffer> DFG::create_buffer(Capability* cap, size_t size, const std::string& custom_id) {
    if (custom_id.empty()) {
        std::cerr << "Error: Empty buffer ID for create_buffer" << std::endl;
        return nullptr;
    }
    if (!cap) {
        std::cerr << "Error: Null capability for create_buffer" << std::endl;
        return nullptr;
    }
    if (size == 0) {
        std::cerr << "Error: Zero size for buffer " << custom_id << std::endl;
        return nullptr;
    }
    if (!cap->has_permission(CapabilityPermission::WRITE)) {
        std::cerr << "Error: Insufficient WRITE permission for create_buffer" << std::endl;
        return nullptr;
    }
    if (buffers.find(custom_id) != buffers.end()) {
        std::cerr << "Error: Buffer " << custom_id << " already exists" << std::endl;
        return nullptr;
    }
    if (nodes.empty()) {
        std::cerr << "Error: No nodes available for memory allocation" << std::endl;
        return nullptr;
    }

    // Walk known nodes and allocate via the first one whose cap we can find.
    void* memory = nullptr;
    Node* allocating_node = nullptr;
    for (const auto& node_pair : nodes) {
        auto node = node_pair.second;
        if (!node) continue;

        std::string node_id = node->get_id();
        std::string node_cap_id = node_id + "_cap";
        Capability* node_cap = find_capability(node_cap_id, cap);
        if (!node_cap) continue;

        try {
            size_t aligned_size = (size + 63) & ~63;
            memory = node->get_mem(aligned_size, node_cap);
            if (memory) {
                allocating_node = node.get();
                std::cout << "Mapped mem at: " << memory << std::endl;
                break;
            }
        } catch (const std::exception& e) {
            std::cerr << "Exception during memory allocation with node " << node_id
                      << ": " << e.what() << std::endl;
        }
    }

    if (!memory || !allocating_node) {
        std::cerr << "Error: Failed to allocate memory for buffer using any available node" << std::endl;
        return nullptr;
    }

    try {
        auto buffer = std::make_shared<Buffer>(custom_id, this, memory, size);
        if (!buffer) throw std::runtime_error("Failed to create buffer object");
        buffers[custom_id] = buffer;

        std::string buffer_cap_id = custom_id + "_cap";
        Capability* buffer_cap = create_root_capability(
            buffer_cap_id,
            CapabilityPermission::READ | CapabilityPermission::WRITE |
            CapabilityPermission::DELEGATE | CapabilityPermission::TRANSITIVE_DELEGATE,
            memory, size);

        if (!buffer_cap) {
            std::string node_id = allocating_node->get_id();
            std::string node_cap_id = node_id + "_cap";
            Capability* node_cap = find_capability(node_cap_id, cap);
            if (node_cap) allocating_node->free_mem(memory, node_cap);
            buffers.erase(custom_id);
            throw std::runtime_error("Failed to create capability for buffer");
        }

        std::cout << "Successfully created buffer " << custom_id << " of size " << size << std::endl;
        return buffer;
    } catch (const std::exception& e) {
        std::cerr << "Exception during buffer creation: " << e.what() << std::endl;
        if (memory && allocating_node) {
            std::string node_id = allocating_node->get_id();
            std::string node_cap_id = node_id + "_cap";
            Capability* node_cap = find_capability(node_cap_id, cap);
            if (node_cap) allocating_node->free_mem(memory, node_cap);
        }
        return nullptr;
    }
}

void DFG::execute_graph(Node** nodes, int num_nodes, sgEntry* sg_entries, Capability* cap) {
    if (!cap || !cap->has_permission(CapabilityPermission::EXECUTE) || !cap->is_for_resource(this)) {
        std::cerr << "Error: Invalid or insufficient capability for execute_graph" << std::endl;
        return;
    }
    if (!nodes || num_nodes <= 0 || !sg_entries) {
        std::cerr << "Error: Invalid parameters for execute_graph" << std::endl;
        return;
    }

    std::vector<Capability*> node_caps(num_nodes, nullptr);
    for (int i = 0; i < num_nodes; i++) {
        if (!nodes[i]) {
            std::cerr << "Error: Null node at index " << i << " in execute_graph" << std::endl;
            return;
        }
        std::string node_id = nodes[i]->get_id();
        std::string node_cap_id = node_id + "_cap";
        node_caps[i] = find_capability(node_cap_id, cap);
        if (!node_caps[i]) {
            std::cerr << "Error: Capability not found for node " << node_id << std::endl;
            return;
        }
        try {
            nodes[i]->clear_completed(node_caps[i]);
        } catch (const std::exception& e) {
            std::cerr << "Exception clearing completion counter for node " << node_id
                      << ": " << e.what() << std::endl;
            return;
        }
    }

    for (int i = 0; i < num_nodes; i++) {
        try {
            // Cap-secured fetch then direct invoke with LOCAL_TRANSFER.
            cThread<std::any>* thread = nodes[i]->get_thread(node_caps[i]);
            if (thread) {
                thread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg_entries[i], {true, true, false});
            } else {
                std::cerr << "Error: Failed to get thread for node " << nodes[i]->get_id() << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "Exception during node execution for " << nodes[i]->get_id()
                      << ": " << e.what() << std::endl;
            stalled.store(true);
            return;
        }
    }
}

void DFG::release_resources(Capability* cap) {
    if (!cap) {
        std::cerr << "Error: Null capability for release_resources" << std::endl;
        return;
    }
    if (!cap->has_permission(CapabilityPermission::WRITE)) {
        std::cerr << "Error: Insufficient WRITE permission for release_resources" << std::endl;
        return;
    }

    stalled.store(true);

    for (const auto& node_pair : nodes) {
        auto node = node_pair.second;
        if (!node) continue;

        std::string node_id = node->get_id();
        std::string node_cap_id = node_id + "_cap";
        Capability* node_cap = find_capability(node_cap_id, cap);
        if (!node_cap) {
            std::cerr << "Warning: Could not find capability for node " << node_id << " during cleanup" << std::endl;
            continue;
        }

        try {
            node->clear_completed(node_cap);
        } catch (const std::exception& e) {
            std::cerr << "Exception clearing completion for node " << node_id
                      << ": " << e.what() << std::endl;
        }

        for (auto& buffer_pair : buffers) {
            auto buffer = buffer_pair.second;
            if (!buffer) continue;

            std::string buffer_id = buffer->get_id();
            std::string buffer_cap_id = buffer_id + "_cap";
            Capability* buffer_cap = find_capability(buffer_cap_id, cap);
            if (!buffer_cap) {
                std::cerr << "Warning: Could not find capability for buffer " << buffer_id << " during cleanup" << std::endl;
                continue;
            }
            try {
                void* memory = buffer->get_memory(buffer_cap);
                if (memory) node->free_mem(memory, node_cap);
            } catch (const std::exception& e) {
                std::cerr << "Exception freeing memory for buffer " << buffer_id
                          << ": " << e.what() << std::endl;
            }
        }
    }

    // Revoke non-root caps in reverse-insertion order so children go before parents.
    std::vector<std::string> cap_ids_to_revoke;
    for (const auto& cap_pair : capabilities) {
        if (cap_pair.second != root_capability) cap_ids_to_revoke.push_back(cap_pair.first);
    }
    for (auto it = cap_ids_to_revoke.rbegin(); it != cap_ids_to_revoke.rend(); ++it) {
        Capability* cap_to_revoke = capabilities[*it];
        if (cap_to_revoke) revoke_capability(cap_to_revoke, root_capability);
    }

    capabilities.clear();
    nodes.clear();
    buffers.clear();
    if (root_capability) capabilities[root_capability->get_id()] = root_capability;
}

void DFG::benchmark_graph(int num_runs, Capability* cap) {
    if (!cap) {
        std::cerr << "Error: Null capability for benchmark_graph" << std::endl;
        return;
    }
    if (!cap->has_permission(CapabilityPermission::EXECUTE)) {
        std::cerr << "Error: Insufficient EXECUTE permission for benchmark_graph" << std::endl;
        return;
    }
    if (num_runs <= 0) {
        std::cerr << "Error: Invalid number of runs for benchmark_graph: " << num_runs << std::endl;
        return;
    }

    try {
        cBench bench(num_runs);
        // Placeholder workload; real benchmarking happens in cBench-using callers.
        auto benchmark_func = []() {};
        bench.runtime(benchmark_func);

        std::cout << "Performance Metrics:" << std::endl;
        std::cout << "Average Execution Time: " << bench.getAvg() << " ns" << std::endl;
        std::cout << "Min Execution Time: " << bench.getMin() << " ns" << std::endl;
        std::cout << "Max Execution Time: " << bench.getMax() << " ns" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Exception during benchmark_graph: " << e.what() << std::endl;
    }
}

// ================================================================
// Factory functions (root-cap shortcuts for the common case)
// ================================================================

DFG* create_dfg(const std::string& app_id, uint32_t device_id = 0, bool use_huge_pages = true, StreamMode stream_mode = HOST_STREAM) {
    if (app_id.empty()) {
        std::cerr << "Error: Empty application ID for create_dfg" << std::endl;
        return nullptr;
    }
    try {
        return new DFG(app_id, device_id, use_huge_pages, stream_mode);
    } catch (const std::exception& e) {
        std::cerr << "Exception during DFG creation: " << e.what() << std::endl;
        return nullptr;
    }
}

Node* create_node(DFG* dfg, int vfid = 0) {
    if (!dfg) {
        std::cerr << "Error: Null DFG for create_node" << std::endl;
        return nullptr;
    }
    Capability* root_cap = dfg->get_root_capability();
    if (!root_cap) {
        std::cerr << "Error: Could not get root capability for node creation" << std::endl;
        return nullptr;
    }
    try {
        auto node = dfg->create_node(root_cap, vfid);
        return node.get();
    } catch (const std::exception& e) {
        std::cerr << "Exception during node creation: " << e.what() << std::endl;
        return nullptr;
    }
}

Node* create_node(DFG* dfg, int vfid, const std::string& custom_id) {
    if (!dfg) {
        std::cerr << "Error: Null DFG for create_node" << std::endl;
        return nullptr;
    }
    if (custom_id.empty()) {
        std::cerr << "Error: Empty node ID for create_node" << std::endl;
        return nullptr;
    }
    Capability* root_cap = dfg->get_root_capability();
    if (!root_cap) {
        std::cerr << "Error: Could not get root capability for node creation" << std::endl;
        return nullptr;
    }
    try {
        auto node = dfg->create_node(root_cap, vfid, custom_id);
        return node.get();
    } catch (const std::exception& e) {
        std::cerr << "Exception during node creation: " << e.what() << std::endl;
        return nullptr;
    }
}

Buffer* create_buffer(DFG* dfg, size_t size) {
    if (!dfg) return nullptr;
    Capability* root_cap = dfg->get_root_capability();
    auto buffer = dfg->create_buffer(root_cap, size);
    return buffer.get();
}

Buffer* create_buffer(DFG* dfg, size_t size, const std::string& custom_id) {
    if (!dfg) return nullptr;
    Capability* root_cap = dfg->get_root_capability();
    auto buffer = dfg->create_buffer(root_cap, size, custom_id);
    return buffer.get();
}

bool connect_edges(const std::string& source_id, const std::string& target_id, DFG* dfg,
                   uint32_t read_offset = 0, uint32_t write_offset = 0, bool suppress_expected_errors = true) {
    if (!dfg) return false;
    Capability* root_cap = dfg->get_root_capability();

    auto source_node = dfg->get_node(source_id, root_cap);
    auto target_node = dfg->get_node(target_id, root_cap);
    if (!source_node && !suppress_expected_errors) {
        std::cerr << "Error: Node not found: " << source_id << std::endl;
    }
    if (!target_node && !suppress_expected_errors) {
        std::cerr << "Error: Node not found: " << target_id << std::endl;
    }

    std::string source_cap_id = source_id + "_cap";
    std::string target_cap_id = target_id + "_cap";
    Capability* source_cap = dfg->find_capability(source_cap_id, root_cap);
    Capability* target_cap = dfg->find_capability(target_cap_id, root_cap);
    if (!source_cap || !target_cap) {
        std::cerr << "Error: Source or Destination capability not found" << std::endl;
        return false;
    }

    std::string conn_cap_id = source_id + "_to_" + target_id;
    uint32_t source_conn_perms = CapabilityPermission::READ | CapabilityPermission::DELEGATE |
                                 CapabilityPermission::TRANSITIVE_DELEGATE;
    Capability* conn_source_cap = dfg->delegate_capability(source_cap, conn_cap_id + "_src", source_conn_perms);

    uint32_t target_conn_perms = CapabilityPermission::WRITE | CapabilityPermission::DELEGATE |
                                 CapabilityPermission::TRANSITIVE_DELEGATE;
    Capability* conn_target_cap = dfg->delegate_capability(target_cap, conn_cap_id + "_dest", target_conn_perms);

    if (!conn_source_cap || !conn_target_cap) {
        std::cerr << "Error: Failed to create connection capabilities" << std::endl;
        return false;
    }

    if (source_node) source_node->connect_edges(read_offset, write_offset, conn_source_cap);
    if (target_node) target_node->connect_edges(write_offset, read_offset, conn_target_cap);
    return true;
}

bool disconnect_edges(const std::string& source_id, const std::string& target_id, DFG* dfg) {
    if (!dfg) return false;
    Capability* root_cap = dfg->get_root_capability();

    std::string conn_source_cap_id = source_id + "_to_" + target_id + "_src";
    std::string conn_target_cap_id = source_id + "_to_" + target_id + "_dest";
    Capability* conn_source_cap = dfg->find_capability(conn_source_cap_id, root_cap);
    Capability* conn_target_cap = dfg->find_capability(conn_target_cap_id, root_cap);

    bool success = true;
    if (conn_source_cap) success &= dfg->revoke_capability(conn_source_cap, root_cap);
    if (conn_target_cap) success &= dfg->revoke_capability(conn_target_cap, root_cap);
    return success;
}

void execute_graph(DFG* dfg, Node** nodes, int num_nodes, sgEntry* sg_entries) {
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    dfg->execute_graph(nodes, num_nodes, sg_entries, root_cap);
}

void write_buffer(Buffer* buffer, void* data, size_t size) {
    if (!buffer || !data) return;
    DFG* dfg = buffer->get_parent_dfg();
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    std::string buffer_cap_id = buffer->get_id() + "_cap";
    Capability* buffer_cap = dfg->find_capability(buffer_cap_id, root_cap);
    if (buffer_cap) buffer->write_data(data, size, buffer_cap);
}

void* read_buffer(Buffer* buffer) {
    if (!buffer) return nullptr;
    DFG* dfg = buffer->get_parent_dfg();
    if (!dfg) return nullptr;
    Capability* root_cap = dfg->get_root_capability();
    std::string buffer_cap_id = buffer->get_id() + "_cap";
    Capability* buffer_cap = dfg->find_capability(buffer_cap_id, root_cap);
    if (buffer_cap) return buffer->get_memory(buffer_cap);
    return nullptr;
}

// Stubs preserved for API compatibility; would need a parent_dfg back-pointer
// on Node to do anything meaningful.
void configure_node_io_switch(Node* node, IODevs io_switch) {
    if (!node) return;
    DFG* dfg = nullptr;
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    std::string node_cap_id = node->get_id() + "_cap";
    Capability* node_cap = dfg->find_capability(node_cap_id, root_cap);
    if (node_cap) node->set_io_switch(io_switch, node_cap);
}

void set_node_operation(Node* node, CoyoteOper operation) {
    if (!node) return;
    DFG* dfg = nullptr;
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    std::string node_cap_id = node->get_id() + "_cap";
    Capability* node_cap = dfg->find_capability(node_cap_id, root_cap);
    if (node_cap) node->set_operation(operation, node_cap);
}

void release_resources(DFG* dfg) {
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    dfg->release_resources(root_cap);
    delete dfg;
}

void print_capability_tree(DFG* dfg) {
    if (!dfg) return;
    Capability* root_cap = dfg->get_root_capability();
    dfg->print_capability_tree(root_cap);
}

Capability* create_capability(DFG* dfg,
                              const std::string& app_id,
                              const std::string& node_buf_id,
                              const std::string& cap_space_id,
                              uint32_t access,
                              bool allow_transitive_delegation = false) {
    if (!dfg) return nullptr;
    if (allow_transitive_delegation) access |= CapabilityPermission::TRANSITIVE_DELEGATE;

    Capability* root_cap = dfg->get_root_capability();
    std::string resource_cap_id = node_buf_id + "_cap";
    Capability* resource_cap = dfg->find_capability(resource_cap_id, root_cap);
    if (!resource_cap) {
        std::cerr << "Error: Resource capability not found for " << node_buf_id << std::endl;
        return nullptr;
    }
    return dfg->delegate_capability(resource_cap, cap_space_id, access);
}

Capability* delegate_capability(DFG* dfg,
                                const std::string& app_id,
                                const std::string& node_buf_id,
                                const std::string& cap_space_id,
                                uint32_t access,
                                bool allow_transitive_delegation = false) {
    if (allow_transitive_delegation) access |= CapabilityPermission::TRANSITIVE_DELEGATE;
    return create_capability(dfg, app_id, node_buf_id, cap_space_id, access, false);
}

bool transfer_ownership(DFG* dfg,
                        const std::string& app_id,
                        const std::string& source_id,
                        const std::string& target_id) {
    if (!dfg) return false;
    std::cerr << "Error: Transfer ownership not supported in this security model" << std::endl;
    return false;
}

bool revoke_capability(DFG* dfg,
                       const std::string& app_id,
                       const std::string& node_buf_id,
                       const std::string& cap_space_id) {
    if (!dfg) return false;
    Capability* root_cap = dfg->get_root_capability();
    Capability* cap_to_revoke = dfg->find_capability(cap_space_id, root_cap);
    if (!cap_to_revoke) {
        std::cerr << "Error: Capability not found for revocation: " << cap_space_id << std::endl;
        return false;
    }
    return dfg->revoke_capability(cap_to_revoke, root_cap);
}

bool expire_capability(DFG* dfg,
                       const std::string& app_id,
                       const std::string& node_buf_id,
                       const std::string& cap_space_id,
                       uint32_t timeout) {
    if (!dfg) return false;
    Capability* root_cap = dfg->get_root_capability();
    Capability* cap_to_expire = dfg->find_capability(cap_space_id, root_cap);
    if (!cap_to_expire) {
        std::cerr << "Error: Capability not found for expiration: " << cap_space_id << std::endl;
        return false;
    }
    return dfg->expire_capability(cap_to_expire, root_cap, timeout);
}

bool reset_capabilities(DFG* dfg,
                        const std::string& app_id,
                        const std::string& node_buf_id) {
    if (!dfg) return false;
    Capability* root_cap = dfg->get_root_capability();
    std::string component_cap_id = node_buf_id + "_cap";
    Capability* component_cap = dfg->find_capability(component_cap_id, root_cap);
    if (!component_cap) {
        std::cerr << "Error: Component capability not found: " << component_cap_id << std::endl;
        return false;
    }
    const auto& children = component_cap->get_children();
    bool success = true;
    for (auto* child : children) success &= dfg->revoke_capability(child, root_cap);
    return success;
}

} // namespace dfg
