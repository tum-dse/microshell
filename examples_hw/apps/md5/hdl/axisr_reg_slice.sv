// Custom register slice module to ensure proper connection
module axisr_reg_slice (
    input  logic        aclk,
    input  logic        aresetn,
    
    // Slave interface
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic [511:0] s_axis_tdata,
    input  logic        s_axis_tlast,
    input  logic [63:0] s_axis_tkeep,
    input  logic [15:0] s_axis_tid,
    
    // Master interface
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic [511:0] m_axis_tdata,
    output logic        m_axis_tlast,
    output logic [63:0] m_axis_tkeep,
    output logic [15:0] m_axis_tid
);
    // Register stage
    logic        storage_valid;
    logic [511:0] storage_data;
    logic        storage_last;
    logic [63:0] storage_keep;
    logic [15:0] storage_id;
    
    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            storage_valid <= 1'b0;
            storage_data  <= '0;
            storage_last  <= 1'b0;
            storage_keep  <= '0;
            storage_id    <= '0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            storage_valid <= 1'b1;
            storage_data  <= s_axis_tdata;
            storage_last  <= s_axis_tlast;
            storage_keep  <= s_axis_tkeep;
            storage_id    <= s_axis_tid;
        end else if (m_axis_tready) begin
            storage_valid <= 1'b0;
        end
    end
    
    // Output assignments
    assign m_axis_tvalid = storage_valid;
    assign m_axis_tdata  = storage_data;
    assign m_axis_tlast  = storage_last;
    assign m_axis_tkeep  = storage_keep;
    assign m_axis_tid    = storage_id;
    
    // Ready signal generation
    assign s_axis_tready = !storage_valid || m_axis_tready;
    
endmodule
