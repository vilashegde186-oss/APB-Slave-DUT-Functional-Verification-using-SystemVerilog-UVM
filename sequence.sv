class apb_sequence extends uvm_sequence #(apb_transaction);

  `uvm_object_utils(apb_sequence)

  rand int num_txns = 20;

  function new(string name = "apb_sequence");
    super.new(name);
  endfunction

  task body();
    apb_transaction tx;
    repeat (num_txns) begin
      tx = apb_transaction::type_id::create("tx");
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end
  endtask

endclass