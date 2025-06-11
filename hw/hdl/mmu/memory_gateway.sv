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
    
    // IMPROVED: Latched access violation signal
    output logic access_violation_irq,
    
    // Software clear interface
    input logic access_violation_clear
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
    // Access Control Check
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Default to deny access (most restrictive state) 
        rd_access_allowed = 1'b0;
        wr_access_allowed = 1'b0;
        
        // Only check if there's a valid request 
        if (s_rd_req.valid) begin
            // Check against all endpoints 
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                if (endpoint_regs[i].valid && 
                    endpoint_regs[i].access_rights[0] && // Read permission
                    (s_rd_req.data.vaddr >= endpoint_regs[i].vaddr_base) &&
                    (s_rd_req.data.vaddr <= endpoint_regs[i].vaddr_bound)) begin
                    rd_access_allowed = 1'b1; // Allow access if match found
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
                    wr_access_allowed = 1'b1; // Allow access if match found
                    break;
                end
            end
        end
    end

    // ----------------------------------------------------------------------------------------
    // Request Filtering - Only pass authorized requests
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        // Read request filtering - only pass authorized requests
        m_rd_req.valid = s_rd_req.valid && rd_access_allowed;
        m_rd_req.data = s_rd_req.data;
        
        // Write request filtering - only pass authorized requests
        m_wr_req.valid = s_wr_req.valid && wr_access_allowed;
        m_wr_req.data = s_wr_req.data;
        
        // Ready signal propagation
        s_rd_req.ready = rd_access_allowed ? m_rd_req.ready : 1'b1;
        s_wr_req.ready = wr_access_allowed ? m_wr_req.ready : 1'b1;
    end

    // ----------------------------------------------------------------------------------------
    // IMPROVED: Latched Access Violation Signal
    // ----------------------------------------------------------------------------------------
    
    // Detect violation occurrence (combinational)
    always_comb begin
        violation_detected = 
            (s_rd_req.valid && !rd_access_allowed) ||
            (s_wr_req.valid && !wr_access_allowed);
    end
    
    // Latch violation until software clears it (sequential)
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            access_violation_irq <= 1'b0;
        end
        else begin
            if (violation_detected) begin
                // Set flag when violation occurs
                access_violation_irq <= 1'b1;
            end
            else if (access_violation_clear) begin
                // Clear flag when software clears it
                access_violation_irq <= 1'b0;
            end
            // Otherwise maintain current state
        end
    end

endmodule