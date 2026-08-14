# Verilog HDL — RTL & FPGA Design Journey

A hands-on collection of **Verilog HDL**, **RTL design**, **digital verification**, and **FPGA** projects built while learning digital design and hardware design.

The repository progresses from fundamental combinational circuits to arithmetic units, sequential logic, and FPGA implementations. The goal is to build practical RTL skills step by step.

## 🛠️ Tools

- Verilog HDL
- Icarus Verilog
- GTKWave
- Visual Studio Code
- Quartus II Web Edition
- Git & GitHub

## 📂 Current Projects

| Category | Projects |
|---|---|
| Combinational Logic | Half Adder, Full Adder, Half Subtractor, Full Subtractor, Multiplexer, Demultiplexer |
| Arithmetic | Ripple Carry Adder, Ripple Carry Subtractor, Carry Look-Ahead Adder, Multiplier, 4-bit ALU, 8-bit Adder |
| Sequential Logic | Flip-Flops, Registers, Universal Register |
| FPGA | 8-bit Adder implementation on FPGA |

## 🧪 Verification Approach

Projects are developed with a focus on:

- RTL implementation
- Dedicated testbenches
- Functional simulation
- VCD waveform generation
- GTKWave waveform inspection
- Multiple Verilog modelling styles where appropriate
- FPGA-oriented RTL design

Example project structure:

```text
HalfAdder/
├── halfadder_behavioural.v
├── halfadder_dataflow.v
├── halfadder_gatelevel.v
├── tb_halfadder.v
└── Half Adder Wave.png
```

## 🗺️ Learning Roadmap

### Phase 1 — Combinational Logic

- [x] Half Adder
- [x] Full Adder
- [x] Half Subtractor
- [x] Full Subtractor
- [x] Multiplexer
- [x] Demultiplexer
- [ ] Encoder
- [ ] Priority Encoder
- [ ] Decoder
- [ ] Comparator
- [ ] Parity Generator & Checker

### Phase 2 — Arithmetic RTL

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

### Phase 3 — Sequential Logic

- [x] Flip-Flops
- [x] Registers
- [x] Universal Register
- [ ] Shift Registers
- [ ] Ring Counter
- [ ] Johnson Counter
- [ ] Synchronous Counter
- [ ] Asynchronous Counter

### Phase 4 — Finite State Machines

- [ ] Sequence Detector
- [ ] Traffic Light Controller
- [ ] Vending Machine
- [ ] Elevator Controller
- [ ] Digital Lock

### Phase 5 — RTL Building Blocks & Protocols

- [ ] UART
- [ ] SPI
- [ ] I²C
- [ ] PWM Generator
- [ ] FIFO
- [ ] RAM
- [ ] ROM

### Phase 6 — Processor Components

- [ ] Register File
- [ ] Program Counter
- [ ] Instruction Decoder
- [ ] Control Unit
- [ ] ALU Control
- [ ] Data Memory
- [ ] Instruction Memory
- [ ] Pipeline Registers

### Phase 7 — Processor Design

- [ ] Single-Cycle CPU
- [ ] Multi-Cycle CPU
- [ ] 5-Stage Pipelined RISC-V Processor

### Phase 8 — FPGA Projects

- [x] 8-bit Adder on FPGA
- [ ] LED Controller
- [ ] Seven-Segment Display Driver
- [ ] Digital Clock
- [ ] Stopwatch
- [ ] UART on FPGA
- [ ] VGA Controller
- [ ] FPGA Calculator

## ▶️ Simulation

A typical Icarus Verilog simulation flow is:

```bash
iverilog -o output *.v
vvp output
gtkwave *.vcd
```

For individual projects, compile the required RTL and testbench files together.

## 🎯 Goal

Build a strong practical foundation in:

- RTL Design
- Verilog HDL
- Digital Design
- Functional Verification
- FPGA Development
- Computer Architecture
- ASIC Frontend Design
- RISC-V Processor Design

This repository is a record of the progression from **basic digital circuits → RTL systems → processor design → FPGA implementation**.

⭐ If you find the projects useful, feel free to explore the repository or give it a star.
