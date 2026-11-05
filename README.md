# Verilog HDL — RTL Design & Digital Systems

<p align="center">
  <strong>Learning digital hardware by designing, simulating, debugging, and implementing RTL.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-blue?style=flat-square" alt="Verilog and SystemVerilog">
  <img src="https://img.shields.io/badge/Focus-RTL%20Design-6f42c1?style=flat-square" alt="RTL Design">
  <img src="https://img.shields.io/badge/Simulation-Icarus%20Verilog-orange?style=flat-square" alt="Icarus Verilog">
  <img src="https://img.shields.io/badge/Verification-Verilator-2ea44f?style=flat-square" alt="Verilator">
  <img src="https://img.shields.io/badge/Waveforms-GTKWave-blue?style=flat-square" alt="GTKWave">
</p>

---

## About This Repository

This repository is a hands-on collection of **Verilog HDL and SystemVerilog projects** covering digital logic, arithmetic datapaths, sequential circuits, finite-state machines, RTL interfaces, and FPGA-oriented designs.

The work progresses from small logic blocks to larger architectures such as FIFOs, a UART receiver, and an FPGA image-processing accelerator. Each project is organised in its own directory and may include RTL source files, testbenches, simulation output, or hardware implementation evidence.

The goal is to build practical skills in:

- Writing synthesizable RTL and understanding the hardware it describes.
- Breaking designs into reusable modules.
- Creating testbenches and checking functional behaviour.
- Debugging simulations with waveform viewers.
- Understanding timing, reset behaviour, and clock-domain crossing.
- Preparing RTL for FPGA synthesis and implementation.

## Repository Contents

### Combinational Logic

| Project | Description |
|---|---|
| [Half Adder](./HalfAdder) | One-bit binary addition |
| [Full Adder](./FullAdder) | One-bit addition with carry-in |
| [Half Subtractor](./HalfSubractor) | One-bit subtraction |
| [Full Subtractor](./FullSubtractor) | One-bit subtraction with borrow-in |
| [Multiplexers](./Multiplexers) | Data selection logic |
| [Demultiplexers](./Demultiplexers) | Data distribution logic |

### Arithmetic and Datapath Design

| Project | Description |
|---|---|
| [8-bit Adder](./8%20bit%20Adder) | Eight-bit binary addition |
| [Ripple Carry Adder](./RippleCarryAdder) | Cascaded full-adder architecture |
| [Ripple Carry Subtractor](./RippleCarrySubtractor) | Multi-bit subtraction |
| [Carry Look-Ahead Adder](./CLA) | Carry computation using generate/propagate logic |
| [Multiplier](./Multiplier) | RTL multiplier design |
| [4-bit ALU](./4BitALU) | Arithmetic and logic operations in one datapath |

### Sequential Logic and Control

| Project | Description |
|---|---|
| [Flip-Flops](./FlipFlops) | Sequential storage elements |
| [Registers](./Registers) | Multi-bit storage |
| [Traffic Light Controller](./TrafficLight) | FSM-based traffic signal control |

### FIFO Architectures

| Project | Description |
|---|---|
| [Synchronous FIFO](./FIFO) | FIFO with a common read/write clock |
| [Asynchronous FIFO](./Asynchronous%20FIFO) | Dual-clock FIFO with pointer synchronization |

### Communication and Image Processing

| Project | Description |
|---|---|
| [UART Receiver](./UART/UART%20receiver) | Serial data reception with a SystemVerilog testbench |
| [FPGA Image Processing Accelerator](./ImageProcessingAccelerator) | Image processing RTL with image ROM and VGA output |

---

## Featured Projects

### 1. Asynchronous FIFO

[View project source](./Asynchronous%20FIFO)

A modular dual-clock FIFO design exploring clock-domain crossing (CDC).

**Design blocks include:**
- FIFO memory.
- Write-pointer and read-pointer handlers.
- Binary-to-Gray pointer conversion.
- Pointer synchronizer stages.
- Full and empty status generation.
- SystemVerilog testbench.

**Concepts explored:** independent clock domains, Gray coding, pointer wrap-around, synchronization, and FIFO status logic.

### 2. UART Receiver

[View UART Receiver](./UART/UART%20receiver)

A UART receiver implemented in Verilog HDL, accompanied by a SystemVerilog testbench.

- RTL module: `uart_receiver.v`
- Testbench: `tb_uart_receiver.sv`

The testbench is intended to exercise serial reception and inspect the received data and receiver behaviour in simulation.

