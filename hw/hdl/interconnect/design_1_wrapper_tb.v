`timescale 1ns / 1ps

module design_1_wrapper_tb();
  // Clock and Reset
  reg aclk_0 = 0;
  reg aresetn_0 = 0;
  
  // Clock generation - 100MHz
  always #5 aclk_0 = ~aclk_0;
  
  // Slave Interface Signals
  reg [7:0] S00_AXIS_0_tdata;
  reg [1:0] S00_AXIS_0_tdest;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;

  reg [7:0] S01_AXIS_0_tdata;
  reg [1:0] S01_AXIS_0_tdest;
  wire S01_AXIS_0_tready;
  reg S01_AXIS_0_tvalid;

  reg [7:0] S02_AXIS_0_tdata;
  reg [1:0] S02_AXIS_0_tdest;
  wire S02_AXIS_0_tready;
  reg S02_AXIS_0_tvalid;
  
  reg [7:0] S03_AXIS_0_tdata;
  reg [1:0] S03_AXIS_0_tdest;
  wire S03_AXIS_0_tready;
  reg S03_AXIS_0_tvalid;
  
  // Master Interface Signals
  wire [7:0] M00_AXIS_0_tdata;
  wire [1:0] M00_AXIS_0_tdest;
  reg M00_AXIS_0_tready;
  wire M00_AXIS_0_tvalid;
  
  wire [7:0] M01_AXIS_0_tdata;
  wire [1:0] M01_AXIS_0_tdest;
  reg M01_AXIS_0_tready;
  wire M01_AXIS_0_tvalid;
  
  wire [7:0] M02_AXIS_0_tdata;
  wire [1:0] M02_AXIS_0_tdest;
  reg M02_AXIS_0_tready;
  wire M02_AXIS_0_tvalid;
  
  wire [7:0] M03_AXIS_0_tdata;
  wire [1:0] M03_AXIS_0_tdest;
  reg M03_AXIS_0_tready;
  wire M03_AXIS_0_tvalid;

  wire [3:0] s_decode_err_0;
  
  // DUT instantiation
  design_1_wrapper DUT (
    .aclk_0(aclk_0),
    .aresetn_0(aresetn_0),
    
    .S00_AXIS_0_tdata(S00_AXIS_0_tdata),
    .S00_AXIS_0_tdest(S00_AXIS_0_tdest),
    .S00_AXIS_0_tready(S00_AXIS_0_tready),
    .S00_AXIS_0_tvalid(S00_AXIS_0_tvalid),
    
    .S01_AXIS_0_tdata(S01_AXIS_0_tdata),
    .S01_AXIS_0_tdest(S01_AXIS_0_tdest),
    .S01_AXIS_0_tready(S01_AXIS_0_tready),
    .S01_AXIS_0_tvalid(S01_AXIS_0_tvalid),
    
    .S02_AXIS_0_tdata(S02_AXIS_0_tdata),
    .S02_AXIS_0_tdest(S02_AXIS_0_tdest),
    .S02_AXIS_0_tready(S02_AXIS_0_tready),
    .S02_AXIS_0_tvalid(S02_AXIS_0_tvalid),
    
    .S03_AXIS_0_tdata(S03_AXIS_0_tdata),
    .S03_AXIS_0_tdest(S03_AXIS_0_tdest),
    .S03_AXIS_0_tready(S03_AXIS_0_tready),
    .S03_AXIS_0_tvalid(S03_AXIS_0_tvalid),
    
    .M00_AXIS_0_tdata(M00_AXIS_0_tdata),
    .M00_AXIS_0_tdest(M00_AXIS_0_tdest),
    .M00_AXIS_0_tready(M00_AXIS_0_tready),
    .M00_AXIS_0_tvalid(M00_AXIS_0_tvalid),
    
    .M01_AXIS_0_tdata(M01_AXIS_0_tdata),
    .M01_AXIS_0_tdest(M01_AXIS_0_tdest),
    .M01_AXIS_0_tready(M01_AXIS_0_tready),
    .M01_AXIS_0_tvalid(M01_AXIS_0_tvalid),
    
    .M02_AXIS_0_tdata(M02_AXIS_0_tdata),
    .M02_AXIS_0_tdest(M02_AXIS_0_tdest),
    .M02_AXIS_0_tready(M02_AXIS_0_tready),
    .M02_AXIS_0_tvalid(M02_AXIS_0_tvalid),
    
    .M03_AXIS_0_tdata(M03_AXIS_0_tdata),
    .M03_AXIS_0_tdest(M03_AXIS_0_tdest),
    .M03_AXIS_0_tready(M03_AXIS_0_tready),
    .M03_AXIS_0_tvalid(M03_AXIS_0_tvalid),
    
    .s_decode_err_0(s_decode_err_0)
  );
        
  // Test stimulus
  initial begin
    // Initialize
    S00_AXIS_0_tdata = 0;
    S00_AXIS_0_tdest = 0;
    S00_AXIS_0_tvalid = 0;
    
    S01_AXIS_0_tdata = 0;
    S01_AXIS_0_tdest = 0;
    S01_AXIS_0_tvalid = 0;
    
    S02_AXIS_0_tdata = 0;
    S02_AXIS_0_tdest = 0;
    S02_AXIS_0_tvalid = 0;
    
    S03_AXIS_0_tdata = 0;
    S03_AXIS_0_tdest = 0;
    S03_AXIS_0_tvalid = 0;
    
    M00_AXIS_0_tready = 1;
    M01_AXIS_0_tready = 1;
    M02_AXIS_0_tready = 1;
    M03_AXIS_0_tready = 1;
    
    // Reset
    aresetn_0 = 0;
    repeat(10) @(posedge aclk_0);
    aresetn_0 = 1;
    repeat(10) @(posedge aclk_0);
        
    // Test Case 1: Each input to its corresponding output
    $display("Test Case 1: One-to-One Routing");
    
    // S00 to M00
    S00_AXIS_0_tdata = 8'hA1;
    S00_AXIS_0_tdest = 2'b00;  // Route to M00
    S00_AXIS_0_tvalid = 1;
    repeat(2) @(posedge aclk_0);
    
    // S01 to M01
    S01_AXIS_0_tdata = 8'hB2;
    S01_AXIS_0_tdest = 2'b01;  // Route to M01
    S01_AXIS_0_tvalid = 1;
    repeat(2) @(posedge aclk_0);
    
    // S02 to M02
    S02_AXIS_0_tdata = 8'hC3;
    S02_AXIS_0_tdest = 2'b10;  // Route to M02
    S02_AXIS_0_tvalid = 1;
    repeat(2) @(posedge aclk_0);
    
    // S03 to M03
    S03_AXIS_0_tdata = 8'hD4;
    S03_AXIS_0_tdest = 2'b11;  // Route to M03
    S03_AXIS_0_tvalid = 1;
    
    repeat(50) @(posedge aclk_0);
    
    $finish;
  end
  
  // Monitor
  always @(posedge aclk_0) begin
    if(M00_AXIS_0_tvalid && M00_AXIS_0_tready)
      $display("M00 received: data=%h tdest=%h", M00_AXIS_0_tdata, M00_AXIS_0_tdest);
    if(M01_AXIS_0_tvalid && M01_AXIS_0_tready)
      $display("M01 received: data=%h tdest=%h", M01_AXIS_0_tdata, M01_AXIS_0_tdest);
    if(M02_AXIS_0_tvalid && M02_AXIS_0_tready)
      $display("M02 received: data=%h tdest=%h", M02_AXIS_0_tdata, M02_AXIS_0_tdest);
    if(M03_AXIS_0_tvalid && M03_AXIS_0_tready)
      $display("M03 received: data=%h tdest=%h", M03_AXIS_0_tdata, M03_AXIS_0_tdest);
  end

endmodule