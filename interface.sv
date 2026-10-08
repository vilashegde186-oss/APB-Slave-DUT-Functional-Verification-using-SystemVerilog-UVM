interface apb_if(input logic PCLK,input logic PRESETn);
  
  logic[7:0] PADDR;
  logic      PWRITE;
  logic      PENABLE;
  logic      PSEL;
  logic[31:0]PWDATA;
  logic      PREADY;
  logic[31:0]PRDATA;
  logic      PSLVERR;
  
endinterface