### 3. FPGA Image Processing Accelerator

[View project source](./ImageProcessingAccelerator)

An FPGA-oriented image-processing design written in Verilog HDL.

**Main RTL files:**
- `image_processor_top.v` — top-level integration.
- `image_processor_core.v` — image-processing core.
- `image_rom_rgb.v` — source image ROM interface.
- `vga_controller.v` — VGA timing and display interface.

The current core is configured for a **64 × 48** image (3,072 pixels), with a four-bit processing-mode input. The display interface generates VGA output. The source image is loaded using `$readmemh`; place the required `image.hex` file in the simulator or Quartus project working directory before running the design.

The design explores image storage, pixel processing, line buffers for neighbourhood operations, filter selection, and display timing.

> The repository contains the RTL source. Check the project files and hardware setup before assuming a particular board configuration or a live-camera input.

---

## Tools and Technologies

| Tool / Language | Use |
|---|---|
| Verilog HDL | RTL design |
| SystemVerilog | Testbench development |
| Icarus Verilog | RTL compilation and simulation |
| Verilator | Linting and simulation workflows |
| GTKWave | VCD waveform inspection |
| ModelSim | HDL simulation where configured |
| Intel Quartus II | Synthesis and FPGA implementation for Altera devices |
| AMD/Xilinx Vivado | FPGA design exploration |
| Visual Studio Code | RTL editing |
| Git and GitHub | Version control and project hosting |

Tool usage varies by project. Not every design has been implemented on physical FPGA hardware.

## Running Simulations

### Verilog testbench with Icarus Verilog

From the relevant project directory:

```bash
iverilog -g2012 -o sim <design_file>.v <testbench_file>.v
vvp sim
```

For a testbench that writes a VCD file:

```bash
gtkwave dump.vcd
```

Add waveform dumping to the testbench:

```verilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
end
```

Replace `tb_top` and the filenames with the actual testbench module and source files.

### SystemVerilog testbench

Use the SystemVerilog flag when compiling a `.sv` testbench:

```bash
iverilog -g2012 -o sim <design_file>.v <testbench_file>.sv
vvp sim
```

### UART receiver with Verilator

From `UART/UART receiver`, a waveform-enabled build can be run with:

```bash
verilator --binary --sv --timing --trace --Wall \
  --top-module tb_uart_receiver \
  uart_receiver.v tb_uart_receiver.sv
end
```

Run the generated executable from the build directory created by Verilator, then open the generated VCD file with GTKWave. Check your Verilator version and build output if the executable or waveform filename differs.

## Verification Workflow

For each design, the intended workflow is:

1. Understand the specification and expected behaviour.
2. Implement the RTL using a suitable modelling style.
3. Develop a testbench with meaningful input sequences.
4. Cover normal operation, boundary conditions, and corner cases.
5. Inspect waveforms and simulation output.
6. Fix mismatches and repeat the tests.
7. For FPGA-targeted designs, run synthesis and review implementation reports.

Simulation demonstrates behaviour for the applied test cases; it does not by itself prove exhaustive correctness or successful hardware implementation.

## Skills Being Developed

- **Combinational RTL:** Boolean logic, arithmetic circuits, multiplexing.
- **Sequential RTL:** registers, flip-flops, counters, and state machines.
- **Datapath architecture:** adders, multipliers, and ALUs.
- **Memory interfaces:** FIFO storage, read/write pointers, and status flags.
- **Clock-domain crossing:** Gray-coded pointers and synchronizer structures.
- **Serial communication:** UART receiver design and testbench development.
- **Image processing hardware:** ROM-based image input, pixel operations, line buffers, and VGA display.
- **Design verification:** stimulus generation, waveform analysis, and debugging.
- **FPGA flow:** synthesis, pin assignment, and hardware-oriented implementation.

## What's Next

Areas for continued development include:

- More systematic self-checking testbenches and assertions.
- Additional UART verification scenarios and transmitter integration.
- Deeper asynchronous FIFO corner-case and CDC verification.
- Parameterized RTL blocks and reusable design libraries.
- RAM/ROM inference and memory architecture experiments.
- Processor datapaths and a small RISC-V implementation.
- More FPGA implementations with documented timing and resource reports.

## Feedback

Suggestions, bug reports, and constructive feedback are welcome. Feel free to explore the project folders and follow the RTL, testbench, and simulation evidence available for each design.

<p align="center">
  <strong>Understand the logic. Design the hardware. Verify the behaviour.</strong>
</p>
