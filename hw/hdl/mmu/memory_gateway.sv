`timescale 1ns / 1ps
import lynxTypes::*;
`include "lynx_macros.svh"

module memory_gateway #(
    parameter integer N_ENDPOINTS = 1
) (
    input logic aclk,
    input logic aresetn,
    
    // Control interface
    input logic [(131*N_ENDPOINTS)-1:0] ep_ctrl,
    
    // Original DMA interfaces (unfiltered inputs)
    metaIntf.s s_rd_req,  
    metaIntf.s s_wr_req,  
    
    // Filtered DMA interfaces (only authorized requests)
    metaIntf.m m_rd_req,
    metaIntf.m m_wr_req
);

    // Signal declarations
    endpoint_reg_t [N_ENDPOINTS-1:0] endpoint_regs;

    // Instantiate memory endpoints configuration module
    memory_endpoints #(
        .N_ENDPOINTS(N_ENDPOINTS)
    ) inst_endpoints (
        .aclk(aclk),
        .aresetn(aresetn),
        .ep_ctrl(ep_ctrl),
        .endpoint_regs(endpoint_regs)
    );

    // Signal declarations
    logic rd_access_allowed, wr_access_allowed;
    logic violation_detected;

    // ----------------------------------------------------------------------------------------
    // Security Validation - Bounds Checking
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Default to deny access 
        rd_access_allowed = 1'b0;
        wr_access_allowed = 1'b0;
        
        // Read request validation
        if (s_rd_req.valid && s_rd_req.data.len > 0) begin
            // Check against all endpoints 
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && endpoint_regs[i].access_rights[0]) begin
                    
                    // Use proper variable declarations and safer arithmetic
                    logic [VADDR_BITS-1:0] req_vaddr;
                    logic [LEN_BITS-1:0] req_len;
                    logic [VADDR_BITS-1:0] req_end_addr;
                    logic [VADDR_BITS-1:0] ep_base, ep_bound;
                    
                    // Extract request parameters
                    req_vaddr = s_rd_req.data.vaddr;
                    req_len = s_rd_req.data.len;
                    ep_base = endpoint_regs[i].vaddr_base;
                    ep_bound = endpoint_regs[i].vaddr_bound;
                    
                    // Calculate end address with overflow protection
                    req_end_addr = req_vaddr + req_len - 1;
                    
                    // Bounds check: 
                    // 1. Start address must be >= endpoint base
                    // 2. End address must be <= endpoint bound  
                    // 3. No arithmetic overflow (end >= start)
                    if ((req_vaddr >= ep_base) && 
                        (req_end_addr <= ep_bound) && 
                        (req_end_addr >= req_vaddr)) begin
                        rd_access_allowed = 1'b1;
                        break; // Found valid endpoint, allow access
                    end
                end
            end
        end
        
        // Write request validation - Same logic as read
        if (s_wr_req.valid && s_wr_req.data.len > 0) begin
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && endpoint_regs[i].access_rights[1]) begin
                    
                    // Use proper variable declarations and safer arithmetic
                    logic [VADDR_BITS-1:0] req_vaddr;
                    logic [LEN_BITS-1:0] req_len;
                    logic [VADDR_BITS-1:0] req_end_addr;
                    logic [VADDR_BITS-1:0] ep_base, ep_bound;
                    
                    // Extract request parameters
                    req_vaddr = s_wr_req.data.vaddr;
                    req_len = s_wr_req.data.len;
                    ep_base = endpoint_regs[i].vaddr_base;
                    ep_bound = endpoint_regs[i].vaddr_bound;
                    
                    // Calculate end address with overflow protection
                    req_end_addr = req_vaddr + req_len - 1;
                    
                    // Bounds check: 
                    // 1. Start address must be >= endpoint base
                    // 2. End address must be <= endpoint bound  
                    // 3. No arithmetic overflow (end >= start)
                    if ((req_vaddr >= ep_base) && 
                        (req_end_addr <= ep_bound) && 
                        (req_end_addr >= req_vaddr)) begin
                        wr_access_allowed = 1'b1;
                        break; // Found valid endpoint, allow access
                    end
                end
            end
        end
    end

    // ----------------------------------------------------------------------------------------
    // Request Forwarding Logic
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // AUTHORIZED REQUESTS: Forward to downstream
        m_rd_req.valid = s_rd_req.valid && rd_access_allowed;
        m_rd_req.data = s_rd_req.data;
        
        m_wr_req.valid = s_wr_req.valid && wr_access_allowed;
        m_wr_req.data = s_wr_req.data;
        
        // BACKPRESSURE HANDLING:
        // - AUTHORIZED: Wait for downstream ready
        // - UNAUTHORIZED: Immediately consume/drop (assert ready to consume/reject request)
        s_rd_req.ready = rd_access_allowed ? m_rd_req.ready : 1'b1;
        s_wr_req.ready = wr_access_allowed ? m_wr_req.ready : 1'b1;
    end

    // ----------------------------------------------------------------------------------------
    // Access Violation Tracking 
    // ----------------------------------------------------------------------------------------
    
    // Detect violation occurrence (combinational)
    always_comb begin
        violation_detected = 
            (s_rd_req.valid && !rd_access_allowed) ||
            (s_wr_req.valid && !wr_access_allowed);
    end
    
    logic access_violation_detected;
    logic [31:0] violation_count;

    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            violation_count <= 0;
            access_violation_detected <= 1'b0;
        end
        else begin
            access_violation_detected <= violation_detected;
            if (violation_detected) begin
                violation_count <= violation_count + 1;
            end
        end
    end

endmodule