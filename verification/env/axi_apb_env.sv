class axi_apb_env extends uvm_env;
  `uvm_component_utils(axi_apb_env)

  axi_lite_agent axi_agent;
  apb_agent      apb_agent;
  axi_apb_scoreboard scoreboard;
  axi_apb_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);

    axi_agent = axi_lite_agent::type_id::create("axi_agent", this);
    apb_agent = apb_agent::type_id::create("apb_agent", this);
    scoreboard = axi_apb_scoreboard::type_id::create("scoreboard", this);
    virtual_sequencer = axi_apb_virtual_sequencer::type_id::create("virtual_sequencer", this);
  endfunction

  virtual function void connect_phase(uvm_connect_phase phase);
    super.connect_phase(phase);

    axi_agent.analysis_port.connect(scoreboard.axi_port);
    apb_agent.analysis_port.connect(scoreboard.apb_port);

    virtual_sequencer.axi_sequencer = axi_agent.sequencer;
  endfunction

endclass

class axi_apb_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_apb_virtual_sequencer)

  uvm_sequencer #(axi_lite_sequence_item) axi_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
