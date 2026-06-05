class axi_apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_apb_scoreboard)

  uvm_analysis_imp #(axi_lite_sequence_item, axi_apb_scoreboard) axi_port;
  uvm_analysis_imp #(apb_sequence_item, axi_apb_scoreboard) apb_port;

  axi_lite_sequence_item axi_q[$];
  apb_sequence_item apb_q[$];

  int unsigned errors = 0;
  int unsigned matches = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_build_phase phase);
    super.build_phase(phase);
    axi_port = new("axi_port", this);
    apb_port = new("apb_port", this);
  endfunction

  virtual function void write_axi(axi_lite_sequence_item item);
    `uvm_info("SCORE", $sformatf("AXI Transaction: %s", item.convert2string()), UVM_MEDIUM)
    axi_q.push_back(item);
    check_transactions();
  endfunction

  virtual function void write_apb(apb_sequence_item item);
    `uvm_info("SCORE", $sformatf("APB Transaction: %s", item.convert2string()), UVM_MEDIUM)
    apb_q.push_back(item);
    check_transactions();
  endfunction

  virtual function void check_transactions();
    axi_lite_sequence_item axi_item;
    apb_sequence_item apb_item;

    if (axi_q.size() > 0 && apb_q.size() > 0) begin
      axi_item = axi_q.pop_front();
      apb_item = apb_q.pop_front();

      // Check address mapping
      if (axi_item.awaddr != apb_item.paddr && axi_item.araddr != apb_item.paddr) begin
        `uvm_error("SCORE", $sformatf("Address mismatch: AXI=0x%08x, APB=0x%08x", 
                                       axi_item.awaddr, apb_item.paddr))
        errors++;
      end else begin
        matches++;
        `uvm_info("SCORE", "Transaction match verified", UVM_MEDIUM)
      end
    end
  endfunction

  virtual function void report_phase(uvm_report_phase phase);
    super.report_phase(phase);
    `uvm_info("SCORE", $sformatf("\n=== SCOREBOARD REPORT ===\nMatches: %0d\nErrors: %0d", matches, errors), UVM_MEDIUM)
  endfunction

endclass
