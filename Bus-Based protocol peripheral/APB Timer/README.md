# APB-Based Countdown Timer

A configurable countdown timer peripheral with an **AMBA APB3-compatible slave interface**, written in Verilog HDL.

This project was developed as a hands-on exercise in bus-based peripheral design and extended with a SystemVerilog testbench for functional verification.

## Features

- APB3-style SETUP and ACCESS transaction handling
- Zero-wait-state slave interface (`PREADY = 1`)
- Configurable timer counter width (`WIDTH`, default: 8 bits)
- Programmable load register
- Start, stop, and restart control
- Readable current counter and completion status
- Invalid-address and read-only-write error reporting through `PSLVERR`
- Directed and randomized test sequences

## Architecture

The APB master accesses the timer through its register interface. The timer core counts independently after a START write is accepted.

### Register map

| Address | Register | Access | Description |
|---|---|---|---|
| `0x00` | LOAD | Read/Write | Timer reload value |
| `0x04` | CTRL | Read/Write | Bit 0: 1 = start/restart, 0 = stop |
| `0x08` | COUNT | Read-only | Current countdown value |
| `0x0C` | STATUS | Read-only | Bit 0: timer completion flag |

### Timer behaviour

1. Write the desired countdown value to LOAD.
2. Write `1` to CTRL to load COUNT and start the timer.
3. COUNT decrements on each PCLK edge while the timer is running.
4. When COUNT reaches zero, the timer stops and STATUS bit 0 (`timer_done`) is asserted.
5. Write `0` to CTRL to stop early. The current count is retained.
6. A new START reloads COUNT from LOAD and clears the completion flag.
7. If LOAD is zero, START completes immediately.

### APB interface signals

| Signal | Direction | Purpose |
|---|---|---|
| PCLK | Input | APB clock |
| PRESETn | Input | Active-low reset |
| PSEL | Input | Selects the peripheral |
| PENABLE | Input | Identifies the ACCESS phase |
| PWRITE | Input | 1 = write, 0 = read |
| PADDR[7:0] | Input | Register address |
| PWDATA[31:0] | Input | Write data |
| PRDATA[31:0] | Output | Read data |
| PREADY | Output | Transfer-ready indication; tied high |
| PSLVERR | Output | Invalid access indication |
| timer_done | Output | Timer completion status |

The slave completes accesses without wait states. A valid transfer is accepted during ACCESS when `PSEL && PENABLE && PREADY` is true.

## Files

- `apb_timer.v` — synthesizable timer peripheral RTL
- `tb_apb_timer.sv` — self-checking simulation testbench
- `README.md` — project documentation

## Simulation

Requirements: Icarus Verilog and GTKWave.

Run from this directory:

```bash
iverilog -g2012 -Wall -o apb_sim apb_timer.v tb_apb_timer.sv
vvp apb_sim
gtkwave apb_timer.vcd
```

The testbench generates `apb_timer.vcd` and prints a PASS/FAIL summary.

## Verification scenarios

- Reset values for all readable registers
- Normal load, start, countdown, stop, and restart operation
- Boundary load values: 0 and 1
- Maximum 8-bit load value: 255
- Randomized load and stop sequences
- Invalid register address accesses
- Writes to read-only COUNT and STATUS registers
- Timer completion and countdown timing checks

The default testbench configuration uses `WIDTH = 8`. The maximum test value of 255 is specific to that configuration.

## Tools

- Verilog HDL
- SystemVerilog
- Icarus Verilog
- GTKWave
- Linux-based open-source EDA workflow

## Learning outcomes

This project explores APB register interfaces, bus transaction phases, peripheral register mapping, sequential timer logic, reusable testbench tasks, directed/randomized testing, and waveform-based debugging.
