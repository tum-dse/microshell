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

    // ----------------------------------------------------------------------------------------
    // Endpoint Configuration Constants
    // ----------------------------------------------------------------------------------------
    
    // Bit field definitions for each endpoint configuration
    localparam integer EP_BASE_ADDR_BITS = 64;
    localparam integer EP_BOUND_ADDR_BITS = 64;
    localparam integer EP_ACCESS_BITS = 2;
    localparam integer EP_VALID_BITS = 1;
    localparam integer EP_TOTAL_BITS = EP_BASE_ADDR_BITS + EP_BOUND_ADDR_BITS + EP_ACCESS_BITS + EP_VALID_BITS; // 131
    
    // Bit field offsets within each endpoint configuration
    localparam integer EP_BASE_ADDR_OFFSET = 0;
    localparam integer EP_BOUND_ADDR_OFFSET = EP_BASE_ADDR_OFFSET + EP_BASE_ADDR_BITS;
    localparam integer EP_ACCESS_OFFSET = EP_BOUND_ADDR_OFFSET + EP_BOUND_ADDR_BITS;
    localparam integer EP_VALID_OFFSET = EP_ACCESS_OFFSET + EP_ACCESS_BITS;

    // ----------------------------------------------------------------------------------------
    // Security Validation - Overflow-Safe Bounds Checking 
    // ----------------------------------------------------------------------------------------
    
    logic rd_access_allowed, wr_access_allowed;
    logic violation_detected;
    
    logic [15:0] epr_start_bit;
    logic [63:0] epr_base;
    logic [63:0] epr_bound;
    logic [1:0] epr_access;
    logic epr_valid;

    logic [15:0] epw_start_bit;
    logic [63:0] epw_base;
    logic [63:0] epw_bound;
    logic [1:0] epw_access;
    logic epw_valid;
                
    always_comb begin
        // Default to deny access 
        rd_access_allowed = 1'b0;
        wr_access_allowed = 1'b0;
        
        // Read request validation
        if (s_rd_req.valid && s_rd_req.data.len > 0) begin
            // Check against all endpoints 
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                // Extract endpoint config directly from ep_ctrl 
                epr_start_bit = i * EP_TOTAL_BITS;
                epr_base = ep_ctrl[epr_start_bit + EP_BASE_ADDR_OFFSET +: EP_BASE_ADDR_BITS];
                epr_bound = ep_ctrl[epr_start_bit + EP_BOUND_ADDR_OFFSET +: EP_BOUND_ADDR_BITS];
                epr_access = ep_ctrl[epr_start_bit + EP_ACCESS_OFFSET +: EP_ACCESS_BITS];
                epr_valid = ep_ctrl[epr_start_bit + EP_VALID_OFFSET +: EP_VALID_BITS];
                
                // Check if endpoint is valid and has read access
                if (epr_valid && epr_access[0] && (epr_base <= epr_bound)) begin
                    // Extract request parameters
                    logic [VADDR_BITS-1:0] req_vaddr = s_rd_req.data.vaddr;
                    logic [LEN_BITS-1:0] req_len = s_rd_req.data.len;
                    
                    // Calculate endpoint size to prevent malicious huge lengths
                    logic [63:0] ep_size = epr_bound - epr_base + 1;
                    
                    // SECURITY: Prevent overflow attacks by checking length vs endpoint size
                    if (req_len <= ep_size) begin
                        // Overflow-safe bounds check using subtraction instead of addition
                        if ((req_vaddr >= epr_base) && 
                            (req_vaddr <= (epr_bound - req_len + 1))) begin
                            rd_access_allowed = 1'b1;
                            break;
                        end
                    end
                    // If req_len > ep_size, implicitly deny (skip this endpoint)
                end
            end
        end
        
        // Write request validation - Same logic as read
        if (s_wr_req.valid && s_wr_req.data.len > 0) begin
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                // Extract endpoint config directly from ep_ctrl 
                epw_start_bit = i * EP_TOTAL_BITS;
                epw_base = ep_ctrl[epw_start_bit + EP_BASE_ADDR_OFFSET +: EP_BASE_ADDR_BITS];
                epw_bound = ep_ctrl[epw_start_bit + EP_BOUND_ADDR_OFFSET +: EP_BOUND_ADDR_BITS];
                epw_access = ep_ctrl[epw_start_bit + EP_ACCESS_OFFSET +: EP_ACCESS_BITS];
                epw_valid = ep_ctrl[epw_start_bit + EP_VALID_OFFSET +: EP_VALID_BITS];
                
                // Check if endpoint is valid and has write access
                if (epw_valid && epw_access[1] && (epw_base <= epw_bound)) begin
                    // Extract request parameters
                    logic [VADDR_BITS-1:0] req_vaddr = s_wr_req.data.vaddr;
                    logic [LEN_BITS-1:0] req_len = s_wr_req.data.len;
                    
                    // Calculate endpoint size to prevent malicious huge lengths
                    logic [63:0] ep_size = epw_bound - epw_base + 1;
                    
                    // SECURITY: Prevent overflow attacks by checking length vs endpoint size
                    if (req_len <= ep_size) begin
                        // Overflow-safe bounds check using subtraction instead of addition
                        if ((req_vaddr >= epw_base) && 
                            (req_vaddr <= (epw_bound - req_len + 1))) begin
                            wr_access_allowed = 1'b1;
                            break;
                        end
                    end
                    // If req_len > ep_size, implicitly deny (skip this endpoint)
                end
            end
        end
    end

    // ----------------------------------------------------------------------------------------
    // Request Forwarding Logic
    // ----------------------------------------------------------------------------------------
    
    always_comb begin
        m_rd_req.valid = s_rd_req.valid && rd_access_allowed;
        m_rd_req.data = s_rd_req.data;
        
        m_wr_req.valid = s_wr_req.valid && wr_access_allowed;
        m_wr_req.data = s_wr_req.data;
        
        s_rd_req.ready = rd_access_allowed ? m_rd_req.ready : 1'b1;
        s_wr_req.ready = wr_access_allowed ? m_wr_req.ready : 1'b1;
    end

    // ----------------------------------------------------------------------------------------
    // Access Violation Tracking
    // ----------------------------------------------------------------------------------------
    
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