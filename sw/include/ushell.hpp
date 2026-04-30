#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <queue>
#include <unordered_map>
#include <memory>
#include <functional>
#include <atomic>
#include <algorithm>
#include <chrono>
#include <cstring>
#include <unistd.h>
#include "dfg.hpp"

namespace ushell {

using namespace fpga;
using namespace std;

class Task;
class Buffer;
class Dataflow;

// ================================================================
// Task — wraps a dfg::Node with a friendlier interface
// ================================================================
class Task {
private:
    std::string name;
    std::string type;
    dfg::Node* internal_node;
    dfg::Capability* node_capability;
    Dataflow* parent_dataflow;
    int vfid;

public:
    struct Port {
        Task* parent;
        std::string port_name;
        Port(Task* p, const std::string& name) : parent(p), port_name(name) {}
        std::string get_task_name() const { return parent ? parent->get_name() : ""; }
    };

    Port in;
    Port out;

    Task(const std::string& task_name, const std::string& task_type = "processing", Dataflow* parent = nullptr);
    ~Task() = default;

    std::string get_name() const { return name; }
    std::string get_type() const { return type; }
    dfg::Node* get_internal_node() const { return internal_node; }
    dfg::Capability* get_capability() const { return node_capability; }
    int get_vfid() const { return vfid; }

    void set_internal_node(dfg::Node* node) { internal_node = node; }
    void set_capability(dfg::Capability* cap) { node_capability = cap; }
    void set_vfid(int id) { vfid = id; }
};

// ================================================================
// Buffer — host-side wrapper around a dfg::Buffer
// ================================================================
class Buffer {
private:
    void* host_ptr;
    size_t size;
    bool owns_memory;
    dfg::Buffer* internal_buffer;
    dfg::Capability* buffer_capability;
    std::string buffer_name;
    Dataflow* parent_dataflow;

public:
    Buffer(void* host_memory, size_t buffer_size = 0, const std::string& name = "", Dataflow* parent = nullptr);
    Buffer(size_t buffer_size, const std::string& name = "", Dataflow* parent = nullptr);
    ~Buffer();

    void* get_host_ptr() const { return host_ptr; }
    size_t get_size() const { return size; }
    dfg::Buffer* get_internal_buffer() const { return internal_buffer; }
    dfg::Capability* get_capability() const { return buffer_capability; }
    std::string get_name() const { return buffer_name; }

    bool write_data(void* data, size_t data_size);
    bool read_data(void* dest, size_t data_size);
    bool write_from_host(void* data, size_t data_size);
    bool read_to_host(void* dest, size_t data_size);

    void set_internal_buffer(dfg::Buffer* buffer) { internal_buffer = buffer; }
    void set_capability(dfg::Capability* cap) { buffer_capability = cap; }
    void set_name(const std::string& name) { buffer_name = name; }
};

// ================================================================
// Dataflow — orchestrates a dfg::DFG with capability bookkeeping
// ================================================================
class Dataflow {
private:
    struct Connection {
        std::string src_name;
        std::string dst_name;
        std::string src_port;
        std::string dst_port;
        std::string src_type; // "task" or "buffer"
        std::string dst_type;
    };

    std::string dataflow_name;
    std::vector<Connection> connections;
    std::vector<std::unique_ptr<Task>> tasks;
    std::vector<std::unique_ptr<Buffer>> buffers;
    std::unordered_map<std::string, Task*> task_map;
    std::unordered_map<std::string, Buffer*> buffer_map;

    dfg::DFG* dfg;
    std::vector<dfg::Node*> nodes;
    std::unordered_map<std::string, dfg::Node*> node_map;
    std::unordered_map<std::string, dfg::Buffer*> raw_buffers;
    std::vector<std::string> flow;

