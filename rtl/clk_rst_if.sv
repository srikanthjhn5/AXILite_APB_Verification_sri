// Clock and Reset Interface
interface clk_rst_if ();
  
  logic clk;
  logic rst_n;
  
  // Modport for master (test/top)
  modport master (
    inout clk,
    inout rst_n
  );
  
  // Modport for slave (DUT)
  modport slave (
    input clk,
    input rst_n
  );

endinterface
