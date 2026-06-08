class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  axi_apb_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    env = axi_apb_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    phase.raise_objection(this);
    
    #10us;
    
    phase.drop_objection(this);
  endtask

  virtual function void report_phase(uvm_report_phase phase);
    super.report_phase(phase);
    `uvm_info("BASE_TEST", "Test execution completed", UVM_MEDIUM)
  endfunction

endclass
