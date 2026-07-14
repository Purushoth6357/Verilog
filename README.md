# Verilog HDL 🚀

A collection of Verilog HDL implementations of digital logic circuits using **Gate-Level**, **Dataflow**, and **Behavioral** modeling styles. Each project includes a dedicated testbench and waveform simulation.

---

## 📚 Contents

- Combinational Circuits
- Sequential Circuits *(Coming Soon)*
- RTL Design Projects *(Coming Soon)*

---

## ✨ Features

- ✅ Gate-Level Modeling
- ✅ Dataflow Modeling
- ✅ Behavioral Modeling
- ✅ Testbenches
- ✅ GTKWave Simulation
- ✅ FPGA Compatible Designs (Quartus II)

---

## 🛠️ Tools Used

- Visual Studio Code
- Icarus Verilog
- GTKWave
- Quartus II Web Edition

---

# 📂 Projects

## Combinational Circuits

| Project | Gate | Dataflow | Behavioral | Testbench | Waveform |
|---------|:----:|:--------:|:----------:|:---------:|:--------:|
| Half Adder | ✅ | ✅ | ✅ | ✅ | ✅ |
| Full Adder | ✅ | ✅ | ✅ | ✅ | ✅ |
| Half Subtractor | ✅ | ✅ | ✅ | ✅ | ✅ |
| Full Subtractor | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Multiplexer | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Demultiplexer | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Encoder | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Decoder | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Comparator | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |

---

## 📁 Repository Structure

```text
Verilog-HDL
│
├── HalfAdder
│   ├── halfadder_gatelevel.v
│   ├── halfadder_dataflow.v
│   ├── halfadder_behavioural.v
│   ├── tb_halfadder.v
│   └── Half Adder Wave.png
│
├── FullAdder
│   ├── fulladder_gatelevel.v
│   ├── fulladder_dataflow.v
│   ├── fulladder_behavioural.v
│   ├── tb_fulladder.v
│   └── Full Adder Wave.png
│
├── HalfSubtractor
│   ├── halfsubtractor_gatelevel.v
│   ├── halfsubtractor_dataflow.v
│   ├── halfsubtractor_behavioural.v
│   ├── tb_halfsubtractor.v
│   └── HalfSubtractor.png
│
├── README.md
└── .gitignore
```

---

## ▶️ Simulation

Compile

```bash
iverilog -o output *.v
```

Run

```bash
vvp output
```

View waveform

```bash
gtkwave *.vcd
```

---

## 🎯 Learning Roadmap

### ✅ Completed

- Half Adder
- Full Adder
- Half Subtractor

### 🚧 In Progress

- Full Subtractor

### 📌 Upcoming

- Multiplexer
- Demultiplexer
- Encoder
- Decoder
- Comparator
- Ripple Carry Adder
- Carry Look Ahead Adder
- ALU
- Flip-Flops
- Registers
- Counters
- Shift Registers
- Finite State Machines (FSM)
- UART
- SPI
- I2C
- RISC-V Components

---

## 🎯 Goals

This repository documents my learning journey in:

- Digital System Design
- RTL Design
- FPGA Development
- VLSI Frontend
- ASIC Design Flow
- RISC-V Processor Design

---

⭐ **If you find this repository useful, consider giving it a star!**