module sha2 (
    // Clock and reset
    input  wire         aclk,
    input  wire         aresetn,
    
    // Input AXI4-Stream interface (512-bit width)
    input  wire [511:0] axis_sink_tdata,
    input  wire         axis_sink_tvalid,
    input  wire         axis_sink_tlast,
    output wire         axis_sink_tready,
    
    // Output AXI4-Stream interface
    output wire [255:0] axis_src_tdata,
    output wire [63:0]  axis_src_tkeep,
    output wire [7:0]   axis_src_tid,
    output wire         axis_src_tvalid,
    output wire         axis_src_tlast,
    input  wire         axis_src_tready
);

    // Internal signals for byte-wise SHA-256 module
    wire         sha_tready;
    wire         sha_tvalid;
    wire         sha_tlast;
    wire [31:0]  sha_tid;
    wire [7:0]   sha_tdata;
    wire         sha_ovalid;
    wire [31:0]  sha_oid;
    wire [60:0]  sha_olen;
    wire [255:0] sha_osha;
    
    // Serialization state machine
    localparam IDLE = 2'b00,
               SENDING = 2'b01,
               WAITING = 2'b10;
    
    reg [1:0]   state;
    reg [6:0]   byte_counter;   // Counts bytes within 512-bit block (0-63)
    reg         stored_tlast;   // Stores tlast signal from input
    reg [511:0] data_buffer;    // Buffer to hold the 512-bit data for serialization
    
    // Control signals for serialization
    wire        start_serialization;
    wire        serialization_done;
    
    // Connect SHA256 outputs to AXI4-Stream output interface
    assign axis_src_tdata  = sha_osha;
    assign axis_src_tkeep  = 64'hffffffffffffffff; // All bytes valid
    assign axis_src_tid    = sha_oid[7:0];        // Use lower 8 bits of ID
    assign axis_src_tvalid = sha_ovalid;
    assign axis_src_tlast  = sha_ovalid;          // Last flag same as valid
    
    // Serialization control
    assign start_serialization = (state == IDLE) && axis_sink_tvalid;
    assign serialization_done = (state == SENDING) && (byte_counter == 7'd63) && sha_tready;
    
    // Input flow control
    assign axis_sink_tready = (state == IDLE);
    
    // Select current byte to send to SHA256 module
    assign sha_tdata = data_buffer[511:504]; // Always send the top byte
    
    // Determine if we're sending the last byte of the message
    assign sha_tlast = (byte_counter == 7'd63) && stored_tlast;
    
    // Set valid when in SENDING state
    assign sha_tvalid = (state == SENDING);
    
    // Fixed ID value (can be modified if needed)
    assign sha_tid = 32'h0; 
    
    // State machine and serialization logic
    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            state <= IDLE;
            byte_counter <= 7'd0;
            stored_tlast <= 1'b0;
            data_buffer <= 512'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_serialization) begin
                        state <= SENDING;
                        byte_counter <= 7'd0;
                        stored_tlast <= axis_sink_tlast;
                        data_buffer <= axis_sink_tdata;
                    end
                end
                
                SENDING: begin
                    if (sha_tready) begin
                        // Shift buffer left by 8 bits (discard the sent byte)
                        data_buffer <= {data_buffer[503:0], 8'b0};
                        
                        if (byte_counter == 7'd63) begin
                            // Last byte sent
                            state <= WAITING;
                            byte_counter <= 7'd0;
                        end else begin
                            // Increment byte counter
                            byte_counter <= byte_counter + 7'd1;
                        end
                    end
                end
                
                WAITING: begin
                    // Wait for SHA output to be ready before accepting new input
                    if (sha_ovalid) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
    // Instantiate the original SHA-256 module
    sha256 sha256_inst (
        .rstn(aresetn),
        .clk(aclk),
        // Input interface
        .tready(sha_tready),
        .tvalid(sha_tvalid),
        .tlast(sha_tlast),
        .tid(sha_tid),
        .tdata(sha_tdata),
        // Output interface
        .ovalid(sha_ovalid),
        .oid(sha_oid),
        .olen(sha_olen),
        .osha(sha_osha)
    );

endmodule