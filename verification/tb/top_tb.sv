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

  logic clk, rst_n;
  logic pclk, prst_n;

  // Interface instantiation
  axi_lite_if axi_if (.clk(clk), .rst_n(rst_n));
  apb_if apb_if (.pclk(pclk), .prst_n(prst_n));

  // DUT instantiation (placeholder)
  // axi_apb_bridge dut (
  //   .axi_lite_if(axi_if),
  //   .apb_if(apb_if)
  // );

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    pclk = 1'b0;
    forever #5ns pclk = ~pclk;
  end

  // Reset generation
  initial begin
    rst_n = 1'b0;
    prst_n = 1'b0;
    #100ns;
    rst_n = 1'b1;
    prst_n = 1'b1;
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
