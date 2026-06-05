class axi_lite_monitor extends uvm_monitor;
  `uvm_component_utils(axi_lite_monitor)

  virtual axi_lite_if vif;
  uvm_analysis_port #(axi_lite_sequence_item) item_collected_port;

  axi_lite_sequence_item collected_item;
  int unsigned transactions_collected = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    fork
      collect_write_transactions();
      collect_read_transactions();
    join_none
  endtask

  virtual task collect_write_transactions();
    forever begin
      wait (vif.awvalid && vif.awready);
      collected_item = axi_lite_sequence_item::type_id::create("collected_item");
      
      @(posedge vif.clk);
      collected_item.awaddr = vif.awaddr;
      collected_item.awprot = vif.awprot;
      
      // Wait for write data
      wait (vif.wvalid && vif.wready);
      collected_item.wdata = vif.wdata;
      collected_item.wstrb = vif.wstrb;
      
      // Wait for write response
      wait (vif.bvalid && vif.bready);
      collected_item.bresp = vif.bresp;
      
      transactions_collected++;
      item_collected_port.write(collected_item);
      `uvm_info("AXI_MON", $sformatf("Write transaction collected: %s", collected_item.convert2string()), UVM_MEDIUM)
    end
  endtask

  virtual task collect_read_transactions();
    forever begin
      wait (vif.arvalid && vif.arready);
      collected_item = axi_lite_sequence_item::type_id::create("collected_item");
      
      @(posedge vif.clk);
      collected_item.araddr = vif.araddr;
      collected_item.arprot = vif.arprot;
      
      // Wait for read data
      wait (vif.rvalid && vif.rready);
      collected_item.rdata = vif.rdata;
      collected_item.rresp = vif.rresp;
      
      transactions_collected++;
      item_collected_port.write(collected_item);
      `uvm_info("AXI_MON", $sformatf("Read transaction collected: %s", collected_item.convert2string()), UVM_MEDIUM)
    end
  endtask

endclass
