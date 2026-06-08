// =====================================================
// APB Master Interface Module
// =====================================================
// Implements APB Master protocol with handshaking

module apb_master #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic                      clk,
  input  logic                      rst_n,
  
  // Request from AXI side
  input  logic [ADDR_WIDTH-1:0]     req_addr,
  input  logic [DATA_WIDTH-1:0]     req_wdata,
  input  logic                      req_write,
  input  logic                      req_valid,
  output logic                      req_ready,
  
  // Response to AXI side
  output logic [DATA_WIDTH-1:0]     resp_rdata,
  output logic                      resp_valid,
  input  logic                      resp_ready,
  
  // APB Master Signals
  output logic [ADDR_WIDTH-1:0]     paddr,
  output logic                      pwrite,
  output logic [DATA_WIDTH-1:0]     pwdata,
  output logic                      psel,
  output logic                      penable,
  input  logic [DATA_WIDTH-1:0]     prdata,
  input  logic                      pready,
  input  logic                      pslverr
);

  // APB State Machine
  typedef enum logic [1:0] {
    APB_IDLE,
    APB_SETUP,
    APB_ACCESS
  } apb_state_t;
  
  apb_state_t state, next_state;
  
  logic [ADDR_WIDTH-1:0] addr_buffer;
  logic [DATA_WIDTH-1:0] wdata_buffer;
  logic write_buffer;

  // ===== APB STATE MACHINE =====
  
  always_comb begin
    next_state = state;
    psel = 1'b0;
    penable = 1'b0;
    req_ready = 1'b0;
    resp_valid = 1'b0;
    
    case(state)
      APB_IDLE: begin
        req_ready = 1'b1;
        if (req_valid) begin
          next_state = APB_SETUP;
        end
      end
      
      APB_SETUP: begin
        psel = 1'b1;
        penable = 1'b0;
        next_state = APB_ACCESS;
      end
      
      APB_ACCESS: begin
        psel = 1'b1;
        penable = 1'b1;
        
        if (pready) begin
          resp_valid = 1'b1;
          if (resp_ready) begin
            next_state = APB_IDLE;
          end
        end
      end
    endcase
  end
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= APB_IDLE;
      paddr <= '0;
      pwrite <= 1'b0;
      pwdata <= '0;
      resp_rdata <= '0;
    end else begin
      state <= next_state;
      
      // Buffer request
      if (req_valid && req_ready) begin
        addr_buffer <= req_addr;
        wdata_buffer <= req_wdata;
        write_buffer <= req_write;
      end
      
      // Drive APB signals
      paddr <= addr_buffer;
      pwrite <= write_buffer;
      pwdata <= wdata_buffer;
      
      // Capture read data
      if (psel && penable && pready && !pwrite) begin
        resp_rdata <= prdata;
      end
    end
  end

endmodule
