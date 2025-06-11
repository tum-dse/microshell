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
    metaIntf.m m_wr_req,
    
    // Access violation signal - auto-clears when violation condition ends
    output logic access_violation_irq
);

    // Signal declarations
    endpoint_reg_t [N_ENDPOINTS-1:0] endpoint_regs;

    // Secure range checking signals - use wider arithmetic to prevent overflow
    logic [VADDR_BITS:0] rd_req_end_addr_wide, wr_req_end_addr_wide;
    logic rd_range_valid, wr_range_valid;
    logic rd_overflow_detected, wr_overflow_detected;

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
    // FIXED: Comprehensive Security Validation with Proper Overflow Detection
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Default to deny access 
        rd_access_allowed = 1'b0;
        wr_access_allowed = 1'b0;
        
        // FIXED: Use wider arithmetic (VADDR_BITS+1) to properly detect overflow
        rd_req_end_addr_wide = {1'b0, s_rd_req.data.vaddr} + {1'b0, s_rd_req.data.len} - 1;
        wr_req_end_addr_wide = {1'b0, s_wr_req.data.vaddr} + {1'b0, s_wr_req.data.len} - 1;
        
        // Detect overflow: if result doesn't fit in VADDR_BITS, it overflowed
        rd_overflow_detected = rd_req_end_addr_wide[VADDR_BITS];
        wr_overflow_detected = wr_req_end_addr_wide[VADDR_BITS];
        
        // Only check if there's a valid request 
        if (s_rd_req.valid) begin
            // Check against all endpoints 
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && endpoint_regs[i].access_rights[0]) begin
                    // FIXED: Comprehensive security validation
                    rd_range_valid = 1'b0; // Start with denial
                    
                    // Security Check 1: Reject zero-length requests
                    if (s_rd_req.data.len == 0) begin
                        rd_range_valid = 1'b0;
                    end
                    // Security Check 2: Detect integer overflow
                    else if (rd_overflow_detected) begin
                        rd_range_valid = 1'b0;
                    end
                    // Security Check 3: Start address must be within endpoint bounds
                    else if (s_rd_req.data.vaddr < endpoint_regs[i].vaddr_base || 
                             s_rd_req.data.vaddr > endpoint_regs[i].vaddr_bound) begin
                        rd_range_valid = 1'b0;
                    end
                    // Security Check 4: End address must be within endpoint bounds (no overflow case)
                    else if (rd_req_end_addr_wide[VADDR_BITS-1:0] > endpoint_regs[i].vaddr_bound) begin
                        rd_range_valid = 1'b0;
                    end
                    // All security checks passed - safe to allow
                    else begin
                        rd_range_valid = 1'b1;
                    end
                    
                    if (rd_range_valid) begin
                        rd_access_allowed = 1'b1;
                        break; // Found valid endpoint, allow access
                    end
                end
            end
        end
        
        // FIXED: Similar comprehensive security check for write requests
        if (s_wr_req.valid) begin
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && endpoint_regs[i].access_rights[1]) begin
                    // FIXED: Comprehensive security validation
                    wr_range_valid = 1'b0; // Start with denial
                    
                    // Security Check 1: Reject zero-length requests
                    if (s_wr_req.data.len == 0) begin
                        wr_range_valid = 1'b0;
                    end
                    // Security Check 2: Detect integer overflow
                    else if (wr_overflow_detected) begin
                        wr_range_valid = 1'b0;
                    end
                    // Security Check 3: Start address must be within endpoint bounds
                    else if (s_wr_req.data.vaddr < endpoint_regs[i].vaddr_base || 
                             s_wr_req.data.vaddr > endpoint_regs[i].vaddr_bound) begin
                        wr_range_valid = 1'b0;
                    end
                    // Security Check 4: End address must be within endpoint bounds (no overflow case)
                    else if (wr_req_end_addr_wide[VADDR_BITS-1:0] > endpoint_regs[i].vaddr_bound) begin
                        wr_range_valid = 1'b0;
                    end
                    // All security checks passed - safe to allow
                    else begin
                        wr_range_valid = 1'b1;
                    end
                    
                    if (wr_range_valid) begin
                        wr_access_allowed = 1'b1;
                        break; // Found valid endpoint, allow access
                    end
                end
            end
        end
    end

    // ----------------------------------------------------------------------------------------
    // Immediate Drop for Unauthorized Requests
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // AUTHORIZED REQUESTS: Forward to downstream
        m_rd_req.valid = s_rd_req.valid && rd_access_allowed;
        m_rd_req.data = s_rd_req.data;
        
        m_wr_req.valid = s_wr_req.valid && wr_access_allowed;
        m_wr_req.data = s_wr_req.data;
        
        // - AUTHORIZED: Wait for downstream ready
        // - UNAUTHORIZED: Immediately drop (assert ready to consume/reject request)
        s_rd_req.ready = rd_access_allowed ? m_rd_req.ready : 1'b1;
        s_wr_req.ready = wr_access_allowed ? m_wr_req.ready : 1'b1;
    end

    // ----------------------------------------------------------------------------------------
    // Access Violation Signal - Auto-clearing
    // ----------------------------------------------------------------------------------------
    
    // Detect violation occurrence (combinational)
    always_comb begin
        violation_detected = 
            (s_rd_req.valid && !rd_access_allowed) ||
            (s_wr_req.valid && !wr_access_allowed);
    end
    
    // Direct assignment - violation signal reflects current access state
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            access_violation_irq <= 1'b0;
        end
        else begin
            // Simple: IRQ follows violation state directly
            access_violation_irq <= violation_detected;
        end
    end

endmodule