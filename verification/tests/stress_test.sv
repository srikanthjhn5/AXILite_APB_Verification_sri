class stress_test extends base_test;
  `uvm_component_utils(stress_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    stress_sequence seq;

    phase.raise_objection(this);

    seq = stress_sequence::type_id::create("stress_seq");
    seq.start(env.virtual_sequencer);

    #10us;

    phase.drop_objection(this);
  endtask

endclass

class stress_sequence extends uvm_sequence #(axi_lite_sequence_item);
  `uvm_object_utils(stress_sequence)

  function new(string name = "stress_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_lite_sequence_item req;

    `uvm_info("STRESS", "Starting stress sequence with high transaction rate", UVM_MEDIUM)

    repeat (100) begin
      req = axi_lite_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end

    `uvm_info("STRESS", "Stress sequence completed - 100 transactions", UVM_MEDIUM)
  endtask

endclass
