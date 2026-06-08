class sanity_test extends base_test;
  `uvm_component_utils(sanity_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    sanity_sequence seq;

    phase.raise_objection(this);

    seq = sanity_sequence::type_id::create("sanity_seq");
    seq.start(env.virtual_sequencer);

    #1us;

    phase.drop_objection(this);
  endtask

endclass

class sanity_sequence extends uvm_sequence #(axi_lite_sequence_item);
  `uvm_object_utils(sanity_sequence)

  function new(string name = "sanity_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_lite_sequence_item req;

    `uvm_info("SANITY", "Starting sanity sequence", UVM_MEDIUM)

    repeat (5) begin
      req = axi_lite_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end

    `uvm_info("SANITY", "Sanity sequence completed", UVM_MEDIUM)
  endtask

endclass
