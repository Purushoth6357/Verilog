# Verilog HDL | RTL Design & Digital Systems

<p align="center">
  <strong>A hands-on journey through digital logic, RTL design, simulation, and FPGA development.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-blue?style=flat-square&logo=verilog" alt="Verilog">
  <img src="https://img.shields.io/badge/Focus-RTL%20Design-6f42c1?style=flat-square" alt="RTL Design">
  <img src="https://img.shields.io/badge/Simulation-Icarus%20Verilog-orange?style=flat-square" alt="Icarus Verilog">
  <img src="https://img.shields.io/badge/Waveforms-GTKWave-2ea44f?style=flat-square" alt="GTKWave">
  <img src="https://img.shields.io/badge/Status-Actively%20Learning-brightgreen?style=flat-square" alt="Actively Learning">
</p>

---

## About

This repository documents my practical work with **Verilog HDL and digital hardware design**.

It started with basic combinational circuits and gradually expanded into arithmetic datapaths, sequential logic, and larger RTL blocks. Each project is an opportunity to understand how hardware behaves, translate logic into synthesizable RTL, and verify the design through simulation.

The emphasis is on **designing, testing, debugging, and understanding hardware** — not just writing Verilog syntax.

## Repository Map

| Area | Projects |
|---|---|
| Combinational Logic | [Half Adder](./HalfAdder), [Full Adder](./FullAdder), [Half Subtractor](./HalfSubractor), [Full Subtractor](./FullSubtractor), [Multiplexers](./Multiplexers), [Demultiplexers](./Demultiplexers) |
| Arithmetic Circuits | [Ripple Carry Adder](./RippleCarryAdder), [Ripple Carry Subtractor](./RippleCarrySubtractor), [Carry Look-Ahead Adder](./CLA), [Multiplier](./Multiplier), [8-bit Adder](./8%20bit%20Adder) |
| Datapath Design | [4-bit ALU](./4BitALU) |
| Sequential Logic | [Flip-Flops](./FlipFlops), [Registers](./Registers) |
| Design Exercises | [FIFO](./FIFO), [Traffic Light Controller](./TrafficLight) |

> The repository evolves as new designs, testbenches, and experiments are added. Check each project directory for its current RTL and verification files.

## Toolchain

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL description |
| Icarus Verilog | Compilation and simulation |
| GTKWave | VCD waveform analysis |
| VS Code | RTL editing |
| AMD/Xilinx Vivado | RTL simulation and FPGA design exploration |
| Intel Quartus | FPGA synthesis and implementation |
| Git & GitHub | Version control |

Not every project uses every tool. The simulator and implementation flow depend on the project.

## Simulation Workflow

A typical simulation using **Icarus Verilog**:

```bash
# Compile the design and its testbench
iverilog -g2012 -o simulation <design_files>.v <testbench>.v

# Run the simulation
vvp simulation

# View the generated waveform
gtkwave dump.vcd
```

Add waveform dumping to the testbench when needed:

```verilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench_name);
end
```

Replace the filenames and testbench module name with those used in the project.

### Verification Approach

For each design, the objective is to:

1. Define the expected hardware behavior.
2. Implement the RTL using an appropriate modelling style.
3. Create a testbench that applies meaningful input combinations.
4. Simulate normal, boundary, and corner cases.
5. Inspect waveforms and debug mismatches.
6. Check synthesizability when the design is intended for FPGA implementation.

For small combinational circuits, exhaustive input testing is practical. For larger sequential designs, verification should also cover reset behavior, state transitions, timing relationships, and corner cases.

## Learning Roadmap

This roadmap tracks the areas I am exploring. A checked item indicates that a project or implementation is present in the repository; it does not imply production-level verification or FPGA deployment.

### 01 — Combinational Logic

- [x] Half Adder
- [x] Full Adder
- [x] Half Subtractor
- [x] Full Subtractor
- [x] Multiplexer
- [x] Demultiplexer
- [ ] Encoder and Priority Encoder
- [ ] Decoder
- [ ] Magnitude Comparator
- [ ] Parity Generator and Checker

### 02 — Arithmetic Architectures

- [x] Ripple Carry Adder
- [x] Ripple Carry Subtractor
- [x] Carry Look-Ahead Adder
- [x] Multiplier
- [x] 4-bit ALU
- [x] 8-bit Adder
- [ ] Carry Select Adder
- [ ] Carry Skip Adder
- [ ] Carry Save Adder
- [ ] Parameterized ALU

### 03 — Sequential Logic

- [x] Flip-Flops
- [x] Registers
- [ ] Shift Registers
- [ ] Ring Counter
- [ ] Johnson Counter
- [ ] Synchronous Counter
- [ ] Asynchronous Counter

### 04 — Finite State Machines

- [x] Traffic Light Controller
- [ ] Sequence Detector
- [ ] Vending Machine
- [ ] Elevator Controller
- [ ] Digital Lock

### 05 — RTL Building Blocks and Interfaces

- [x] FIFO
- [ ] Single-Port RAM
- [ ] Dual-Port RAM
- [ ] ROM
- [ ] UART
- [ ] SPI
- [ ] I²C
- [ ] PWM Generator

### 06 — Computer Architecture

- [ ] Register File
- [ ] Program Counter
- [ ] Instruction Decoder
- [ ] Control Unit
- [ ] ALU Control
- [ ] Instruction and Data Memory
- [ ] Pipeline Registers
- [ ] Single-Cycle CPU
- [ ] Multi-Cycle CPU
- [ ] Pipelined RISC-V Processor

### 07 — FPGA Implementation

- [x] 8-bit Adder
- [ ] LED Controller
- [ ] Seven-Segment Display Driver
- [ ] Digital Clock
- [ ] Stopwatch
- [ ] UART on FPGA
- [ ] VGA Controller
- [ ] FPGA Calculator

## Design Principles

The concepts I aim to develop through these projects:

- **RTL thinking:** Understand the hardware structure represented by the code.
- **Modularity:** Break larger systems into reusable, independently verifiable modules.
- **Timing awareness:** Understand clocking, reset, propagation delay, and setup/hold concepts.
- **Verification:** Use testbenches to validate behavior instead of relying on visual inspection alone.
- **Synthesis awareness:** Distinguish synthesizable design logic from simulation-only constructs.
- **Architecture:** Explore trade-offs between different implementations of the same function.

## What's Next?

The next stage is to move beyond isolated circuits and focus on larger digital systems:

- Build stronger testbenches and reusable verification practices.
- Explore synchronous and asynchronous FIFO architectures.
- Solve more RTL design problems.
- Develop and simulate datapaths and control logic.
- Explore FPGA implementation using Vivado and Quartus.
- Work towards processor architecture and RISC-V RTL.

## Connect

I'm documenting my progress as I learn digital design and RTL development. Suggestions, discussions, and constructive feedback are welcome.

<p align="center">
  <strong>Understand the logic. Design the hardware. Verify the behavior.</strong>
</p>
