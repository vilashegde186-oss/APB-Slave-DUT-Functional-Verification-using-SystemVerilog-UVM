class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  uvm_analysis_imp#(apb_transaction,apb_scoreboard) analysis_export;
  
  bit [31:0] shadow_reg[0:7];
  int fail_cnt;
  int pass_cnt;
  
  function new(string name ="apb_scoreboard",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export",this);
    foreach(shadow_reg[i])
      shadow_reg[i]=0;
  endfunction
  
  function void write(apb_transaction tx);
    int exp_rdata;
    int exp_pslverr;
    
    if(tx.write)
      begin
        if(tx.addr<8 && tx.addr!=5)
          begin
            shadow_reg[tx.addr] = tx.wdata;
          end
      end
    else
      begin
        if(tx.addr >= 8 || tx.addr ==6)
          begin
          exp_rdata = 0;
          exp_pslverr = 1;
          end
        else
          begin
            exp_rdata = shadow_reg[tx.addr];
            exp_pslverr = 0;
          end
        if (tx.rdata !== exp_rdata || tx.pslverr !== exp_pslverr) begin
        fail_cnt++;
        `uvm_error("SCOREBOARD",
          $sformatf("MISMATCH addr=%0d exp_rdata=%0h act_rdata=%0h exp_err=%0b act_err=%0b",
                      tx.addr, exp_rdata, tx.rdata, exp_pslverr, tx.pslverr))
      end
      else begin
        pass_cnt++;
        `uvm_info("SCOREBOARD",
          $sformatf("MATCH addr=%0d rdata=%0h", tx.addr, tx.rdata), UVM_LOW)
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD",
      $sformatf("TOTAL: pass=%0d fail=%0d", pass_cnt, fail_cnt), UVM_LOW)
  endfunction

endclass