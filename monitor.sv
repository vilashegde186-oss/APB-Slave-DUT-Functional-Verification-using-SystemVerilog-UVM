class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  virtual apb_if vif;
  uvm_analysis_port #(apb_transaction) ap;

  function new(string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      apb_transaction tx;

      @(posedge vif.PCLK);
      wait (vif.PSEL && !vif.PENABLE);

      tx = apb_transaction::type_id::create("tx");
      tx.addr  = vif.PADDR;
      tx.write = vif.PWRITE;
      tx.wdata = vif.PWDATA;

      @(posedge vif.PCLK);
      while (!vif.PREADY)
        @(posedge vif.PCLK);

      tx.rdata   = vif.PRDATA;
      tx.pslverr = vif.PSLVERR;

      ap.write(tx);
    end
  endtask

endclass