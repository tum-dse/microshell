`timescale 1ns / 1ps
import lynxTypes::*;
`include "lynx_macros.svh"

module memory_endpoints #(
    parameter integer N_ENDPOINTS = 1
) (
    input logic aclk,
    input logic aresetn,
    
    // Wide control signal input - packed configuration for all endpoints
    // Format per endpoint: [valid][access_rights][bound_addr][base_addr]
    // Per endpoint: 1 + 2 + 64 + 64 = 131 bits
    // For N_ENDPOINTS: 131 * N_ENDPOINTS bits
    input logic [(131*N_ENDPOINTS)-1:0] ep_ctrl,
    
    // Endpoint registers output
    output endpoint_reg_t [N_ENDPOINTS-1:0] endpoint_regs
);

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
    
    // Extract configuration for each endpoint and update registers
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            // Initialize all endpoints as invalid
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                endpoint_regs[i].valid <= 1'b0;
                endpoint_regs[i].vaddr_base <= '0;
                endpoint_regs[i].vaddr_bound <= '0;
                endpoint_regs[i].access_rights <= 2'b00;
            end
        end
        else begin
            // Update endpoint configurations from packed control signal
            for (int i = 0; i < N_ENDPOINTS; i++) begin
                // Calculate bit range for this endpoint
                logic [15:0] ep_start_bit = i * EP_TOTAL_BITS;
                
                // Extract fields for endpoint i into temporary variables
                logic [63:0] new_base;
                logic [63:0] new_bound;
                logic [1:0] new_access;
                logic new_valid;
                
                new_base = ep_ctrl[ep_start_bit + EP_BASE_ADDR_OFFSET +: EP_BASE_ADDR_BITS];
                new_bound = ep_ctrl[ep_start_bit + EP_BOUND_ADDR_OFFSET +: EP_BOUND_ADDR_BITS];
                new_access = ep_ctrl[ep_start_bit + EP_ACCESS_OFFSET +: EP_ACCESS_BITS];
                new_valid = ep_ctrl[ep_start_bit + EP_VALID_OFFSET +: EP_VALID_BITS];
                
                // VALIDATION: Check that base <= bound for valid endpoints
                if (new_valid && (new_base <= new_bound)) begin
                    // Valid configuration - accept all fields
                    endpoint_regs[i].vaddr_base <= new_base;
                    endpoint_regs[i].vaddr_bound <= new_bound;
                    endpoint_regs[i].access_rights <= new_access;
                    endpoint_regs[i].valid <= 1'b1;
                end else if (new_valid && (new_base > new_bound)) begin
                    // Invalid range (base > bound) - disable endpoint but keep other fields for debugging
                    endpoint_regs[i].vaddr_base <= new_base;
                    endpoint_regs[i].vaddr_bound <= new_bound;
                    endpoint_regs[i].access_rights <= new_access;
                    endpoint_regs[i].valid <= 1'b0;  // Auto-disable invalid config
                end else begin
                    // Explicitly disabled (new_valid = 0) - update all fields
                    endpoint_regs[i].vaddr_base <= new_base;
                    endpoint_regs[i].vaddr_bound <= new_bound;
                    endpoint_regs[i].access_rights <= new_access;
                    endpoint_regs[i].valid <= 1'b0;
                end
            end
        end
    end

endmodule