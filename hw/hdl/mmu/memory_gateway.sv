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
    
    // Original DMA interfaces (unfiltered inputs from user)
    metaIntf.s s_rd_req,
    metaIntf.s s_wr_req,
    
    // Filtered DMA interfaces (outputs to TLB FSM)
    metaIntf.m m_rd_req,
    metaIntf.m m_wr_req,
    
    // Access violation page fault outputs (only for violations we detect)
    metaIntf.m m_rd_pfault_irq,
    metaIntf.m m_wr_pfault_irq,
    output logic [LEN_BITS-1:0] m_rd_pfault_rng,
    output logic [LEN_BITS-1:0] m_wr_pfault_rng
);

    // Signal declarations
    endpoint_reg_t [N_ENDPOINTS-1:0] endpoint_regs;
    logic rd_access_violation, wr_access_violation;
    
    // Page fault state tracking
    logic rd_pf_pending, wr_pf_pending;

    // Instantiate memory endpoints configuration module
    memory_endpoints #(
        .N_ENDPOINTS(N_ENDPOINTS)
    ) inst_endpoints (
        .aclk(aclk),
        .aresetn(aresetn),
        .ep_ctrl(ep_ctrl),
        .endpoint_regs(endpoint_regs)
    );

    // ----------------------------------------------------------------------------------------
    // Access Violation Detection 
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Default to violations (most restrictive state) 
        rd_access_violation = 1'b1;
        wr_access_violation = 1'b1;
        
        // Only check if there's a valid request 
        if (s_rd_req.valid) begin
            // Check against all endpoints 
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && 
                    endpoint_regs[i].access_rights[0] && // Read permission
                    (s_rd_req.data.vaddr >= endpoint_regs[i].vaddr_base) &&
                    (s_rd_req.data.vaddr <= endpoint_regs[i].vaddr_bound)) begin
                    rd_access_violation = 1'b0; // Clear violation if match found
                    break;
                end
            end
        end
        
        // Similar check for write requests 
        if (s_wr_req.valid) begin
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && 
                    endpoint_regs[i].access_rights[1] && // Write permission
                    (s_wr_req.data.vaddr >= endpoint_regs[i].vaddr_base) &&
                    (s_wr_req.data.vaddr <= endpoint_regs[i].vaddr_bound)) begin
                    wr_access_violation = 1'b0; // Clear violation if match found
                    break;
                end
            end
        end
    end

    // ----------------------------------------------------------------------------------------
    // Request Filtering - FIXED: Use violations directly (combinational)
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Read request filtering - use CURRENT violation status
        m_rd_req.valid = s_rd_req.valid && !rd_access_violation;
        m_rd_req.data = s_rd_req.data;
        s_rd_req.ready = m_rd_req.ready || (s_rd_req.valid && rd_access_violation);
        
        // Write request filtering - use CURRENT violation status
        m_wr_req.valid = s_wr_req.valid && !wr_access_violation;
        m_wr_req.data = s_wr_req.data;
        s_wr_req.ready = m_wr_req.ready || (s_wr_req.valid && wr_access_violation);
    end

    // ----------------------------------------------------------------------------------------
    // Access Violation Page Faults - FIXED: Use violations directly
    // ----------------------------------------------------------------------------------------
    
    // Read path page faults
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            m_rd_pfault_irq.valid <= 1'b0;
            rd_pf_pending <= 1'b0;
        end
        else begin
            if (!rd_pf_pending) begin
                // Generate page fault for access violation - use CURRENT violation status
                if (s_rd_req.valid && rd_access_violation && s_rd_req.ready) begin
                    m_rd_pfault_irq.valid <= 1'b1;
                    m_rd_pfault_irq.data.vaddr <= s_rd_req.data.vaddr;
                    m_rd_pfault_irq.data.pid <= s_rd_req.data.pid;
                    m_rd_pfault_irq.data.strm <= s_rd_req.data.strm;
                    m_rd_pfault_rng <= s_rd_req.data.len;
                    rd_pf_pending <= 1'b1;
                end
            end
            else begin
                // Wait for acknowledgment
                if (m_rd_pfault_irq.ready) begin
                    m_rd_pfault_irq.valid <= 1'b0;
                    rd_pf_pending <= 1'b0;
                end
            end
        end
    end
    
    // Write path page faults
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            m_wr_pfault_irq.valid <= 1'b0;
            wr_pf_pending <= 1'b0;
        end
        else begin
            if (!wr_pf_pending) begin
                // Generate page fault for access violation - use CURRENT violation status
                if (s_wr_req.valid && wr_access_violation && s_wr_req.ready) begin
                    m_wr_pfault_irq.valid <= 1'b1;
                    m_wr_pfault_irq.data.vaddr <= s_wr_req.data.vaddr;
                    m_wr_pfault_irq.data.pid <= s_wr_req.data.pid;
                    m_wr_pfault_irq.data.strm <= s_wr_req.data.strm;
                    m_wr_pfault_rng <= s_wr_req.data.len;
                    wr_pf_pending <= 1'b1;
                end
            end
            else begin
                // Wait for acknowledgment
                if (m_wr_pfault_irq.ready) begin
                    m_wr_pfault_irq.valid <= 1'b0;
                    wr_pf_pending <= 1'b0;
                end
            end
        end
    end

endmodule