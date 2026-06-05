class apb_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(apb_sequence_item)

  rand logic [31:0] paddr;      // APB address
  rand logic [31:0] pwdata;     // Write data
  logic [31:0] prdata;          // Read data
  rand logic pwrite;            // Write enable
  logic psel;                   // Slave select
  logic penable;                // Enable signal
  logic pready;                 // Ready signal
  logic pslverr;                // Slave error

  constraint addr_range {
    paddr inside {[32'h0000_0000 : 32'h0FFF_FFFF]};
  }

  function new(string name = "apb_sequence_item");
    super.new(name);
  endfunction

  function string convert2string();
    string s;
    s = $sformatf("APB: paddr=0x%08x, pwrite=%b, pwdata=0x%08x, prdata=0x%08x",
                  paddr, pwrite, pwdata, prdata);
    return s;
  endfunction

endclass
