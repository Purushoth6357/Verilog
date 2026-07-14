# Verilog HDL 🚀

A collection of Verilog HDL implementations of fundamental digital logic circuits, written using multiple modeling styles.

## ✨ Features

- Gate Level Modeling
- Dataflow Modeling
- Behavioral Modeling
- Testbenches
- GTKWave Simulation

## 🛠 Tools

- VS Code
- Icarus Verilog
- GTKWave
- Quartus II (FPGA Synthesis)

---

## 📂 Projects

### Combinational Circuits

| Project | Gate | Dataflow | Behavioral | Testbench |
|---------|:----:|:--------:|:----------:|:---------:|
| Half Adder | ✅ | ✅ | ✅ | ✅ |
| Full Adder | ✅ | ✅ | ✅ | ✅ |
| Half Subtractor | ⏳ | ⏳ | ⏳ | ⏳ |
| Full Subtractor | ⏳ | ⏳ | ⏳ | ⏳ |
| Multiplexer | ⏳ | ⏳ | ⏳ | ⏳ |
| Demultiplexer | ⏳ | ⏳ | ⏳ | ⏳ |
| Encoder | ⏳ | ⏳ | ⏳ | ⏳ |
| Decoder | ⏳ | ⏳ | ⏳ | ⏳ |
| Comparator | ⏳ | ⏳ | ⏳ | ⏳ |

---

## 📁 Repository Structure

```
Verilog
│
├── HalfAdder
│   ├── halfadder_gatelevel.v
│   ├── halfadder_dataflow.v
│   ├── halfadder_behavioural.v
│   └── tb_halfadder.v
│
├── FullAdder
│   ├── fulladder_gatelevel.v
│   ├── fulladder_dataflow.v
│   ├── fulladder_behavioural.v
│   └── tb_fulladder.v
│
├── README.md
└── .gitignore
```

---

## ▶️ Simulation

Compile:

```bash
iverilog -o output HalfAdder/*.v
```

Run:

```bash
vvp output
```

Open waveform:

```bash
gtkwave halfadder.vcd
```

---

## 🎯 Learning Goals

This repository is part of my journey into:

- Digital System Design
- RTL Design
- FPGA Development
- VLSI Frontend
- RISC-V Processor Design

---

⭐ Feel free to explore the implementations and simulations.