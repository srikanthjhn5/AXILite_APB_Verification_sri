interface axi_lite_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input clk,
  input rst_n
);

  // Write Address Channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [2:0]           awprot;
  logic                 awvalid;
  logic                 awready;

  // Write Data Channel
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                 wvalid;
  logic                 wready;

  // Write Response Channel
  logic [1:0]          bresp;
  logic                bvalid;
  logic                bready;

  // Read Address Channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic [2:0]           arprot;
  logic                 arvalid;
  logic                 arready;

  // Read Data Channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]           rresp;
  logic                 rvalid;
  logic                 rready;

  // Modports
  modport master (
    output awaddr, awprot, awvalid, wdata, wstrb, wvalid, araddr, arprot, arvalid, bready, rready,
    input  awready, wready, bresp, bvalid, rdata, rresp, rvalid, arready
  );

  modport slave (
    input  awaddr, awprot, awvalid, wdata, wstrb, wvalid, araddr, arprot, arvalid, bready, rready,
    output awready, wready, bresp, bvalid, rdata, rresp, rvalid, arready
  );

endinterface
