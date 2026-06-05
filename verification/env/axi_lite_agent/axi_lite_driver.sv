class axi_lite_driver extends uvm_driver #(axi_lite_sequence_item);
  `uvm_component_utils(axi_lite_driver)

  virtual axi_lite_if vif;
  int write_count = 0;
  int read_count = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  virtual task run_phase(uvm_run_phase phase);
    axi_lite_sequence_item req, rsp;
    
    // Initialize signals
    init_signals();

    forever begin
      seq_item_port.get_next_item(req);
      
      // Drive AXI Lite transaction
      fork
        drive_write_address(req);
        drive_write_data(req);
        drive_read_address(req);
      join_any

      // Wait for responses
      fork
        begin
          wait_write_response(rsp);
        end
        begin
          wait_read_response(rsp);
        end
      join_any

      seq_item_port.item_done();
    end
  endtask

  virtual task init_signals();
    vif.awvalid <= 1'b0;
    vif.wvalid  <= 1'b0;
    vif.bready  <= 1'b1;
    vif.arvalid <= 1'b0;
    vif.rready  <= 1'b1;
  endtask

  virtual task drive_write_address(axi_lite_sequence_item req);
    if (req.wstrb != 4'b0000) begin
      vif.awaddr  <= req.awaddr;
      vif.awprot  <= req.awprot;
      vif.awvalid <= 1'b1;
      
      wait (vif.awready == 1'b1);
      @(posedge vif.clk);
      vif.awvalid <= 1'b0;
      
      write_count++;
      `uvm_info("AXI_DRV", $sformatf("Write Address: 0x%08x", req.awaddr), UVM_MEDIUM)
    end
  endtask

  virtual task drive_write_data(axi_lite_sequence_item req);
    if (req.wstrb != 4'b0000) begin
      vif.wdata  <= req.wdata;
      vif.wstrb  <= req.wstrb;
      vif.wvalid <= 1'b1;
      
      wait (vif.wready == 1'b1);
      @(posedge vif.clk);
      vif.wvalid <= 1'b0;
      
      `uvm_info("AXI_DRV", $sformatf("Write Data: 0x%08x, Strobe: 0x%x", req.wdata, req.wstrb), UVM_MEDIUM)
    end
  endtask

  virtual task drive_read_address(axi_lite_sequence_item req);
    vif.araddr  <= req.araddr;
    vif.arprot  <= req.arprot;
    vif.arvalid <= 1'b1;
    
    wait (vif.arready == 1'b1);
    @(posedge vif.clk);
    vif.arvalid <= 1'b0;
    
    read_count++;
    `uvm_info("AXI_DRV", $sformatf("Read Address: 0x%08x", req.araddr), UVM_MEDIUM)
  endtask

  virtual task wait_write_response(axi_lite_sequence_item rsp);
    wait (vif.bvalid == 1'b1);
    @(posedge vif.clk);
    `uvm_info("AXI_DRV", "Write Response received", UVM_MEDIUM)
  endtask

  virtual task wait_read_response(axi_lite_sequence_item rsp);
    wait (vif.rvalid == 1'b1);
    @(posedge vif.clk);
    `uvm_info("AXI_DRV", $sformatf("Read Data: 0x%08x", vif.rdata), UVM_MEDIUM)
  endtask

endclass
