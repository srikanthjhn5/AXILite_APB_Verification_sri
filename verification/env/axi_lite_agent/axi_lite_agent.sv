class axi_lite_agent extends uvm_agent;
  `uvm_component_utils(axi_lite_agent)

  axi_lite_driver    driver;
  axi_lite_monitor   monitor;
  uvm_sequencer #(axi_lite_sequence_item) sequencer;

  uvm_analysis_port #(axi_lite_sequence_item) analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    
    monitor = axi_lite_monitor::type_id::create("monitor", this);
    
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = axi_lite_driver::type_id::create("driver", this);
      sequencer = uvm_sequencer #(axi_lite_sequence_item)::type_id::create("sequencer", this);
    end
    
    analysis_port = new("analysis_port", this);
  endfunction

  virtual function void connect_phase(uvm_connect_phase phase);
    super.connect_phase(phase);
    
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    monitor.item_collected_port.connect(analysis_port);
  endfunction

endclass
