class functional_test extends base_test;
  `uvm_component_utils(functional_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    write_sequence wr_seq;
    read_sequence rd_seq;
    mixed_sequence mx_seq;

    phase.raise_objection(this);

    wr_seq = write_sequence::type_id::create("wr_seq");
    rd_seq = read_sequence::type_id::create("rd_seq");
    mx_seq = mixed_sequence::type_id::create("mx_seq");

    wr_seq.start(env.virtual_sequencer);
    rd_seq.start(env.virtual_sequencer);
    mx_seq.start(env.virtual_sequencer);

    #5us;

    phase.drop_objection(this);
  endtask

endclass

class write_sequence extends uvm_sequence #(axi_lite_sequence_item);
  `uvm_object_utils(write_sequence)

  function new(string name = "write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_lite_sequence_item req;

    `uvm_info("WRITE_SEQ", "Starting write sequence", UVM_MEDIUM)

    repeat (10) begin
      req = axi_lite_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {wstrb != 4'b0000;});
      finish_item(req);
    end
  endtask

endclass

class read_sequence extends uvm_sequence #(axi_lite_sequence_item);
  `uvm_object_utils(read_sequence)

  function new(string name = "read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_lite_sequence_item req;

    `uvm_info("READ_SEQ", "Starting read sequence", UVM_MEDIUM)

    repeat (10) begin
      req = axi_lite_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {wstrb == 4'b0000;});
      finish_item(req);
    end
  endtask

endclass

class mixed_sequence extends uvm_sequence #(axi_lite_sequence_item);
  `uvm_object_utils(mixed_sequence)

  function new(string name = "mixed_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi_lite_sequence_item req;

    `uvm_info("MIXED_SEQ", "Starting mixed read/write sequence", UVM_MEDIUM)

    repeat (20) begin
      req = axi_lite_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
  endtask

endclass
