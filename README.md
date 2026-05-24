# UART Transmitter — Basys3 (Artix-7)

A simple 8-bit UART transmitter implemented in Verilog and deployed on the **Digilent Basys3 FPGA board**.  
Set 8 switches to an ASCII byte, press the centre button, and the character appears in any serial terminal.

---

## Project Structure

```
uart_tx/
├── Top_module.v          # Top-level: wires Debounce + Transmitter
├── Transmitter.v         # UART TX state machine (9600 baud, 8N1)
├── Debounce_Signals.v    # Button synchroniser + one-pulse generator
├── constraints.xdc       # Pin assignments for Basys3
└── README.md
```

---

## Hardware

| Item | Detail |
|---|---|
| Board | Digilent Basys3 |
| FPGA | Xilinx Artix-7 `xc7a35tcpg236-1` |
| Clock | 100 MHz on-board oscillator |
| UART baud rate | 9600 baud |
| Frame format | 8N1 (8 data bits, No parity, 1 stop bit) |
| TX pin | `A18` (USB-UART bridge on Basys3) |

---

## Pin Assignments

| Signal | Package Pin | Description |
|---|---|---|
| `clk` | W5 | 100 MHz system clock |
| `data[0]` | V17 | Switch SW0 (LSB) |
| `data[1]` | V16 | Switch SW1 |
| `data[2]` | W16 | Switch SW2 |
| `data[3]` | W17 | Switch SW3 |
| `data[4]` | W15 | Switch SW4 |
| `data[5]` | V15 | Switch SW5 |
| `data[6]` | W14 | Switch SW6 |
| `data[7]` | W13 | Switch SW7 (MSB) |
| `btn` | U18 | Centre button (BTNC) |
| `TxD` | A18 | UART TX out |

---

## Module Descriptions

### `Top_module`
Top-level wrapper. Connects `Debounce_Signals` output to `Transmitter` input.  
The `reset` pin of the transmitter is tied permanently low (`1'b0`).

### `Transmitter`
Two-state FSM (`IDLE` → `SEND` → `IDLE`).

- Waits in `IDLE` with `TxD = 1` (line idle high).
- On a `transmit` pulse, loads the 10-bit frame `{stop, data[7:0], start}` = `{1, data, 0}`.
- Shifts out LSB-first at 9600 baud using a 14-bit baud counter.
- Baud counter period: `10416` cycles @ 100 MHz = 9600.6 baud (0.006% error).
- Returns to `IDLE` after all 10 bits are sent.

### `Debounce_Signals`
- **Two-FF synchroniser** eliminates metastability from the physical button.
- **Debounce counter** requires the button to stay high for `100 000` clock cycles (~1 ms) before triggering.
- **One-pulse generator** ensures exactly one clock-wide `transmit` pulse per button press, regardless of how long it is held.

---

## How to Use

### 1. Load the Design
1. Open **Vivado** and create a new RTL project targeting `xc7a35tcpg236-1`.
2. Add `Top_module.v`, `Transmitter.v`, `Debounce_Signals.v` as design sources.
3. Add `constraints.xdc` as a constraint source.
4. Right-click `Top_module` in the Sources panel → **Set as Top**.

### 2. Build
1. Run **Synthesis** → Run **Implementation** → **Generate Bitstream**.
2. Open **Hardware Manager** → **Auto Connect** → **Program Device**.

### 3. Open a Serial Terminal

| Setting | Value |
|---|---|
| Port | Basys3 COM port (check Device Manager) |
| Baud rate | 9600 |
| Data bits | 8 |
| Stop bits | 1 |
| Parity | None |
| Flow control | None |

Recommended tools: PuTTY, Tera Term, Arduino Serial Monitor.

### 4. Transmit a Character
1. Set switches `SW[7:0]` to the binary value of your ASCII character.
2. Press the **centre button (BTNC)**.
3. The character appears in the serial terminal.

**Example — send the letter `A` (ASCII 65 = `0x41`)**

```
SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
 0   1   0   0   0   0   0   1
```

---

## UART Frame Format

```
Idle  Start  D0  D1  D2  D3  D4  D5  D6  D7  Stop  Idle
  1     0    b0  b1  b2  b3  b4  b5  b6  b7    1     1
        |<----------- 10 bits @ 9600 baud ----------->|
```

Each bit lasts `1 / 9600 ≈ 104.2 µs` → full frame ≈ **1.04 ms**.

---

## Known Warnings (Non-Critical)

| Warning ID | Message | Fix |
|---|---|---|
| `DRC CFGBVS-1` | Missing CFGBVS / CONFIG_VOLTAGE | Add two lines to `.xdc` (see below) |

Add to the top of `constraints.xdc` to suppress:
```tcl
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
```

---

## Tools & Version

| Tool | Version |
|---|---|
| Xilinx Vivado | 2020.x or later |
| Target device | xc7a35tcpg236-1 |
| HDL | Verilog (IEEE 1364-2001) |

---

## License

This project is released for educational use. Free to use, modify, and distribute.