    dfg::Capability* dfg_root_capability;
    std::unordered_map<std::string, dfg::Capability*> node_capabilities;
    std::unordered_map<std::string, dfg::Capability*> buffer_capabilities;
    std::unordered_map<std::string, dfg::Capability*> connection_capabilities;

    bool is_built;
    bool is_checked;
    int debug_level = 1; // 0=minimal, 1=normal, 2=verbose

    void build_internal_dfg();
    void setup_capabilities();
    void create_internal_nodes();
    void create_internal_buffers();
    void setup_connections();
    void configure_io_switches();
    void setup_operations();

    bool validate_connections();
    std::vector<std::string> build_execution_flow();

    size_t detect_buffer_size(void* ptr);
    std::string generate_unique_name(const std::string& prefix);

    static std::atomic<int> task_counter;
    static std::atomic<int> buffer_counter;
    static std::atomic<int> dataflow_counter;

public:
    Dataflow(const std::string& name = "");
    ~Dataflow();

    Task& add_task(const std::string& name, const std::string& type = "processing");
    Buffer& add_buffer(void* host_memory, size_t size = 0, const std::string& name = "");
    Buffer& add_buffer(size_t size, const std::string& name = "");

    Dataflow& to(Buffer& src, Task::Port& dst);
    Dataflow& to(Task::Port& src, Task::Port& dst);
    Dataflow& to(Task::Port& src, Buffer& dst);

    bool check();
    void execute(size_t current_size = 0);

    void release();
    void clear_completed();

    void set_debug_level(int level) { debug_level = level; }
    int get_debug_level() const { return debug_level; }

    Task* get_task(const std::string& name);
    Buffer* get_buffer(const std::string& name);
    dfg::DFG* get_dfg() const { return dfg; }
    dfg::Capability* get_root_capability() const { return dfg_root_capability; }

    dfg::Capability* create_capability(const std::string& component_name,
                                       const std::string& cap_space_id,
                                       uint32_t access,
                                       bool allow_transitive_delegation = false);
    dfg::Capability* delegate_capability(const std::string& src_component,
                                         const std::string& cap_space_id,
                                         uint32_t access,
                                         bool allow_transitive_delegation = false);
    bool can_component_delegate_delegation(const std::string& component_name) const;
    bool transfer_ownership(const std::string& src_component, const std::string& dst_component);
    bool revoke_capability(const std::string& component_name, const std::string& cap_space_id);
    bool expire_capability(const std::string& component_name, const std::string& cap_space_id, uint32_t timeout);
    bool reset_capabilities(const std::string& component_name);
    void print_capability_tree() const;

