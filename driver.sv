class apb_driver extends uvm_driver #(apb_transaction);

  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_DRV", "virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    vif.PSEL    <= 0;
    vif.PENABLE <= 0;
    vif.PWRITE  <= 0;
    vif.PADDR   <= 0;
    vif.PWDATA  <= 0;

    forever begin
      apb_transaction tx;
      seq_item_port.get_next_item(tx);
      drive_transfer(tx);
      seq_item_port.item_done();
    end
  endtask

  task drive_transfer(apb_transaction tx);
    @(posedge vif.PCLK);
    vif.PSEL    <= 1;
    vif.PENABLE <= 0;
    vif.PWRITE  <= tx.write;
    vif.PADDR   <= tx.addr;
    vif.PWDATA  <= tx.wdata;

    @(posedge vif.PCLK);
    vif.PENABLE <= 1;

    while (!vif.PREADY)
      @(posedge vif.PCLK);

    tx.rdata   = vif.PRDATA;
    tx.pslverr = vif.PSLVERR;

    @(posedge vif.PCLK);
    vif.PSEL    <= 0;
    vif.PENABLE <= 0;
  endtask
endclass