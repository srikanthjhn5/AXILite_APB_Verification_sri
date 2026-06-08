AXI_APB_Verification/
├── README.md
├── .gitignore
│
├── docs/
│   └── VERIFICATION_PLAN.md
│
├── rtl/                          ← RTL FILES HERE
│   ├── axi_apb_bridge.v          ← Main DUT (Top module)
│   ├── axi_lite_slave.v          ← Optional (reference impl)
│   ├── apb_master.v              ← Optional (reference impl)
│   └── clk_rst_if.sv             ← Clock/Reset interface
│
├── verification/
│   ├── env/
│   │   ├── axi_lite_agent/
│   │   │   ├── axi_lite_sequence_item.sv
│   │   │   ├── axi_lite_driver.sv
│   │   │   ├── axi_lite_monitor.sv
│   │   │   └── axi_lite_agent.sv
│   │   │
│   │   ├── apb_agent/
│   │   │   ├── apb_sequence_item.sv
│   │   │   ├── apb_monitor.sv
│   │   │   └── apb_agent.sv
│   │   │
│   │   ├── axi_apb_scoreboard.sv
│   │   └── axi_apb_env.sv
│   │
│   ├── tests/
│   │   ├── base_test.sv
│   │   ├── sanity_test.sv
│   │   ├── functional_test.sv
│   │   └── stress_test.sv
│   │
│   ├── interfaces/
│   │   ├── axi_lite_if.sv
│   │   └── apb_if.sv
│   │
│   ├── tb/
│   │   └── top_tb.sv             ← UPDATED with DUT
│   │
│   └── sim/
│       ├── Makefile
│       ├── filelist.f             ← UPDATED with RTL files
│       ├── run_sim.sh
│       ├── run_gls.sh
│       └── run_regression.sh
│
├── sim_results/
│   ├── rtl/
│   ├── gls/
│   └── reports/
│
└── logs/
