# Verilog HDL — RTL Design, IP Integration & Verification

<p align="center">
  <strong>Learning digital hardware by designing RTL, building reusable IP, writing testbenches, and debugging waveforms.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog%20%7C%20SystemVerilog-blue?style=flat-square" alt="Verilog and SystemVerilog">
  <img src="https://img.shields.io/badge/Focus-RTL%20Design-6f42c1?style=flat-square" alt="RTL design">
  <img src="https://img.shields.io/badge/Verification-Icarus%20%7C%20Verilator-2ea44f?style=flat-square" alt="Verification tools">
  <img src="https://img.shields.io/badge/Waveforms-GTKWave-orange?style=flat-square" alt="GTKWave">
  <img src="https://img.shields.io/badge/FPGA-Quartus%20%7C%20Vivado-informational?style=flat-square" alt="FPGA tools">
</p>

---

## About

This repository contains hands-on **Verilog HDL and SystemVerilog RTL designs** developed while learning digital design, computer architecture, on-chip interfaces, and design verification.

The projects progress from basic combinational logic to datapaths, sequential circuits, FIFO architectures, serial communication blocks, bus-connected peripherals, and FPGA-oriented image processing.

The focus is practical RTL engineering:

- Translating a hardware specification into synthesizable RTL.
- Structuring designs into clear, reusable modules.
- Developing directed, boundary, corner-case, and randomized test sequences.
- Checking expected behaviour with testbench scoreboards and logs.
- Debugging timing and control behaviour using GTKWave.
- Exploring FPGA synthesis and implementation workflows.

## Repository Map

### 1. Combinational Logic

| Design | What it covers |
|---|---|
| [Half Adder](./HalfAdder) | One-bit addition |
| [Full Adder](./FullAdder) | Addition with carry-in; behavioural, dataflow, and gate-level styles |
| [Half Subtractor](./HalfSubractor) | One-bit subtraction |
| [Full Subtractor](./FullSubtractor) | Subtraction with borrow-in |
| [Multiplexers](./Multiplexers) | Combinational data selection |
| [Demultiplexers](./Demultiplexers) | Combinational data distribution |

### 2. Arithmetic Datapaths

| Design | What it covers |
|---|---|
| [8-bit Adder](./8%20bit%20Adder) | Multi-bit binary addition and FPGA implementation evidence |
| [Ripple Carry Adder](./RippleCarryAdder) | Cascaded carry propagation |
| [Ripple Carry Subtractor](./RippleCarrySubtractor) | Multi-bit subtraction |
| [Carry Look-Ahead Adder](./CLA) | Generate/propagate carry logic |
| [Multiplier](./Multiplier) | RTL multiplier design |
| [4-bit ALU](./4BitALU) | Combined arithmetic and logic operations |

### 3. Sequential Logic and Control

| Design | What it covers |
|---|---|
| [Flip-Flops](./FlipFlops) | Sequential storage elements |
| [Registers](./Registers) | Multi-bit storage |
| [Traffic Light Controller](./TrafficLight) | FSM-based controller |

### 4. FIFO and Memory-Oriented Designs

| Design | What it covers |
|---|---|
| [Synchronous FIFO](./FIFO) | Common-clock FIFO, pointer and occupancy behaviour |
| [Asynchronous FIFO](./Asynchronous%20FIFO) | Independent read/write clocks, Gray-coded pointers, synchronizer stages, and full/empty logic |

### 5. Serial Communication

| Design | What it covers |
|---|---|
| [UART Receiver](./UART/UART%20receiver) | UART serial reception and SystemVerilog testbench |
| [UART Transmitter](./UART/UART%20Transmitter) | Parameterized baud timing, FSM-based framing, LSB-first transmission, and SystemVerilog verification |

### 6. Bus-Based IP and Peripherals

| Design | What it covers |
|---|---|
| [APB Timer](./Bus-Based%20protocol%20peripheral/APB%20Timer) | APB3 memory-mapped timer peripheral with register read/write access, countdown logic, status, and error response |

### 7. FPGA-Oriented Image Processing

| Design | What it covers |
|---|---|
| [Image Processing Accelerator](./ImageProcessingAccelerator) | ROM-based image input, pixel-processing core, line-buffer-based operations, and VGA display interface |

---

## Featured RTL Projects

### APB3 Timer Peripheral

[Explore the APB Timer source and testbench](./Bus-Based%20protocol%20peripheral/APB%20Timer)

A memory-mapped timer peripheral using an **APB3-style slave interface**.

**Register map**

| Address | Register | Access | Function |
|---|---|---|---|
| `0x00` | LOAD | Read / Write | Holds the timer reload value |
| `0x04` | CTRL | Read / Write | Starts, restarts, or stops the timer |
| `0x08` | COUNT | Read only | Returns the current countdown value |
| `0x0C` | STATUS | Read only | Reports timer completion |

**Interface signals:** `PCLK`, `PRESETn`, `PSEL`, `PENABLE`, `PWRITE`, `PADDR`, `PWDATA`, `PRDATA`, `PREADY`, and `PSLVERR`.

The current RTL is parameterized by counter width and implements a zero-wait-state response. The supplied SystemVerilog testbench exercises APB transactions and timer behaviour. See the project directory for the complete test sequence and simulation log.

### UART Transmitter

[Explore the UART Transmitter source and testbench](./UART/UART%20Transmitter)

A parameterized UART TX block that serializes an 8-bit input using a finite-state machine.

