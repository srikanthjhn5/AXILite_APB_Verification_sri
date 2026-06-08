# AXI Lite Slave & APB Master - UVM Verification Environment

## Overview

Complete UVM-based verification environment for an **AXI Lite Slave to APB Master Bridge** design.

### Design Under Test (DUT)
- **Interface 1**: AXI Lite Slave (Receiving side)
- **Interface 2**: APB Master (Transmitting side)
- **Functionality**: Protocol bridge converting AXI Lite transactions to APB transactions

## Directory Structure

```
AXI_APB_Verification/
├── README.md                          # This file
├── docs/                              # Documentation
│   ├── VERIFICATION_PLAN.md
│   ├── UVM_ARCHITECTURE.md
│   ├── TEST_PLAN.md
│   └── COVERAGE_PLAN.md
│
├── rtl/                               # RTL Source Files
│   ├── axi_apb_bridge.v
│   ├── axi_lite_slave.v
│   └── apb_master.v
│
├── verification/                      # Verification Environment
│   ├── env/                           # UVM Environment
│   │   ├── axi_lite_agent/            # AXI Lite Agent
│   │   │   ├── axi_lite_sequence_item.sv
│   │   │   ├── axi_lite_driver.sv
│   │   │   ├── axi_lite_monitor.sv
│   │   │   └── axi_lite_agent.sv
│   │   │
│   │   ├── apb_agent/                 # APB Agent
│   │   │   ├── apb_sequence_item.sv
│   │   │   ├── apb_monitor.sv
│   │   │   └── apb_agent.sv
│   │   │
│   │   ├── axi_apb_env.sv             # Top Environment
│   │   └── axi_apb_scoreboard.sv      # Scoreboard
│   │
│   ├── tests/                         # Test Cases
│   │   ├── base_test.sv
│   │   ├── sanity_test.sv
│   │   ├── functional_test.sv
│   │   └── stress_test.sv
│   │
│   ├── interfaces/                    # Protocol Interfaces
│   │   ├── axi_lite_if.sv
│   │   └── apb_if.sv
│   │
│   ├── tb/                            # Testbench
│   │   └── top_tb.sv
│   │
│   └── sim/                           # Simulation Scripts
│       ├── Makefile
│       ├── filelist.f
│       ├── run_sim.sh
│       ├── run_gls.sh
│       └── run_regression.sh
│
├── sim_results/                       # Simulation Results
│   ├── rtl/                           # RTL simulation results
│   ├── gls/                           # GLS simulation results
│   └── reports/                       # Coverage & reports
│
├── logs/                              # Simulation Logs
└── coverage/                          # Coverage Databases

```

## Quick Start Guide

### 1. **Prerequisites**
- SystemVerilog simulator (VCS, Questa, or Xcelium)
- UVM library (1.2 or higher)
- Bash shell

### 2. **RTL Simulation**

```bash
cd verification/sim
chmod +x *.sh

# Run sanity test
./run_sim.sh -t sanity_test

# Run with GUI
./run_sim.sh -t sanity_test -g

# Run with waveforms
./run_sim.sh -t sanity_test -w
```

### 3. **GLS Simulation**

```bash
cd verification/sim

# Run GLS simulation
./run_gls.sh -t sanity_test

# Specify custom netlist
./run_gls.sh -t sanity_test -n /path/to/netlist.v
```

### 4. **Regression Testing**

```bash
cd verification/sim

# Run full regression with 5 random seeds
./run_regression.sh

# Run with 10 random seeds
./run_regression.sh -s 10

# RTL-only regression
./run_regression.sh --rtl-only

# GLS-only regression
./run_regression.sh --gls-only
```

### 5. **Using Makefile**

```bash
cd verification/sim

# View help
make help

# Compile only
make compile

# Run simulation
make sim TEST=sanity_test

# Generate coverage report
make coverage_report

# Clean all
make clean_all
```

## Available Tests

| Test Name | Type | Transactions | Purpose |
|-----------|------|--------------|---------|
| `sanity_test` | Directed | 5 | Basic functionality check |
| `functional_test` | Mixed | 40 | Feature-specific verification |
| `stress_test` | Random | 100 | High-volume transaction testing |

## Verification Features

✅ **Complete Protocol Coverage**
- AXI Lite Slave interface (read/write operations)
- APB Master interface (address/data transfer)
- Handshake and control signal verification

✅ **Cross-Domain Verification**
- Scoreboard validates data consistency between domains
- Address translation verification
- Response/Error propagation checking

✅ **Comprehensive Coverage**
- Functional coverage collection
- Code coverage tracking
- Toggle coverage analysis

✅ **Scalable Architecture**
- Modular UVM design
- Easy to extend for additional protocols
- Configuration-based test setup

## Simulation Results

After simulation, results are located in:

- **RTL Results**: `sim_results/rtl/`
- **GLS Results**: `sim_results/gls/`
- **Reports**: `sim_results/reports/`
- **Logs**: `logs/`

## Verification Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Functional Coverage | ≥95% | In Progress |
| Code Coverage | ≥95% | In Progress |
| Critical Bugs | 0 | In Progress |
| RTL Pass Rate | 100% | In Progress |
| GLS Pass Rate | 100% | In Progress |

## File Organization

### Interfaces (`verification/interfaces/`)
- `axi_lite_if.sv` - AXI Lite protocol interface
- `apb_if.sv` - APB protocol interface

### Agents (`verification/env/`)
- **AXI Lite Agent**: Drives AXI Lite transactions
- **APB Agent**: Monitors APB responses
- Includes drivers, monitors, sequencers, and coverage

### Environment (`verification/env/`)
- `axi_apb_env.sv` - Top-level environment
- `axi_apb_scoreboard.sv` - Transaction comparison

### Tests (`verification/tests/`)
- Base test class with common functionality
- Specialized tests for different scenarios
- Sequences for directed and random testing

## Coverage Analysis

### Functional Coverage Groups

1. **Write Address Coverage**
   - Address ranges (low, mid, high)
   - Protection types
   - Cross-combinations

2. **Read Address Coverage**
   - Address ranges
   - Protection types

3. **Data Coverage**
   - Zero data patterns
   - All-ones patterns
   - Random patterns
   - Byte enable combinations

4. **Protocol Coverage**
   - Response types (OKAY, ERROR)
   - Back-to-back transactions
   - Ready/Valid handshakes

## Troubleshooting

### Common Issues

1. **Interface not found error**
   - Ensure interfaces are in `verification/interfaces/`
   - Check `filelist.f` includes all required files

2. **Compilation failures**
   - Verify SystemVerilog syntax
   - Check tool-specific compilation options

3. **Simulation timeout**
   - Reduce number of transactions in stress tests
   - Check for deadlocks in DUT

## Documentation

- **Verification Plan**: `docs/VERIFICATION_PLAN.md`
- **UVM Architecture**: `docs/UVM_ARCHITECTURE.md` (to be created)
- **Test Plan**: `docs/TEST_PLAN.md` (to be created)

## Contributing

1. Follow UVM coding guidelines
2. Maintain directory structure
3. Add coverage for new features
4. Update documentation

## Support

- UVM Documentation: [Accellera UVM](https://www.accellera.org/activities/vip)
- SystemVerilog: [IEEE 1800-2017](https://standards.ieee.org/)

## License

This project is provided as-is for educational and verification purposes.

---

**Project Status**: 🔄 In Active Development

**Last Updated**: June 5, 2026

**Maintainer**: @srikanthjhn5