    void print_graph() const;
    void print_connections() const;
};

std::atomic<int> Dataflow::task_counter{0};
std::atomic<int> Dataflow::buffer_counter{0};
std::atomic<int> Dataflow::dataflow_counter{0};

// ================================================================
// Task implementation
// ================================================================
Task::Task(const std::string& task_name, const std::string& task_type, Dataflow* parent)
    : name(task_name), type(task_type), internal_node(nullptr), node_capability(nullptr),
      parent_dataflow(parent), vfid(0), in(this, "input"), out(this, "output") {}

// ================================================================
// Buffer implementation
// ================================================================
Buffer::Buffer(void* host_memory, size_t buffer_size, const std::string& name, Dataflow* parent)
    : host_ptr(host_memory), size(buffer_size), owns_memory(false), internal_buffer(nullptr),
      buffer_capability(nullptr), buffer_name(name), parent_dataflow(parent) {
    // Fallback for callers that pass a pointer with unknown size.
    if (size == 0 && host_ptr) size = 65536;
}

Buffer::Buffer(size_t buffer_size, const std::string& name, Dataflow* parent)
    : size(buffer_size), owns_memory(true), internal_buffer(nullptr),
      buffer_capability(nullptr), buffer_name(name), parent_dataflow(parent) {
    host_ptr = malloc(size);
    if (!host_ptr) throw std::runtime_error("Failed to allocate memory for buffer");
    memset(host_ptr, 0, size);
}

Buffer::~Buffer() {
    if (owns_memory && host_ptr) free(host_ptr);
}

bool Buffer::write_data(void* data, size_t data_size) {
    if (!data || data_size == 0 || data_size > size) return false;
    memcpy(host_ptr, data, data_size);
    if (internal_buffer) dfg::write_buffer(internal_buffer, data, data_size);
    return true;
}

bool Buffer::read_data(void* dest, size_t data_size) {
    if (!dest || data_size == 0 || data_size > size) return false;
    if (internal_buffer) {
        void* device_memory = dfg::read_buffer(internal_buffer);
        if (device_memory) {
            memcpy(dest, device_memory, data_size);
            memcpy(host_ptr, device_memory, data_size);
            return true;
        }
    }
    memcpy(dest, host_ptr, data_size);
    return true;
}

bool Buffer::write_from_host(void* data, size_t data_size) {
    if (!data || data_size == 0 || data_size > size) return false;
    memcpy(host_ptr, data, data_size);
    if (internal_buffer) {
        dfg::write_buffer(internal_buffer, data, data_size);
        return true;
    }
    return false;
}

bool Buffer::read_to_host(void* dest, size_t data_size) {
    if (!dest || data_size == 0 || data_size > size) return false;
    if (internal_buffer) {
        void* device_memory = dfg::read_buffer(internal_buffer);
        if (device_memory) {
            memcpy(dest, device_memory, data_size);
            memcpy(host_ptr, device_memory, data_size);
            return true;
        }
    }
    memcpy(dest, host_ptr, data_size);
    return true;
}

// ================================================================
// Dataflow implementation
// ================================================================
Dataflow::Dataflow(const std::string& name)
    : dataflow_name(name.empty() ? "dataflow_" + std::to_string(dataflow_counter++) : name),
      dfg(nullptr), dfg_root_capability(nullptr), is_built(false), is_checked(false) {}

Dataflow::~Dataflow() { release(); }

Task& Dataflow::add_task(const std::string& name, const std::string& type) {
    std::string task_name = name.empty() ? "task_" + std::to_string(task_counter++) : name;
    if (task_map.find(task_name) != task_map.end()) {
        throw std::runtime_error("Task '" + task_name + "' already exists");
    }
    auto task = std::make_unique<Task>(task_name, type, this);
    Task* task_ptr = task.get();
    task_map[task_name] = task_ptr;
    tasks.push_back(std::move(task));
    return *task_ptr;
}

Buffer& Dataflow::add_buffer(void* host_memory, size_t size, const std::string& name) {
    std::string buffer_name = name.empty() ? "buffer_" + std::to_string(buffer_counter++) : name;
    if (buffer_map.find(buffer_name) != buffer_map.end()) {
        throw std::runtime_error("Buffer '" + buffer_name + "' already exists");
    }
    auto buffer = std::make_unique<Buffer>(host_memory, size, buffer_name, this);
    Buffer* buffer_ptr = buffer.get();
    buffer_map[buffer_name] = buffer_ptr;
    buffers.push_back(std::move(buffer));
    return *buffer_ptr;
}

Buffer& Dataflow::add_buffer(size_t size, const std::string& name) {
    std::string buffer_name = name.empty() ? "buffer_" + std::to_string(buffer_counter++) : name;
    if (buffer_map.find(buffer_name) != buffer_map.end()) {
        throw std::runtime_error("Buffer '" + buffer_name + "' already exists");
    }
    auto buffer = std::make_unique<Buffer>(size, buffer_name, this);
    Buffer* buffer_ptr = buffer.get();
    buffer_map[buffer_name] = buffer_ptr;
    buffers.push_back(std::move(buffer));
    return *buffer_ptr;
}

Dataflow& Dataflow::to(Buffer& src, Task::Port& dst) {
    Connection conn;
    conn.src_name = src.get_name();
    conn.dst_name = dst.get_task_name();
    conn.src_port = "output";
    conn.dst_port = dst.port_name;
    conn.src_type = "buffer";
    conn.dst_type = "task";
    connections.push_back(conn);
    is_built = false;
    return *this;
}

Dataflow& Dataflow::to(Task::Port& src, Task::Port& dst) {
    Connection conn;
    conn.src_name = src.get_task_name();
    conn.dst_name = dst.get_task_name();
    conn.src_port = src.port_name;
    conn.dst_port = dst.port_name;
    conn.src_type = "task";
    conn.dst_type = "task";
    connections.push_back(conn);
    is_built = false;
    return *this;
}

Dataflow& Dataflow::to(Task::Port& src, Buffer& dst) {
    Connection conn;
    conn.src_name = src.get_task_name();
    conn.dst_name = dst.get_name();
    conn.src_port = src.port_name;
    conn.dst_port = "input";
    conn.src_type = "task";
    conn.dst_type = "buffer";
    connections.push_back(conn);
    is_built = false;
    return *this;
}

bool Dataflow::validate_connections() {
    for (const auto& conn : connections) {
        if (conn.src_type == "task" && task_map.find(conn.src_name) == task_map.end()) {
            std::cerr << "Error: Source task '" << conn.src_name << "' not found" << std::endl;
            return false;
        }
        if (conn.src_type == "buffer" && buffer_map.find(conn.src_name) == buffer_map.end()) {
            std::cerr << "Error: Source buffer '" << conn.src_name << "' not found" << std::endl;
            return false;
        }
        if (conn.dst_type == "task" && task_map.find(conn.dst_name) == task_map.end()) {
            std::cerr << "Error: Destination task '" << conn.dst_name << "' not found" << std::endl;
            return false;
        }
        if (conn.dst_type == "buffer" && buffer_map.find(conn.dst_name) == buffer_map.end()) {
            std::cerr << "Error: Destination buffer '" << conn.dst_name << "' not found" << std::endl;
            return false;
        }
    }
    return true;
}

// Topological sort: start from nodes with no incoming edges, walk forward.
std::vector<std::string> Dataflow::build_execution_flow() {
    std::vector<std::string> flow;
    std::unordered_map<std::string, int> incoming_count;

    for (const auto& task : tasks) incoming_count[task->get_name()] = 0;
    for (const auto& buffer : buffers) incoming_count[buffer->get_name()] = 0;
    for (const auto& conn : connections) incoming_count[conn.dst_name]++;

    std::queue<std::string> ready;
    for (const auto& pair : incoming_count) {
        if (pair.second == 0) ready.push(pair.first);
    }

    while (!ready.empty()) {
        std::string current = ready.front();
        ready.pop();
        flow.push_back(current);
        for (const auto& conn : connections) {
            if (conn.src_name == current) {
                incoming_count[conn.dst_name]--;
                if (incoming_count[conn.dst_name] == 0) ready.push(conn.dst_name);
            }
        }
    }
    return flow;
}

bool Dataflow::check() {
    if (is_checked && is_built) return true;
    if (!validate_connections()) return false;
    flow = build_execution_flow();
    build_internal_dfg();
    is_checked = true;
    return is_built;
}

void Dataflow::build_internal_dfg() {
    try {
        dfg = dfg::create_dfg(dataflow_name);
        if (!dfg) throw std::runtime_error("Failed to create DFG for dataflow " + dataflow_name);

        dfg_root_capability = dfg->get_root_capability();
        if (!dfg_root_capability) throw std::runtime_error("Failed to get root capability for dataflow " + dataflow_name);

        if (debug_level > 1) {
            std::cout << "Dataflow initialization - Initial capability tree:" << std::endl;
            dfg::print_capability_tree(dfg);
        }

        create_internal_nodes();
        create_internal_buffers();
        setup_connections();
        configure_io_switches();
        setup_operations();

        is_built = true;

        if (debug_level > 1) {
            std::cout << "Dataflow initialization - Final capability tree:" << std::endl;
            dfg::print_capability_tree(dfg);
        }
    } catch (const std::exception& e) {
        std::cerr << "Exception during dataflow build: " << e.what() << std::endl;
        is_built = false;
    }
}

void Dataflow::create_internal_nodes() {
    nodes.reserve(tasks.size());
    for (size_t i = 0; i < tasks.size(); i++) {
        auto& task = tasks[i];
        if (debug_level > 0) {
            std::cout << "Creating node: " << task->get_name() << " (index " << i << ")" << std::endl;
        }

        dfg::Node* node = dfg::create_node(dfg, i, task->get_name());
        if (!node) {
            std::cerr << "Error: Failed to create node " << task->get_name() << std::endl;
            continue;
        }

        nodes.push_back(node);
        node_map[task->get_name()] = node;
        task->set_internal_node(node);
        task->set_vfid(i);

        std::string node_cap_id = task->get_name() + "_cap";
        dfg::Capability* node_cap = dfg->find_capability(node_cap_id, dfg_root_capability);
        if (node_cap) {
            node_capabilities[task->get_name()] = node_cap;
            task->set_capability(node_cap);
            if (debug_level > 1) {
                std::cout << "Successfully found capability for node " << task->get_name() << std::endl;
            }
        } else {
            std::cerr << "Warning: Could not find capability for node " << task->get_name() << std::endl;
        }
    }
}

void Dataflow::create_internal_buffers() {
    for (auto& buffer : buffers) {
        if (debug_level > 0) {
            std::cout << "Creating buffer: " << buffer->get_name() << " (size " << buffer->get_size() << ")" << std::endl;
        }

        dfg::Buffer* raw_buffer = dfg::create_buffer(dfg, buffer->get_size(), buffer->get_name());
        if (!raw_buffer) {
            std::cerr << "Error: Failed to create buffer " << buffer->get_name() << std::endl;
            continue;
        }

        raw_buffers[buffer->get_name()] = raw_buffer;
        buffer->set_internal_buffer(raw_buffer);

        std::string buffer_cap_id = buffer->get_name() + "_cap";
        dfg::Capability* buffer_cap = dfg->find_capability(buffer_cap_id, dfg_root_capability);
        if (buffer_cap) {
            buffer_capabilities[buffer->get_name()] = buffer_cap;
            buffer->set_capability(buffer_cap);
            if (debug_level > 1) {
                std::cout << "Successfully found capability for buffer " << buffer->get_name() << std::endl;
            }
        } else {
            std::cerr << "Warning: Could not find capability for buffer " << buffer->get_name() << std::endl;
        }
    }
}

void Dataflow::setup_connections() {
    for (const auto& conn : connections) {
        if (debug_level > 0) {
            std::cout << "Connecting: " << conn.src_name << " -> " << conn.dst_name << std::endl;
        }

        if (!dfg::connect_edges(conn.src_name, conn.dst_name, dfg, 0, 6, true)) {
            std::cerr << "Error: Failed to connect " << conn.src_name << " -> " << conn.dst_name << std::endl;
            continue;
        }
        if (debug_level > 0) {
            std::cout << "Successfully connected: " << conn.src_name << " -> " << conn.dst_name << std::endl;
        }

        std::string conn_source_cap_id = conn.src_name + "_to_" + conn.dst_name + "_src";
        std::string conn_target_cap_id = conn.src_name + "_to_" + conn.dst_name + "_dest";
        if (auto* c = dfg->find_capability(conn_source_cap_id, dfg_root_capability)) {
            connection_capabilities[conn_source_cap_id] = c;
        }
        if (auto* c = dfg->find_capability(conn_target_cap_id, dfg_root_capability)) {
            connection_capabilities[conn_target_cap_id] = c;
        }
    }
}

void Dataflow::configure_io_switches() {
    if (nodes.size() >= 2) {
        if (debug_level > 0) std::cout << "Configuring IO switches for nodes..." << std::endl;
        dfg::configure_node_io_switch(nodes[0], dfg::IODevs::Inter_2_TO_CEU_1);
        dfg::configure_node_io_switch(nodes[nodes.size() - 1], dfg::IODevs::Inter_2_TO_HOST_1);
        for (size_t i = 1; i < nodes.size() - 1; i++) {
            dfg::configure_node_io_switch(nodes[i], dfg::IODevs::Inter_3_TO_CEU_2);
        }
    } else if (nodes.size() == 1) {
        dfg::configure_node_io_switch(nodes[0], dfg::IODevs::Inter_3_TO_HOST_0);
    }
}

void Dataflow::setup_operations() {
    for (auto* node : nodes) {
        if (node) dfg::set_node_operation(node, dfg::CoyoteOper::LOCAL_TRANSFER);
    }
}

void Dataflow::clear_completed() {
    if (!is_built) return;
    for (auto* node : nodes) {
        if (!node) continue;
        dfg::Capability* node_cap = node_capabilities[node->get_id()];
        if (!node_cap) continue;
        try {
            node->clear_completed(node_cap);
        } catch (const std::exception& e) {
            std::cerr << "Exception clearing completion counter for node " << node->get_id()
                      << ": " << e.what() << std::endl;
        }
    }
}

void Dataflow::execute(size_t current_size) {
    if (!is_checked || !is_built) {
        if (!check()) throw std::runtime_error("Dataflow validation failed");
    }

    // Stage host buffers down to device memory.
    for (auto& buffer : buffers) {
        if (buffer->get_internal_buffer()) {
            dfg::write_buffer(buffer->get_internal_buffer(),
                              buffer->get_host_ptr(),
                              current_size > 0 ? current_size : buffer->get_size());
        }
    }

    clear_completed();

    std::vector<dfg::sgEntry> sg(nodes.size());
    for (size_t i = 0; i < nodes.size(); i++) {
        memset(&sg[i], 0, sizeof(dfg::sgEntry));
        if (current_size > 0) {
            sg[i].local.src_len = current_size;
            sg[i].local.dst_len = current_size;
        }
        sg[i].local.src_stream = 1; // HOST_STREAM
        sg[i].local.dst_stream = 1;
    }

    for (size_t i = 0; i < nodes.size(); i++) {
        std::string node_name = nodes[i]->get_id();
        auto node_pos = std::find(flow.begin(), flow.end(), node_name);
        if (node_pos == flow.end()) continue;

        std::string input_buffer_name, output_buffer_name;
        if (node_pos != flow.begin()) {
            auto prev = node_pos - 1;
            if (buffer_map.find(*prev) != buffer_map.end()) input_buffer_name = *prev;
        }
        if (node_pos + 1 != flow.end()) {
            auto next = node_pos + 1;
            if (buffer_map.find(*next) != buffer_map.end()) output_buffer_name = *next;
        }

        if (!input_buffer_name.empty()) {
            auto buffer_it = raw_buffers.find(input_buffer_name);
            if (buffer_it != raw_buffers.end()) {
                void* buffer_memory = dfg::read_buffer(buffer_it->second);
                if (buffer_memory) {
                    sg[i].local.src_addr = buffer_memory;
                    sg[i].local.src_len = current_size > 0 ? current_size : buffer_map[input_buffer_name]->get_size();
                }
            }
        }
        if (!output_buffer_name.empty()) {
            auto buffer_it = raw_buffers.find(output_buffer_name);
            if (buffer_it != raw_buffers.end()) {
                void* buffer_memory = dfg::read_buffer(buffer_it->second);
                if (buffer_memory) {
                    sg[i].local.dst_addr = buffer_memory;
                    sg[i].local.dst_len = current_size > 0 ? current_size : buffer_map[output_buffer_name]->get_size();
                }
            }
        }

        // Offset 6 reserves the leading word for chained inter-vFPGA transfer.
        if (i == 0) {
            sg[i].local.offset_r = 0;
            sg[i].local.offset_w = 6;
        } else if (i == nodes.size() - 1) {
            sg[i].local.offset_r = 6;
            sg[i].local.offset_w = 0;
        } else {
            sg[i].local.offset_r = 6;
            sg[i].local.offset_w = 6;
        }
    }

    dfg::Node* node_array[nodes.size()];
    for (size_t i = 0; i < nodes.size(); i++) node_array[i] = nodes[i];
    dfg::execute_graph(dfg, node_array, nodes.size(), sg.data());

    if (!nodes.empty()) {
        int timeout_counter = 0;
        const int max_timeout = 10000000;
        dfg::Capability* last_node_cap = node_capabilities[nodes.back()->get_id()];
        if (last_node_cap) {
            while (nodes.back()->check_completed(last_node_cap, dfg::CoyoteOper::LOCAL_TRANSFER) != 1) {
                timeout_counter++;
                if (dfg->is_stalled(dfg_root_capability) || timeout_counter > max_timeout) {
                    std::cerr << (timeout_counter > max_timeout
                                  ? "Warning: Execution timed out"
                                  : "Warning: Execution stalled") << std::endl;
                    break;
                }
            }
        }
    }

    // Copy device output back to host buffers.
    for (auto& buffer : buffers) {
        if (buffer->get_internal_buffer()) {
            void* device_memory = dfg::read_buffer(buffer->get_internal_buffer());
            if (device_memory) {
                size_t transfer_size = current_size > 0 ? current_size : buffer->get_size();
                memcpy(buffer->get_host_ptr(), device_memory, transfer_size);
            }
        }
    }
}

void Dataflow::release() {
    // Guard against re-entry from both ~Dataflow and an explicit release() call.
    static std::atomic<bool> already_releasing(false);
    bool expected = false;
    if (!already_releasing.compare_exchange_strong(expected, true)) return;

    try {
        if (debug_level > 0) std::cout << "Releasing dataflow resources..." << std::endl;

        is_built = false;
        is_checked = false;

        node_capabilities.clear();
        buffer_capabilities.clear();
        connection_capabilities.clear();

        nodes.clear();
        node_map.clear();
        raw_buffers.clear();

        if (dfg) {
            try {
                dfg::release_resources(dfg);
            } catch (const std::exception& e) {
                std::cerr << "Exception during DFG resource release: " << e.what() << std::endl;
            }
            dfg = nullptr;
        }
        dfg_root_capability = nullptr;

        task_map.clear();
        buffer_map.clear();
        tasks.clear();
        buffers.clear();
        connections.clear();
        flow.clear();
    } catch (const std::exception& e) {
        std::cerr << "Critical error during dataflow release: " << e.what() << std::endl;
    }

    already_releasing.store(false);
}

Task* Dataflow::get_task(const std::string& name) {
    auto it = task_map.find(name);
    return it != task_map.end() ? it->second : nullptr;
}

Buffer* Dataflow::get_buffer(const std::string& name) {
    auto it = buffer_map.find(name);
    return it != buffer_map.end() ? it->second : nullptr;
}

dfg::Capability* Dataflow::create_capability(const std::string& component_name,
                                             const std::string& cap_space_id,
                                             uint32_t access,
                                             bool allow_transitive_delegation) {
    if (!dfg) return nullptr;
    return dfg::create_capability(dfg, dataflow_name, component_name, cap_space_id, access, allow_transitive_delegation);
}

dfg::Capability* Dataflow::delegate_capability(const std::string& src_component,
                                               const std::string& cap_space_id,
                                               uint32_t access,
                                               bool allow_transitive_delegation) {
    if (!dfg) return nullptr;
    return dfg::delegate_capability(dfg, dataflow_name, src_component, cap_space_id, access, allow_transitive_delegation);
}

bool Dataflow::can_component_delegate_delegation(const std::string& component_name) const {
    auto node_cap_it = node_capabilities.find(component_name);
    if (node_cap_it != node_capabilities.end() && node_cap_it->second) {
        return node_cap_it->second->can_delegate_delegation();
    }
    auto buffer_cap_it = buffer_capabilities.find(component_name);
    if (buffer_cap_it != buffer_capabilities.end() && buffer_cap_it->second) {
        return buffer_cap_it->second->can_delegate_delegation();
    }
    return false;
}

bool Dataflow::transfer_ownership(const std::string& src_component, const std::string& dst_component) {
    if (!dfg) return false;
    return dfg::transfer_ownership(dfg, dataflow_name, src_component, dst_component);
}

bool Dataflow::revoke_capability(const std::string& component_name, const std::string& cap_space_id) {
    if (!dfg) return false;
    return dfg::revoke_capability(dfg, dataflow_name, component_name, cap_space_id);
}

bool Dataflow::expire_capability(const std::string& component_name, const std::string& cap_space_id, uint32_t timeout) {
    if (!dfg) return false;
    return dfg::expire_capability(dfg, dataflow_name, component_name, cap_space_id, timeout);
}

bool Dataflow::reset_capabilities(const std::string& component_name) {
    if (!dfg) return false;
    return dfg::reset_capabilities(dfg, dataflow_name, component_name);
}

void Dataflow::print_capability_tree() const {
    if (dfg) {
        std::cout << "Capability Tree for Dataflow '" << dataflow_name << "':" << std::endl;
        dfg::print_capability_tree(dfg);
    }
}

void Dataflow::print_graph() const {
    std::cout << "Dataflow Graph '" << dataflow_name << "':" << std::endl;
    std::cout << "Tasks: ";
    for (const auto& task : tasks) std::cout << task->get_name() << " ";
    std::cout << std::endl;

    std::cout << "Buffers: ";
    for (const auto& buffer : buffers) std::cout << buffer->get_name() << " ";
    std::cout << std::endl;

    std::cout << "Connections:" << std::endl;
    for (const auto& conn : connections) {
        std::cout << "  " << conn.src_name << " -> " << conn.dst_name << std::endl;
    }
}

void Dataflow::print_connections() const {
    std::cout << "Connections for dataflow '" << dataflow_name << "':" << std::endl;
    for (const auto& conn : connections) {
        std::cout << "  " << conn.src_name << "(" << conn.src_type << ":" << conn.src_port
                  << ") -> " << conn.dst_name << "(" << conn.dst_type << ":" << conn.dst_port << ")" << std::endl;
    }
}

// ================================================================
// Free-function helpers
// ================================================================

void write_dataflow_buffer(Buffer& buffer, void* data, size_t size) {
    buffer.write_from_host(data, size);
}

void read_dataflow_buffer(Buffer& buffer, void* dest, size_t size) {
    buffer.read_to_host(dest, size);
}

Buffer* get_dataflow_buffer(Dataflow* dataflow, const std::string& buffer_name) {
    return dataflow ? dataflow->get_buffer(buffer_name) : nullptr;
}

Task task(const std::string& name, const std::string& type = "processing") {
    return Task(name, type, nullptr);
}

Buffer buffer(void* host_ptr, size_t size = 0) {
    return Buffer(host_ptr, size);
}

template<typename T, size_t N>
Buffer buffer(T (&array)[N]) {
    return Buffer(array, sizeof(array));
}

Buffer buffer(size_t size) {
    return Buffer(size);
}

Dataflow dataflow(const std::string& name = "") {
    return Dataflow(name);
}

} // namespace ushell
