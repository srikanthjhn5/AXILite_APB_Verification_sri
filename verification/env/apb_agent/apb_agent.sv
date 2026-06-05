class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)

  apb_monitor monitor;
  uvm_analysis_port #(apb_sequence_item) analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    monitor = apb_monitor::type_id::create("monitor", this);
    analysis_port = new("analysis_port", this);
  endfunction

  virtual function void connect_phase(uvm_connect_phase phase);
    super.connect_phase(phase);
    monitor.item_collected_port.connect(analysis_port);
  endfunction

endclass
