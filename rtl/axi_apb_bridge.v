// =====================================================
// AXI Lite Slave to APB Master Bridge
// =====================================================
// Top-level module that bridges AXI Lite Slave interface
// to APB Master interface

module axi_apb_bridge #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  // AXI Lite Slave Interface (Input)
  input  logic                      axi_clk,
  input  logic                      axi_rst_n,
  
  // AXI Write Address Channel
  input  logic [ADDR_WIDTH-1:0]     axi_awaddr,
  input  logic [2:0]                axi_awprot,
  input  logic                      axi_awvalid,
  output logic                      axi_awready,
  
  // AXI Write Data Channel
  input  logic [DATA_WIDTH-1:0]     axi_wdata,
  input  logic [DATA_WIDTH/8-1:0]   axi_wstrb,
  input  logic                      axi_wvalid,
  output logic                      axi_wready,
  
  // AXI Write Response Channel
  output logic [1:0]                axi_bresp,
  output logic                      axi_bvalid,
  input  logic                      axi_bready,
  
  // AXI Read Address Channel
  input  logic [ADDR_WIDTH-1:0]     axi_araddr,
  input  logic [2:0]                axi_arprot,
  input  logic                      axi_arvalid,
  output logic                      axi_arready,
  
  // AXI Read Data Channel
  output logic [DATA_WIDTH-1:0]     axi_rdata,
  output logic [1:0]                axi_rresp,
  output logic                      axi_rvalid,
  input  logic                      axi_rready,
  
  // APB Master Interface (Output)
  input  logic                      apb_clk,
  input  logic                      apb_rst_n,
  
  output logic [ADDR_WIDTH-1:0]     apb_paddr,
  output logic                      apb_pwrite,
  output logic [DATA_WIDTH-1:0]     apb_pwdata,
  output logic                      apb_psel,
  output logic                      apb_penable,
  input  logic [DATA_WIDTH-1:0]     apb_prdata,
  input  logic                      apb_pready,
  input  logic                      apb_pslverr
);

  // ===== Internal Signals =====
  
  // Write path signals
  logic [ADDR_WIDTH-1:0]     wr_addr_buffer;
  logic [DATA_WIDTH-1:0]     wr_data_buffer;
  logic [DATA_WIDTH/8-1:0]   wr_strb_buffer;
  logic                      write_in_progress;
  logic                      write_address_phase;
  logic                      write_data_phase;
  logic                      apb_write_in_progress;
  
  // Read path signals
  logic [ADDR_WIDTH-1:0]     rd_addr_buffer;
  logic                      read_in_progress;
  logic                      read_address_phase;
  logic                      apb_read_in_progress;
  logic [DATA_WIDTH-1:0]     apb_read_data;
  
  // ===== AXI LITE SLAVE - WRITE PATH =====
  
  // Write Address Channel Control
  always_ff @(posedge axi_clk or negedge axi_rst_n) begin
    if (!axi_rst_n) begin
      write_address_phase <= 1'b0;
      wr_addr_buffer <= '0;
    end else begin
      if (axi_awvalid && axi_awready) begin
        write_address_phase <= 1'b1;
        wr_addr_buffer <= axi_awaddr;
      end else if (axi_wvalid && axi_wready) begin
        write_address_phase <= 1'b0;
      end
    end
  end
  
  // Write Data Channel Control
  always_ff @(posedge axi_clk or negedge axi_rst_n) begin
    if (!axi_rst_n) begin
      write_data_phase <= 1'b0;
      wr_data_buffer <= '0;
      wr_strb_buffer <= '0;
    end else begin
      if (axi_wvalid && axi_wready) begin
        write_data_phase <= 1'b1;
        wr_data_buffer <= axi_wdata;
        wr_strb_buffer <= axi_wstrb;
      end else if (axi_bvalid && axi_bready) begin
        write_data_phase <= 1'b0;
      end
    end
  end
  
  // Write Ready Control
  assign axi_awready = ~write_address_phase & ~apb_write_in_progress;
  assign axi_wready = write_address_phase & ~apb_write_in_progress;
  
  // Write Response Control
  always_ff @(posedge axi_clk or negedge axi_rst_n) begin
    if (!axi_rst_n) begin
      axi_bvalid <= 1'b0;
      axi_bresp <= 2'b00;  // OKAY response
    end else begin
      if (apb_psel && apb_penable && apb_pready) begin
        // APB write completed
        axi_bvalid <= 1'b1;
        axi_bresp <= apb_pslverr ? 2'b10 : 2'b00;  // Error or Okay
      end else if (axi_bvalid && axi_bready) begin
        axi_bvalid <= 1'b0;
      end
    end
  end
  
  // ===== AXI LITE SLAVE - READ PATH =====
  
  // Read Address Channel Control
  always_ff @(posedge axi_clk or negedge axi_rst_n) begin
    if (!axi_rst_n) begin
      read_address_phase <= 1'b0;
      rd_addr_buffer <= '0;
    end else begin
      if (axi_arvalid && axi_arready) begin
        read_address_phase <= 1'b1;
        rd_addr_buffer <= axi_araddr;
      end else if (axi_rvalid && axi_rready) begin
        read_address_phase <= 1'b0;
      end
    end
  end
  
  // Read Ready Control
  assign axi_arready = ~read_address_phase & ~apb_read_in_progress;
  
  // Read Data Channel Control
  always_ff @(posedge axi_clk or negedge axi_rst_n) begin
    if (!axi_rst_n) begin
      axi_rvalid <= 1'b0;
      axi_rdata <= '0;
      axi_rresp <= 2'b00;
    end else begin
      if (apb_psel && !apb_pwrite && apb_penable && apb_pready) begin
        // APB read completed
        axi_rvalid <= 1'b1;
        axi_rdata <= apb_prdata;
        axi_rresp <= apb_pslverr ? 2'b10 : 2'b00;  // Error or Okay
      end else if (axi_rvalid && axi_rready) begin
        axi_rvalid <= 1'b0;
      end
    end
  end
  
  // ===== APB MASTER - WRITE CONTROL =====
  
  // Track write completion from APB
  always_ff @(posedge apb_clk or negedge apb_rst_n) begin
    if (!apb_rst_n) begin
      apb_write_in_progress <= 1'b0;
    end else begin
      if (axi_wvalid && axi_wready) begin
        apb_write_in_progress <= 1'b1;
      end else if (apb_psel && apb_penable && apb_pready) begin
        apb_write_in_progress <= 1'b0;
      end
    end
  end
  
  // APB Write Protocol State Machine
  always_ff @(posedge apb_clk or negedge apb_rst_n) begin
    if (!apb_rst_n) begin
      apb_psel <= 1'b0;
      apb_penable <= 1'b0;
      apb_pwrite <= 1'b0;
      apb_paddr <= '0;
      apb_pwdata <= '0;
    end else begin
      if (apb_write_in_progress) begin
        if (!apb_psel) begin
          // Setup phase: Assert PSEL
          apb_psel <= 1'b1;
          apb_penable <= 1'b0;
          apb_pwrite <= 1'b1;
          apb_paddr <= wr_addr_buffer;
          apb_pwdata <= wr_data_buffer;
        end else if (apb_psel && !apb_penable) begin
          // Access phase: Assert PENABLE
          apb_penable <= 1'b1;
        end else if (apb_pready) begin
          // Transaction complete
          apb_psel <= 1'b0;
          apb_penable <= 1'b0;
        end
      end
    end
  end
  
  // ===== APB MASTER - READ CONTROL =====
  
  // Track read completion from APB
  always_ff @(posedge apb_clk or negedge apb_rst_n) begin
    if (!apb_rst_n) begin
      apb_read_in_progress <= 1'b0;
    end else begin
      if (axi_arvalid && axi_arready) begin
        apb_read_in_progress <= 1'b1;
      end else if (apb_psel && !apb_pwrite && apb_penable && apb_pready) begin
        apb_read_in_progress <= 1'b0;
      end
    end
  end
  
  // APB Read Protocol State Machine
  always_ff @(posedge apb_clk or negedge apb_rst_n) begin
    if (!apb_rst_n) begin
      apb_psel <= 1'b0;
      apb_penable <= 1'b0;
      apb_pwrite <= 1'b0;
      apb_paddr <= '0;
    end else begin
      if (apb_read_in_progress && !apb_write_in_progress) begin
        if (!apb_psel) begin
          // Setup phase: Assert PSEL
          apb_psel <= 1'b1;
          apb_penable <= 1'b0;
          apb_pwrite <= 1'b0;
          apb_paddr <= rd_addr_buffer;
        end else if (apb_psel && !apb_penable) begin
          // Access phase: Assert PENABLE
          apb_penable <= 1'b1;
        end else if (apb_pready) begin
          // Transaction complete
          apb_psel <= 1'b0;
          apb_penable <= 1'b0;
        end
      end
    end
  end

endmodule
