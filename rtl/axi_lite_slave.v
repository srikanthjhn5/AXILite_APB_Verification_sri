// =====================================================
// AXI Lite Slave Interface Module
// =====================================================
// Implements AXI Lite Slave protocol with handshaking
// This is a standalone module for reference

module axi_lite_slave #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic                      clk,
  input  logic                      rst_n,
  
  // Write Address Channel
  input  logic [ADDR_WIDTH-1:0]     awaddr,
  input  logic [2:0]                awprot,
  input  logic                      awvalid,
  output logic                      awready,
  
  // Write Data Channel
  input  logic [DATA_WIDTH-1:0]     wdata,
  input  logic [DATA_WIDTH/8-1:0]   wstrb,
  input  logic                      wvalid,
  output logic                      wready,
  
  // Write Response Channel
  output logic [1:0]                bresp,
  output logic                      bvalid,
  input  logic                      bready,
  
  // Read Address Channel
  input  logic [ADDR_WIDTH-1:0]     araddr,
  input  logic [2:0]                arprot,
  input  logic                      arvalid,
  output logic                      arready,
  
  // Read Data Channel
  output logic [DATA_WIDTH-1:0]     rdata,
  output logic [1:0]                rresp,
  output logic                      rvalid,
  input  logic                      rready
);

  // Response codes
  localparam RESP_OKAY  = 2'b00;
  localparam RESP_EXOK  = 2'b01;
  localparam RESP_SLVERR = 2'b10;
  localparam RESP_DECERR = 2'b11;

  // Write path state machine
  typedef enum logic [1:0] {
    WRITE_IDLE,
    WRITE_ADDR,
    WRITE_DATA,
    WRITE_RESP
  } write_state_t;
  
  write_state_t write_state, write_next_state;
  
  // Read path state machine
  typedef enum logic [1:0] {
    READ_IDLE,
    READ_ADDR,
    READ_DATA
  } read_state_t;
  
  read_state_t read_state, read_next_state;
  
  // Buffers
  logic [ADDR_WIDTH-1:0] wr_addr;
  logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH/8-1:0] wr_strb;
  logic [ADDR_WIDTH-1:0] rd_addr;
  logic [DATA_WIDTH-1:0] rd_data;

  // ===== WRITE PATH STATE MACHINE =====
  
  always_comb begin
    write_next_state = write_state;
    awready = 1'b0;
    wready = 1'b0;
    bvalid = 1'b0;
    
    case(write_state)
      WRITE_IDLE: begin
        if (awvalid) begin
          awready = 1'b1;
          write_next_state = WRITE_ADDR;
        end
      end
      
      WRITE_ADDR: begin
        if (wvalid) begin
          wready = 1'b1;
          write_next_state = WRITE_DATA;
        end
      end
      
      WRITE_DATA: begin
        write_next_state = WRITE_RESP;
      end
      
      WRITE_RESP: begin
        bvalid = 1'b1;
        if (bready) begin
          write_next_state = WRITE_IDLE;
        end
      end
    endcase
  end
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_state <= WRITE_IDLE;
      bresp <= RESP_OKAY;
    end else begin
      write_state <= write_next_state;
      
      // Sample write address
      if (awvalid && awready) begin
        wr_addr <= awaddr;
      end
      
      // Sample write data
      if (wvalid && wready) begin
        wr_data <= wdata;
        wr_strb <= wstrb;
      end
      
      // Set response
      bresp <= RESP_OKAY;
    end
  end

  // ===== READ PATH STATE MACHINE =====
  
  always_comb begin
    read_next_state = read_state;
    arready = 1'b0;
    rvalid = 1'b0;
    
    case(read_state)
      READ_IDLE: begin
        if (arvalid) begin
          arready = 1'b1;
          read_next_state = READ_ADDR;
        end
      end
      
      READ_ADDR: begin
        read_next_state = READ_DATA;
      end
      
      READ_DATA: begin
        rvalid = 1'b1;
        if (rready) begin
          read_next_state = READ_IDLE;
        end
      end
    endcase
  end
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_state <= READ_IDLE;
      rresp <= RESP_OKAY;
      rdata <= '0;
    end else begin
      read_state <= read_next_state;
      
      // Sample read address
      if (arvalid && arready) begin
        rd_addr <= araddr;
      end
      
      // Return read data
      rdata <= rd_data;
      rresp <= RESP_OKAY;
    end
  end

endmodule