- Configurable `CLKS_PER_BIT` timing parameter.
- Idle, start, data, and stop states.
- LSB-first data transmission.
- Active-low asynchronous reset.
- `busy` indication during frame transmission.
- SystemVerilog testbench with bit-level checks and waveform generation.

The transmitter uses a default `CLKS_PER_BIT` value of 217. Choose the parameter to match the system clock and target baud rate:

`CLKS_PER_BIT = clock_frequency / baud_rate`

The testbench source documents the stimulus and checking approach. Run it with the instructions below and inspect the generated waveform for exact timing.

### Asynchronous FIFO

[Explore the Asynchronous FIFO](./Asynchronous%20FIFO)

A dual-clock FIFO architecture covering clock-domain crossing concepts.

- FIFO memory.
- Independent read and write pointer handlers.
- Binary-to-Gray pointer conversion.
- Synchronizer stages between clock domains.
- Full and empty status generation.
- SystemVerilog testbench.

Key concepts include pointer wrap-around, Gray coding, synchronization latency, and safe status generation across asynchronous clock domains.

### FPGA Image Processing Accelerator

[Explore the Image Processing Accelerator](./ImageProcessingAccelerator)

An FPGA-oriented image processing datapath with a ROM-based image source and VGA output path. The current design is configured around a **64 × 48** source image and selectable processing modes.

The source includes a top-level integration module, processing core, RGB image ROM, and VGA controller. The image data is loaded with `$readmemh`; make sure the required memory file is available in the simulator or FPGA project working directory.

---

## Tools and Technologies

| Tool / Language | Usage |
|---|---|
| Verilog HDL | Synthesizable RTL design |
| SystemVerilog | Testbench development and verification stimulus |
| Icarus Verilog | RTL compilation and simulation |
| Verilator | Linting and compiled simulation |
| GTKWave | VCD waveform inspection |
| ModelSim | HDL simulation where configured |
| Intel Quartus II | Intel FPGA synthesis and implementation |
| AMD/Xilinx Vivado | FPGA design exploration |
| VS Code | RTL editing |
| Git and GitHub | Version control |

Not every project has been synthesized or tested on physical hardware. Refer to each project directory for its available simulation and implementation evidence.

## Running Simulations

Run commands from the relevant project directory and replace filenames with the files used by that design.

### Icarus Verilog

For a Verilog design and testbench:

```bash
iverilog -g2012 -o sim <design_file>.v <testbench_file>.v
vvp sim
```

For a SystemVerilog testbench:

```bash
iverilog -g2012 -s <testbench_module> -o sim <design_file>.v <testbench_file>.sv
vvp sim
```

If the testbench creates a VCD file:

```bash
gtkwave <waveform_file>.vcd
```

A typical waveform dump block is:

```systemverilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
end
```

### UART Transmitter — Icarus Verilog

From `UART/UART Transmitter`:

```bash
iverilog -g2012 -s tb_uart_transmitter -o sim \
  uart_transmitter.v tb_uart_transmitter.sv
vvp sim
gtkwave uart_transmitter.vcd
```

### APB Timer — Icarus Verilog

From `Bus-Based protocol peripheral/APB Timer`:

```bash
iverilog -g2012 -s tb_apb_timer -o sim \
  apb_timer.v tb_apb_timer.sv
vvp sim
gtkwave apb_timer.vcd
```

### Verilator

For a timing-enabled SystemVerilog testbench with tracing enabled:

```bash
verilator --binary --sv --timing --trace --Wall \
  --top-module <testbench_module> \
  <design_file>.v <testbench_file>.sv
```

Run the generated executable from the build directory (usually `obj_dir/`) and open the VCD file emitted by the testbench in GTKWave. Check the build output and Verilator version if generated filenames differ.

## Verification Approach

The testbenches in this repository use different levels of checking depending on the project. A useful verification progression is:

1. **Reset checks:** confirm known initial values and idle outputs.
2. **Normal transactions:** exercise expected functional behaviour.
3. **Boundary cases:** test zero, maximum values, and counter or pointer limits.
4. **Protocol timing:** check setup/access sequencing, bit periods, and handshakes.
5. **Error cases:** exercise invalid addresses or unsupported operations where applicable.
6. **Randomized stimulus:** broaden input combinations beyond directed tests.
7. **Waveform inspection:** correlate signal transitions with the expected cycle-level behaviour.

A passing simulation only establishes that the applied test cases passed. It does not establish exhaustive correctness, timing closure, CDC sign-off, or successful FPGA hardware validation.

## Engineering Topics

- Combinational and sequential RTL modelling.
- Arithmetic datapath design and control logic.
- FSM design and implementation.
- Synchronous and asynchronous FIFO architecture.
- Clock-domain crossing and Gray-coded pointer synchronization.
- UART framing, baud-rate timing, and serial interfaces.
- APB3 peripheral register maps and bus transactions.
- Testbench architecture, scoreboards, directed tests, and randomized stimulus.
- Waveform-based debugging.
- FPGA synthesis and implementation flows.

## Planned Extensions

- UART receiver/transmitter integration and loopback verification.
- More reusable bus-functional tasks and self-checking SystemVerilog testbenches.
- Assertions and functional coverage for protocol and FIFO corner cases.
- Parameterized reusable RTL IP blocks.
- Additional bus-connected peripherals and register interfaces.
- More FPGA implementation reports with timing and resource data.

## Feedback

Suggestions, bug reports, and constructive feedback are welcome. Explore the project directories to see each module's RTL, testbench, waveform, and implementation artifacts.

<p align="center">
  <strong>Design the RTL. Verify the behaviour. Understand the hardware.</strong>
</p>
