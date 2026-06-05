class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  virtual apb_if vif;
  uvm_analysis_port #(apb_sequence_item) item_collected_port;

  apb_sequence_item collected_item;
  int unsigned transactions_collected = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual apb_if)::get(this, "", "apb_if", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    forever begin
      wait (vif.psel && vif.penable);
      
      collected_item = apb_sequence_item::type_id::create("collected_item");
      collected_item.paddr = vif.paddr;
      collected_item.pwrite = vif.pwrite;
      
      if (vif.pwrite) begin
        collected_item.pwdata = vif.pwdata;
      end else begin
        collected_item.prdata = vif.prdata;
      end
      
      wait (vif.pready);
      @(posedge vif.pclk);
      
      transactions_collected++;
      item_collected_port.write(collected_item);
      `uvm_info("APB_MON", $sformatf("APB transaction collected: %s", collected_item.convert2string()), UVM_MEDIUM)
    end
  endtask

endclass
