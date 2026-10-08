module apb_top;
  import uvm_pkg::*;
  import pkg::*;
 
  
  logic PCLK;
  logic PRESETn;
 
  initial PCLK = 0;
  always #5 PCLK = ~PCLK;
  
  initial begin
    PRESETn = 0;
    #20;
    PRESETn = 1;
  end
  
  apb_if vif(PCLK,PRESETn);
  
    apb_slave #(
    .ADDR_WIDTH   (8),
    .DATA_WIDTH   (32),
    .NUM_REGS     (8),
    .WAIT_REG_IDX (2),
    .WAIT_CYCLES  (3),
    .RO_REG_IDX   (5),
    .RDERR_REG_IDX(6)
    )dut (
    .PCLK   (PCLK),
    .PRESETn(PRESETn),
    .PADDR  (vif.PADDR),
    .PSEL   (vif.PSEL),
    .PENABLE(vif.PENABLE),
    .PWRITE (vif.PWRITE),
    .PWDATA (vif.PWDATA),
    .PRDATA (vif.PRDATA),
    .PREADY (vif.PREADY),
    .PSLVERR(vif.PSLVERR)
  );

  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"*","vif",vif);
    run_test("apb_test");
  end
    initial
    begin
      
      $dumpfile("apb_tb.vcd");
      $dumpvars(0,apb_top);
      
    end
  
endmodule
    