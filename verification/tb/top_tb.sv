`timescale 1ns/1ps

module top_tb;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include all UVM components
  `include "axi_lite_sequence_item.sv"
  `include "axi_lite_driver.sv"
  `include "axi_lite_monitor.sv"
  `include "axi_lite_agent.sv"
  `include "apb_sequence_item.sv"
  `include "apb_monitor.sv"
  `include "apb_agent.sv"
  `include "axi_apb_scoreboard.sv"
  `include "axi_apb_env.sv"
  `include "base_test.sv"
  `include "sanity_test.sv"
  `include "functional_test.sv"
  `include "stress_test.sv"

  logic axi_clk, axi_rst_n;
  logic apb_clk, apb_rst_n;

  // Interface instantiation
  axi_lite_if axi_if (.clk(axi_clk), .rst_n(axi_rst_n));
  apb_if apb_if (.pclk(apb_clk), .prst_n(apb_rst_n));

  // ===== DUT INSTANTIATION =====
  axi_apb_bridge #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) dut (
    // AXI Lite Slave Interface
    .axi_clk(axi_clk),
    .axi_rst_n(axi_rst_n),
    
    // AXI Write Address Channel
    .axi_awaddr(axi_if.awaddr),
    .axi_awprot(axi_if.awprot),
    .axi_awvalid(axi_if.awvalid),
    .axi_awready(axi_if.awready),
    
    // AXI Write Data Channel
    .axi_wdata(axi_if.wdata),
    .axi_wstrb(axi_if.wstrb),
    .axi_wvalid(axi_if.wvalid),
    .axi_wready(axi_if.wready),
    
    // AXI Write Response Channel
    .axi_bresp(axi_if.bresp),
    .axi_bvalid(axi_if.bvalid),
    .axi_bready(axi_if.bready),
    
    // AXI Read Address Channel
    .axi_araddr(axi_if.araddr),
    .axi_arprot(axi_if.arprot),
    .axi_arvalid(axi_if.arvalid),
    .axi_arready(axi_if.arready),
    
    // AXI Read Data Channel
    .axi_rdata(axi_if.rdata),
    .axi_rresp(axi_if.rresp),
    .axi_rvalid(axi_if.rvalid),
    .axi_rready(axi_if.rready),
    
    // APB Master Interface
    .apb_clk(apb_clk),
    .apb_rst_n(apb_rst_n),
    
    .apb_paddr(apb_if.paddr),
    .apb_pwrite(apb_if.pwrite),
    .apb_pwdata(apb_if.pwdata),
    .apb_psel(apb_if.psel),
    .apb_penable(apb_if.penable),
    .apb_prdata(apb_if.prdata),
    .apb_pready(apb_if.pready),
    .apb_pslverr(apb_if.pslverr)
  );

  // Clock generation
  initial begin
    axi_clk = 1'b0;
    forever #5ns axi_clk = ~axi_clk;
  end

  initial begin
    apb_clk = 1'b0;
    forever #5ns apb_clk = ~apb_clk;
  end

  // Reset generation
  initial begin
    axi_rst_n = 1'b0;
    apb_rst_n = 1'b0;
    #100ns;
    axi_rst_n = 1'b1;
    apb_rst_n = 1'b1;
  end

  // Configuration and run
  initial begin
    uvm_config_db #(virtual axi_lite_if)::set(null, "uvm_test_top.*", "axi_lite_if", axi_if);
    uvm_config_db #(virtual apb_if)::set(null, "uvm_test_top.*", "apb_if", apb_if);

    run_test();
  end

  // Waveform dumping
  initial begin
    if ($test$plusargs("dump_waveform")) begin
      $dumpfile("waveform.vcd");
      $dumpvars(0, top_tb);
    end
  end

endmodule
