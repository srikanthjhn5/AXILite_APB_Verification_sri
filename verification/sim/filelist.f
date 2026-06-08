# RTL Files (DUT)
../../rtl/axi_apb_bridge.v
../../rtl/axi_lite_slave.v
../../rtl/apb_master.v

# Interfaces
../interfaces/axi_lite_if.sv
../interfaces/apb_if.sv

# AXI Lite Agent
../env/axi_lite_agent/axi_lite_sequence_item.sv
../env/axi_lite_agent/axi_lite_driver.sv
../env/axi_lite_agent/axi_lite_monitor.sv
../env/axi_lite_agent/axi_lite_agent.sv

# APB Agent
../env/apb_agent/apb_sequence_item.sv
../env/apb_agent/apb_monitor.sv
../env/apb_agent/apb_agent.sv

# Environment
../env/axi_apb_scoreboard.sv
../env/axi_apb_env.sv

# Tests
../tests/base_test.sv
../tests/sanity_test.sv
../tests/functional_test.sv
../tests/stress_test.sv

# Testbench
../tb/top_tb.sv
