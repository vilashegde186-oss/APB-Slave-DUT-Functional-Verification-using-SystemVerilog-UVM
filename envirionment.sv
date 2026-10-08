class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)
  
  apb_scoreboard sb;
  apb_agent agent;
  
  function new(string name="apb_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb = apb_scoreboard::type_id::create("sb",this);
    agent = apb_agent::type_id::create("agent",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.analysis_export);
  endfunction
  
endclass