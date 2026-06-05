class axi_lite_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(axi_lite_sequence_item)

  // AXI Lite Write Address Channel
  rand logic [31:0] awaddr;           // Write address
  rand logic [2:0]  awprot;           // Write protection type
  logic             awvalid;          // Write address valid
  logic             awready;          // Write address ready

  // AXI Lite Write Data Channel
  rand logic [31:0] wdata;            // Write data
  rand logic [3:0]  wstrb;            // Write strobes
  logic             wvalid;           // Write valid
  logic             wready;           // Write ready

  // AXI Lite Write Response Channel
  logic             bvalid;           // Response valid
  logic             bready;           // Response ready
  logic [1:0]       bresp;            // Response

  // AXI Lite Read Address Channel
  rand logic [31:0] araddr;           // Read address
  rand logic [2:0]  arprot;           // Read protection type
  logic             arvalid;          // Read address valid
  logic             arready;          // Read address ready

  // AXI Lite Read Data Channel
  logic [31:0]      rdata;            // Read data
  logic [1:0]       rresp;            // Read response
  logic             rvalid;           // Read valid
  logic             rready;           // Read ready

  // Constraints
  constraint addr_range {
    awaddr inside {[32'h0000_0000 : 32'h0FFF_FFFF]};
    araddr inside {[32'h0000_0000 : 32'h0FFF_FFFF]};
  }

  constraint wstrb_valid {
    wstrb != 4'b0000;
  }

  constraint prot_valid {
    awprot[2] == 1'b0;  // Data access
    arprot[2] == 1'b0;  // Data access
  }

  function new(string name = "axi_lite_sequence_item");
    super.new(name);
  endfunction

  function string convert2string();
    string s;
    s = $sformatf("AXILITE: awaddr=0x%08x, wdata=0x%08x, wstrb=0x%x, araddr=0x%08x",
                  awaddr, wdata, wstrb, araddr);
    return s;
  endfunction

  function void do_copy(uvm_object rhs);
    axi_lite_sequence_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_fatal("CAST_ERROR", "Cast failed in do_copy")
    end
    super.do_copy(rhs);
    awaddr = rhs_.awaddr;
    awprot = rhs_.awprot;
    wdata  = rhs_.wdata;
    wstrb  = rhs_.wstrb;
    araddr = rhs_.araddr;
    arprot = rhs_.arprot;
  endfunction

endclass
