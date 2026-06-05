interface apb_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input pclk,
  input prst_n
);

  logic [ADDR_WIDTH-1:0] paddr;
  logic                  pwrite;
  logic [DATA_WIDTH-1:0] pwdata;
  logic                  psel;
  logic                  penable;
  logic [DATA_WIDTH-1:0] prdata;
  logic                  pready;
  logic                  pslverr;

  modport master (
    output paddr, pwrite, pwdata, psel, penable,
    input  prdata, pready, pslverr
  );

  modport slave (
    input  paddr, pwrite, pwdata, psel, penable,
    output prdata, pready, pslverr
  );

endinterface
