# Y8960 APPLICATION MANUAL

October 31, 2026

Written by Takayuki Hara (HRA!)

# Contents

- [Chapter 1 Introduction](#chapter-1-introduction)
  - [1.1 About This Manual](#11-about-this-manual)
  - [1.2 Notation](#12-notation)
  - [1.3 Overview of the Y8960](#13-overview-of-the-y8960)
  - [1.4 Block Configuration](#14-block-configuration)
  - [1.5 Main Features](#15-main-features)
- [Chapter 2 Hardware Organization](#chapter-2-hardware-organization)
  - [2.1 Cartridge Configuration](#21-cartridge-configuration)
  - [2.2 SerialSRAM Organization](#22-serialsram-organization)
  - [2.3 Behavior at Power-On](#23-behavior-at-power-on)
  - [2.4 Audio Output](#24-audio-output)
  - [2.5 Clock and Reset](#25-clock-and-reset)
- [Chapter 3 I/O Map and Memory Map](#chapter-3-io-map-and-memory-map)
  - [3.1 Overview of Access Methods](#31-overview-of-access-methods)
  - [3.2 I/O Port Map](#32-io-port-map)
  - [3.3 State at Power-On and Enabling the I/O Ports](#33-state-at-power-on-and-enabling-the-io-ports)
  - [3.4 Memory-Mapped I/O (7FF0h–7FFFh)](#34-memory-mapped-io-7ff0h7fffh)
  - [3.5 Memory Map and Bank Control](#35-memory-map-and-bank-control)
- [Chapter 4 SSG](#chapter-4-ssg)
  - [4.1 Overview](#41-overview)
  - [4.2 Access Methods](#42-access-methods)
  - [4.3 Register Map](#43-register-map)
  - [4.4 Functions of the Basic Registers](#44-functions-of-the-basic-registers)
  - [4.5 I/O Ports (GPIO)](#45-io-ports-gpio)
  - [4.6 Y8960 Extended Registers](#46-y8960-extended-registers)
  - [4.7 Usage](#47-usage)
- [Chapter 5 OPLL-EX](#chapter-5-opll-ex)
  - [5.1 Overview](#51-overview)
  - [5.2 Access Methods](#52-access-methods)
  - [5.3 Register Map](#53-register-map)
  - [5.4 Preset Instrument Banks](#54-preset-instrument-banks)
  - [5.5 Rhythm Mode](#55-rhythm-mode)
  - [5.6 Stereo Positioning (Pan)](#56-stereo-positioning-pan)
  - [5.7 Usage](#57-usage)
- [Chapter 6 OPL2 + ADPCM](#chapter-6-opl2--adpcm)
  - [6.1 Overview](#61-overview)
  - [6.2 Access Methods](#62-access-methods)
  - [6.3 Status Register](#63-status-register)
  - [6.4 FM Section Registers](#64-fm-section-registers)
  - [6.5 ADPCM Section Registers](#65-adpcm-section-registers)
  - [6.6 ADPCM Memory](#66-adpcm-memory)
  - [6.7 Pan and Volume](#67-pan-and-volume)
  - [6.8 Interrupts](#68-interrupts)
  - [6.9 Usage](#69-usage)
- [Chapter 7 SCC](#chapter-7-scc)
  - [7.1 Overview](#71-overview)
  - [7.2 How the SCC Register Bank Appears](#72-how-the-scc-register-bank-appears)
  - [7.3 Register Map](#73-register-map)
  - [7.4 Waveform Memory](#74-waveform-memory)
  - [7.5 Frequency Registers and Volume](#75-frequency-registers-and-volume)
  - [7.6 Output Switch](#76-output-switch)
  - [7.7 Stereo Positioning (Pan)](#77-stereo-positioning-pan)
  - [7.8 Mode Register](#78-mode-register)
  - [7.9 Relationship to Bank Control](#79-relationship-to-bank-control)
  - [7.10 Procedure for Producing Sound](#710-procedure-for-producing-sound)
- [Chapter 8 OPM](#chapter-8-opm)
  - [8.1 Overview](#81-overview)
  - [8.2 Access Methods](#82-access-methods)
  - [8.3 Write Queue and /WAIT](#83-write-queue-and-wait)
  - [8.4 Status Register](#84-status-register)
  - [8.5 Register Map](#85-register-map)
  - [8.6 Stereo Output (RL Bits)](#86-stereo-output-rl-bits)
  - [8.7 Timers and Interrupts](#87-timers-and-interrupts)
  - [8.8 Usage](#88-usage)
- [Chapter 9 Digital Mixer](#chapter-9-digital-mixer)
  - [9.1 Overview](#91-overview)
  - [9.2 Per-Group Volumes and the Master Volume](#92-per-group-volumes-and-the-master-volume)
  - [9.3 Saturation and Clipping](#93-saturation-and-clipping)
  - [9.4 I2S Output](#94-i2s-output)
- [Chapter 10 System Functions](#chapter-10-system-functions)
  - [10.1 System Controller](#101-system-controller)
  - [10.2 MSX-TIMER](#102-msx-timer)
  - [10.3 Reset Behavior](#103-reset-behavior)
  - [10.4 Interrupts](#104-interrupts)
  - [10.5 Notes on Use](#105-notes-on-use)
- [Index](#index)

# Chapter 1 Introduction

## 1.1 About This Manual

This manual is the programmer's manual for the **Y8960 Cartridge**, a sound cartridge for the MSX. The Y8960 is a sound source module developed as the successor to the Y8950 (MSX-AUDIO), which was widely used as a sound source for the MSX, and the Y8960 Cartridge is a development cartridge for using that Y8960 in an MSX cartridge slot.

This manual is intended for software developers who develop applications and drivers that produce music and sound effects using the Y8960, and focuses on hardware-oriented information such as register specifications and memory maps.

The supported models are MSX, MSX2, MSX2+, and MSX turbo R.

## 1.2 Notation

This manual uses the following notation.

- Hexadecimal notation for addresses and numeric values is indicated by a trailing `h` (for example, `7FF0h`). Binary numbers may be indicated by a trailing `b`.
- A division of the memory space in 8KB units is called a **BANK**, and the corresponding 8KB entity on the SerialSRAM side is called **BANK#n** (n is the bank number).
- Register read/write access is indicated in the R/W column by `RO` (read-only), `WO` (write-only), and `RW` (read/write).
- "SSG1" and "SSG2" are the names used to distinguish the two built-in SSG cores. SSG1 corresponds to register numbers 00h–0Fh, and SSG2 corresponds to 10h–1Fh.

## 1.3 Overview of the Y8960

The Y8960 is a sound source in a combo-cartridge configuration that integrates circuits equivalent to multiple sound source chips that have been used on the MSX into a single unit. As the successor to the Y8950, it inherits the conventional MSX-AUDIO compatible functions, while adding more sound sources and making all of the sound sources stereo.

Stereo support is provided in a form that allows the stereo positioning (pan) to be specified for each channel of every sound source. The output of each sound source is mixed by the digital mixer and output in stereo.

## 1.4 Block Configuration

The finalized configuration of the Y8960 is as follows.

| Block | Count | Description |
|---|---|---|
| SSG (YM2149 equivalent) | 2 | A PSG with 3 tone channels + noise + envelope. With pan for each channel. The two groups can be used independently, for example by separating them for music and for sound effects |
| OPLL-EX (YM2413 equivalent) | 1 | 9-channel FM + rhythm. With extensions for preset instrument bank switching and pan for each channel |
| OPL2 (YM3812 equivalent) | 1 | 9-channel FM + rhythm. Two built-in timers and an interrupt. With an extension for pan for each channel |
| ADPCM (ADPCM-B equivalent) | 1 | An ADPCM playback circuit controlled through the same register map as the OPL2 (Y8950 compatible). Uses 256KB of dedicated memory |
| OPM (YM2151 equivalent) | 1 | 8-channel FM. Has L/R output selection for each channel |
| SCC | 1 | Waveform memory sound source, 5 channels (A–E). Also handles MegaROM bank control. With an extension for pan for each channel |
| Digital mixer | 1 | Mixes the stereo inputs of the five groups above (SSG / OPLL / OPL2+ADPCM / SCC / OPM) and outputs them via I2S |
| MSX-TIMER | 4 cores | Timers using an index/value method. With interrupts |
| System Controller | 1 | A management circuit that provides cartridge identification and access to the Config ROM (I/O 40h–4Fh, device ID = 02h) |
| SerialSRAM | 1 | 512KB. 256KB for program/data and 256KB dedicated to ADPCM |
| SPI ROM (Config ROM) | 1 | Part of its contents are copied to SerialSRAM at power-on |

## 1.5 Main Features

- **Two SSG groups built in**: They can be used separately without interfering with each other, for example by separating them for music and for sound effects.
- **Preset instrument bank switching for OPLL-EX**: Four types of instrument ROMs are built in as the preset instruments of the OPLL — OPLL (YM2413) / OPLL-X (YM2423) / OPLL-P (YMF281) / VRC7 — and a bank can be selected for each channel (the VRC7 bank can also be selected via the bank register).
- **OPL2+ADPCM is controlled with a Y8950 (MSX-AUDIO) compatible register map**: Existing assets for MSX-AUDIO can be used.
- **All sound sources support stereo**: SSG, OPLL, OPL2, ADPCM, and SCC have pan specification for each channel, and OPM has YM2151-compatible L/R output specification. In the mixer, the volume of each group and the master volume can be adjusted.
- **Control by Memory Mapped I/O**: The normal I/O ports are disabled immediately after power-on, and are enabled for each block through the Memory Mapped I/O procedure (a mechanism based on the same concept as that of the FM-PAC, which also makes it possible to control multiple cartridges individually).
- **Four built-in MSX-TIMER cores**: Equipped with timers with interrupts, which can be used for purposes such as tempo management of music.

For details of each block, see Chapters 4 to 8; for the mixer, see Chapter 9.

# Chapter 2 Hardware Organization

## 2.1 Cartridge Configuration

The Y8960 Cartridge is an MSX cartridge that implements all of the Y8960 circuitry in an FPGA (TangPrimer25K). Internally, it consists broadly of the following elements.

- **Sound source blocks**: SSG×2, OPLL-EX, OPL2, ADPCM, OPM, SCC (see the block configuration table in Chapter 1)
- **Digital mixer**: A time-division mixer that mixes the stereo outputs of the five groups
- **Slot interface**: Conversion between the MSX slot signals and the internal bus, address decoding, and management of the I/O enable
- **SerialSRAM and its peripherals**: 512KB of serial SRAM, an arbiter that arbitrates among the three parties — the CPU (SCC bank) / ADPCM / initialization sequencer — and SCC bank control
- **SPI ROM (Config ROM)**: SPI flash that holds power-on data
- **System Controller**: A management circuit for cartridge identification and Config ROM access
- **I2S output**: A digital audio output that sends the mixer output to the outside
- **Clock generation**: Generates the internal operating clocks using a PLL and divider circuits

## 2.2 SerialSRAM Organization

The installed memory is SerialSRAM of 512KB. If it is divided into 8KB units and numbered BANK#0–BANK#63, their roles are as follows.

| BANK# | Capacity | Role |
|---|---|---|
| #0–#15 | 128KB | BIOS ROM (copied from the Config ROM at power-on) |
| #16–#31 | 128KB | RAM (for program/data) |
| #32–#63 | 256KB | RAM dedicated to ADPCM |

The SerialSRAM address space is divided into two by the most significant bit (A18): A18 = 0 is the 256KB visible from the CPU (BANK#0–BANK#31), and A18 = 1 is the 256KB dedicated to ADPCM. From the CPU, only the range BANK#0–BANK#31 is visible, through the SCC bank control (Chapter 3). The contents of the ADPCM memory are read and written through the register control of the ADPCM (Chapter 6).

Note that BANK#32–BANK#62 appear from CPU space as mirrors of BANK#0–BANK#30, and BANK#63 becomes the SCC register bank depending on conditions (Chapter 3, Section 3.5). BANK#64 and beyond are not connected.

## 2.3 Behavior at Power-On

At power-on (startup), the System Controller executes an initialization sequence.

1. It copies the **128KB located at 7E0000h–7FFFFFh of the Config ROM (SPI flash) to SerialSRAM starting at address 00000h**. This becomes the contents of the BIOS ROM in BANK#0–BANK#15.
2. While the copy is in progress, the other modules are stopped, and the MSX itself is also stopped by the /WAIT signal.
3. When the copy ends, the cartridge enters normal operation.

Also, immediately after power-on and immediately after reset, **all of the normal I/O ports of the sound source blocks are disabled**, and the cartridge does not respond to the bus. For the procedure to enable them, see Chapter 3, Section 3.3. Details of the state at reset and the recommended initialization sequence are covered in Chapter 10.

## 2.4 Audio Output

The output of each sound source is mixed by the digital mixer and output in I2S format, after **24-bit saturation processing**. The I2S configuration is 32-bit slots × 2 channels.

The sampling frequency of I2S is approximately 94.4kHz (obtained by dividing the I2S clock of approximately 24.16MHz generated by the PLL; MCLK is unused). For details, see Chapter 9, Section 9.4.

For the specifications of the mixer's group volume, pan, and master volume, see Chapter 9.

## 2.5 Clock and Reset

The internal clocks are generated by a PLL (in the implementation, a 171.8MHz system and an approximately 24.16MHz system are generated from an input clock of 28.63636MHz, and a 42.95MHz system is made by frequency division). The sound source cores are driven by generating enable signals from these clocks so that they operate at timing equivalent to that of the original chips.

When a reset is applied, all of the I/O enables return to disabled (the same state as immediately after power-on).

# Chapter 3 I/O Map and Memory Map

## 3.1 Overview of Access Methods

There are three routes for accessing the Y8960 Cartridge.

1. **Ordinary I/O ports**: A method that uses the I/O addresses assigned to each sound source block. However, immediately after power-on, all of them are disabled, and they cannot be used until they have been enabled by the Memory Mapped I/O procedure (Section 3.3).
2. **Memory Mapped I/O (MMIO)**: A window placed at memory addresses 7FF0h–7FFFh. It provides direct access to the sound source registers, enabling of the I/O ports, and mixer volume settings (Section 3.4).
3. **Memory space**: The SCC also serves as a MegaROM controller, providing bank switching for 4000h–BFFFh and access to the SCC registers (Section 3.5).

## 3.2 I/O Port Map

| I/O address | R/W | Contents |
|---|---|---|
| 40h–4Fh | RW | System Controller (Section 3.2.4) |
| 7Ch | WO | OPLL register address (MSX-MUSIC compatible) |
| 7Dh | WO | OPLL register data |
| 7Eh | WO | OPM register address |
| 7Fh | RW | OPM register data / status |
| A0h | WO | SSG register address (latch) |
| A1h | WO | SSG register data write (a read returns FFh) |
| A2h | RO | SSG register data read |
| A3h | ― | [TBC] The formal handling has not been confirmed. In the RTL, a read returns FFh and a write has no effect |
| B0h | RW | MSX-TIMER: index (bits 3–2 = core selection, bits 1–0 = register selection) |
| B1h | RW | MSX-TIMER: value of the register pointed to by the index |
| B2h | RW | MSX-TIMER: interrupt flags (cleared by read / write) |
| B3h | RW | MSX-TIMER: counter read (a write selects the target core) |
| C0h | RW | OPL2 register address (write) / status read (MSX-AUDIO compatible) |
| C1h | WO | OPL2 register data |

The ADPCM has no independent I/O ports; it is controlled from the OPL2 ports (C0h / C1h) using a register map compatible with the Y8950 (MSX-AUDIO). The SCC likewise has no I/O ports and appears only in the memory space.

### 3.2.1 Accessing the SSG

The SSG is accessed using an address latch method.

1. Write the register number to A0h.
2. Write data to A1h, or read data from A2h.

The correspondence between register numbers and target cores is as follows; the two cores share a single address latch.

| Register number | Target |
|---|---|
| 00h–0Fh | SSG1 registers (YM2149-compatible registers) |
| 10h–1Fh | SSG2 registers (same as above) |
| 20h–22h / 24h–26h | Gain adjustment registers (SSG1 / SSG2) |
| 28h–2Ah / 2Ch–2Eh | Pan registers (SSG1 / SSG2) |

For details of the registers, see Section 4.3 in Chapter 4.

### 3.2.2 Accessing the OPLL / OPL2 / OPM

All of these use a two-port method: write the register number to the address port, and read or write the value at the data port.

- OPLL: 7Ch (address) / 7Dh (data). The same ports as MSX-MUSIC.
- OPL2: C0h (address) / C1h (data). The same ports as MSX-AUDIO; the status is read from C0h. The ADPCM registers are also included in this map.
- OPM: 7Eh (address) / 7Fh (data).

### 3.2.3 Accessing the MSX-TIMER

The MSX-TIMER has four cores, all accessed through the single set of ports B0h–B3h. Write an index to B0h (bits 3–2 select the core, bits 1–0 select the register within the core), and read or write the value of that register at B1h. B2h holds the interrupt flags for the four cores (cleared by read / write), and B3h reads the counter value of the currently selected core. For the timer specifications and interrupts, see Section 10.2 in Chapter 10.

### 3.2.4 System Controller

The System Controller is a management circuit connected to I/O 40h–4Fh, and provides identification of the cartridge and reads and writes to the Config ROM. Independently of the sound sources, it can be accessed from immediately after power-on.

| I/O address | Contents |
|---|---|
| 40h | Enabler. Writing 80h enables it. After it has been enabled, a read returns 7Fh (all bits of 80h inverted), and the program recognizes the presence of the System Controller by this. Until it is enabled, reads of 40h–4Fh are not responded to |
| 41h | Device Select. Write the device ID. The ID of the Y8960 Cartridge is **02h**. Only when its own ID has been written does it return the inverted value (FDh) on read. For other IDs it does not respond (to avoid bus contention with other devices) |
| 42h | Function Select. 01h = Config ROM Reader/Writer. When read in the correctly selected state, FEh is returned |
| 43h–45h | Config ROM address (lower / middle / upper 8 bits) |
| 46h | Command (00h = read, 01h = write, 02h = sector erase (in 64KB units), 03h = chip erase, 04h = status read. A read returns FFh) |
| 47h | Data. Read / status results are read from this port after the command has completed. Bit 0 of the status is BUSY |
| 48h–4Fh | Reserved. Does not respond to reads or writes |

While a command is executing (a few µs), I/O accesses to the System Controller cannot be accepted (no WAIT is issued). After writing a command to 46h, repeat reads until 40h returns 7Fh before performing the next access.

## 3.3 State at Power-On and Enabling the I/O Ports

Immediately after power-on and immediately after a reset, **all of the ordinary I/O ports of the sound source blocks are disabled**, and the cartridge does not respond to those addresses. This is a specification to avoid conflicts with other sound devices, and is based on the same approach as the Panasonic FM-PAC.

Enabling is performed block by block by writing to Memory Mapped I/O **I/O Enabler1 (7FF6h)** and **I/O Enabler2 (7FFFh)**.

| Address | Bit | Block enabled |
|---|---|---|
| 7FF6h (Enabler1) | b0 | OPLL |
| 7FFFh (Enabler2) | b0 | OPL2 (+ADPCM) |
| | b1 | SSG |
| | b2 | OPM |
| | b7 | MSX-TIMER |

Writing 1 to a bit enables it; writing 0 returns it to disabled. Enabler2 can also be read, so the current settings can be read back.

![Bit layout of 7FF6h (I/O Enabler1)](images/bf_enabler1.png)

![Bit layout of 7FFFh (I/O Enabler2)](images/bf_enabler2.png)

Note that MMIO itself is an access to the cartridge's memory space, so even when multiple Y8960 Cartridges are installed, each cartridge can be enabled and controlled individually (the I/O ports of a cartridge that has not been enabled remain disabled, so there is no conflict in the I/O space either).

## 3.4 Memory-Mapped I/O (7FF0h–7FFFh)

MMIO is a 16-byte window at memory addresses 7FF0h–7FFFh. Except for 7FFFh, it is write-only. This window can be used only **when RAM mode = 0, or when a ROM bank (BANK#0–#15) is mapped into BANK1** (Section 3.5).

| Address | R/W | Contents |
|---|---|---|
| 7FF0h | WO | SSG register address |
| 7FF1h | WO | SSG register data write |
| 7FF2h | WO | OPL2 register address |
| 7FF3h | WO | OPL2 register data |
| 7FF4h | WO | OPLL register address |
| 7FF5h | WO | OPLL register data |
| 7FF6h | WO | I/O Enabler1 (b0 = OPLL) |
| 7FF7h | WO | SSG volume |
| 7FF8h | WO | OPLL volume |
| 7FF9h | WO | OPL2 volume |
| 7FFAh | WO | SCC volume |
| 7FFBh | WO | OPM register address |
| 7FFCh | WO | OPM register data |
| 7FFDh | WO | OPM volume |
| 7FFEh | WO | Master volume |
| 7FFFh | RW | I/O Enabler2 (b7 = TIMER, b2 = OPM, b1 = SSG, b0 = OPL2) |

All volumes are 8-bit values: 0 = OFF, 128 = MAX. For details of the mixer, see Chapter 9.

Register accesses via MMIO can be used at any time, regardless of whether the ordinary I/O ports are enabled or disabled. This is convenient when you want to initialize the sound sources before enabling the I/O ports, such as during driver initialization.

## 3.5 Memory Map and Bank Control

### 3.5.1 Bank Organization

The CPU memory space 4000h–BFFFh is divided into four banks of 8KB each.

| CPU address | Bank name |
|---|---|
| 4000h–5FFFh | BANK0 |
| 6000h–7FFFh | BANK1 |
| 8000h–9FFFh | BANK2 |
| A000h–BFFFh | BANK3 |

Each bank has a bank register; writing a value n maps SerialSRAM BANK#n into that bank. The contents of BANK#n are as described in Section 2.2 in Chapter 2 (#0–#15 = ROM, #16–#31 = RAM), and the upper bank numbers are handled as follows.

| Bank number | Handling |
|---|---|
| #32–#62 | Mirrors of BANK#0–#30 |
| #63 | The SCC register bank when the conditions are met (Section 3.5.3). In the remaining ranges, not connected (no ROM appears) |
| #64–#255 | The bank registers are 6 bits, so the upper 2 bits are discarded and the value is handled the same as #0–#63 (for example, #127 is handled as #63) |

The bank registers are write-only, and their values cannot be read back. Reading a bank register address returns the contents of the SerialSRAM mapped at that address.

**BANK0 is read-only.** Even if a RAM bank (#16–#31) is mapped in, writes to BANK0 do not reach the SRAM (except for writes to the RAM mode register, described below).

### 3.5.2 RAM Mode and Bank Register Layout

The placement of the bank registers changes depending on the RAM mode (compatible mode / RAM mode). At power-on, RAM mode = 0 (compatible mode).

**Bank registers for RAM mode = 0 (compatible mode)**:

| Address | Contents |
|---|---|
| 5000h–57FFh | BANK0 bank register |
| 7000h–77FFh | BANK1 bank register |
| 9000h–97FFh | BANK2 bank register |
| B000h–B7FFh | BANK3 bank register |

Switching to **RAM mode = 1** is done by writing 1 to **b0 of address 4XFBh (X = 8–F)**. In RAM mode, the layout changes as follows.

| Address | Contents |
|---|---|
| 4XFBh | BANK mode register (b0: 0 = compatible mode, 1 = RAM mode). Always present |
| 4XFCh | BANK0 bank register |
| 4XFDh | BANK1 bank register |
| 4XFEh | BANK2 bank register |
| 4XFFh | BANK3 bank register |

In RAM mode, writes to BANK1–BANK3 reach the SRAM, and the SCC register bank can also be mapped into BANK1. Note that writes to the RAM mode register and to the bank registers themselves are not written into the contents of the currently mapped BANK#.

### 3.5.3 SCC Register Bank

When BANK#63 is mapped in, that bank becomes the SCC register bank. The locations where it appears are as follows.

| Condition | Address where the SCC registers appear |
|---|---|
| BANK#63 in BANK2 (regardless of the RAM mode) | 9800h–9FFFh (addresses shown as 9xxxh) |
| RAM mode = 1, BANK#63 in BANK1 | 7800h–7FFFh (addresses shown as 7xxxh) |

In a bank where BANK#63 is mapped in, no ROM appears at addresses outside the SCC register window (the ranges in the table above) either; those ranges are unconnected.

Overview of the register layout (for 9xxxh; for 7xxxh, the top digit becomes 7):

| Address | R/W | Contents |
|---|---|---|
| 9800h–981Fh | RW | Ch.A waveform memory (32 bytes) |
| 9820h–983Fh | RW | Ch.B waveform memory |
| 9840h–985Fh | RW | Ch.C waveform memory |
| 9860h–987Fh | RW | Ch.D/E waveform memory |
| 9880h–9889h | WO | Frequency registers for each channel |
| 988Ah–988Eh | WO | Volume registers for each channel |
| 988Fh | WO | Output switch |
| 9890h–989Fh | WO | Mirrors of 9880h–988Fh |
| 98E0h–98FFh | WO | Mode register (implemented as a single byte) |
| 9900h–9904h | WO | Stereo positioning (pan) for Ch.A–E. 1 = leftmost, 128 = center, 255 = rightmost. Default 128 |
| 9905h–9FFFh | ― | Unused (access prohibited; reserved for future use) |

For write-only registers such as the frequency and volume registers, there is no guarantee that a value will be returned when they are read. For details of the SCC registers, see Section 7.3 in Chapter 7.

# Chapter 4 SSG

## 4.1 Overview

The Y8960 contains **two** SSG cores equivalent to the YM2149 (AY-3-8910 compatible). In this manual, the first core is called **SSG1** and the second **SSG2**. Each core has three tone channels (A / B / C), one noise generator group, and one envelope generator group, and its register configuration and basic operation are compatible with the YM2149.

The two cores operate simultaneously at all times, and their outputs are summed and sent to the SSG input of the mixer. The two-core arrangement is intended for uses such as assigning one core to music and the other to sound effects. Which core is assigned to which purpose is up to the software, and there is no distinction in hardware. Note, however, that as described below, registers can be read only on the SSG2 side.

The Y8960 extensions are the following two points.

- **Per-channel stereo positioning (pan)**: An 8-bit pan can be specified for each of channels A / B / C, so the left/right positioning can be varied per channel (Section 4.6).
- **Per-channel gain**: The output level of each channel can be adjusted with 8 bits (Section 4.6).

## 4.2 Access Methods

### 4.2.1 I/O Ports

The SSG is accessed through I/O ports A0h–A3h. The two cores share a single register address space (Section 4.3), and the roles of the ports are as follows.

| Port | R/W | Function |
|---|---|---|
| A0h | W | Specifies the register address |
| A1h | W | Writes to a register (reads return FFh) |
| A2h | R | Reads from a register |
| A3h | − | Reserved. Accessing it has no effect (reads return FFh) |

To write, write the register address to A0h, then write the data to A1h. To read, write the register address to A0h, then read A2h.

Note that immediately after power-on, the SSG I/O ports are disabled. To use them, the I/O enable (the SSG bit of MMIO 7FFFh) must be set to 1 to enable them (see Chapter 3).

### 4.2.2 Memory-Mapped I/O (Mirror)

The same register access can also be performed through memory-mapped I/O 7FF0h / 7FF1h.

| Address | R/W | Function |
|---|---|---|
| 7FF0h | W | Specifies the register address (same as A0h) |
| 7FF1h | W | Writes to a register (same as A1h) |

The mirror side is write-only and cannot be read. For the memory-state conditions under which the mirror is available, see Chapter 3.

## 4.3 Register Map

The register address is 6 bits, and the basic registers and extended registers of SSG1 / SSG2 are arranged in a single space.

| Address | Target | Contents |
|---|---|---|
| 00h–0Fh | SSG1 | Basic registers (Table 4.2) |
| 10h–1Fh | SSG2 | Basic registers (same configuration as Table 4.2) |
| 20h–22h | SSG1 | Per-channel gain A / B / C (Section 4.6) |
| 23h | − | Not connected |
| 24h–26h | SSG2 | Per-channel gain A / B / C (Section 4.6) |
| 27h | − | Not connected |
| 28h–2Ah | SSG1 | Per-channel pan A / B / C (Section 4.6) |
| 2Bh | − | Not connected |
| 2Ch–2Eh | SSG2 | Per-channel pan A / B / C (Section 4.6) |
| 2Fh | − | Not connected |
| 30h–3Fh | − | Not connected |

Because the register address is interpreted with its lower 6 bits, specifying 40h–FFh accesses a mirror of 00h–3Fh. For example, specifying 50h accesses 10h (SSG2 R#0).

**Read availability**: Reading (via A2h) is possible only for **the SSG2-side registers (10h–1Fh, 24h–26h, 2Ch–2Eh)**; all SSG1-side registers are write-only. Specifying an SSG1-side address and reading returns FFh.

### Table 4.2 Basic registers (SSG1 uses offset +00h, SSG2 uses offset +10h)

| Offset | Contents | Bit configuration |
|---|---|---|
| 00h | Ch.A tone divider, low | Divider [7:0] |
| 01h | Ch.A tone divider, high | Divider [11:8] |
| 02h | Ch.B tone divider, low | Divider [7:0] |
| 03h | Ch.B tone divider, high | Divider [11:8] |
| 04h | Ch.C tone divider, low | Divider [7:0] |
| 05h | Ch.C tone divider, high | Divider [11:8] |
| 06h | Noise divider | Divider [4:0] |
| 07h | Mixer / I/O control (/ENABLE) | b7: IOB, b6: IOA, b5: NC, b4: NB, b3: NA, b2: TC, b1: TB, b0: TA |
| 08h | Ch.A volume | b4: M (envelope select), b3–b0: volume |
| 09h | Ch.B volume | b4: M, b3–b0: volume |
| 0Ah | Ch.C volume | b4: M, b3–b0: volume |
| 0Bh | Envelope period, low | Period [7:0] |
| 0Ch | Envelope period, high | Period [15:8] |
| 0Dh | Envelope shape | b3: CONT, b2: ATT, b1: ALT, b0: HOLD |
| 0Eh | I/O port A | GPIO (Section 4.5) |
| 0Fh | I/O port B | GPIO (Section 4.5) |

## 4.4 Functions of the Basic Registers

The basic registers operate in the same way as on the YM2149. The SSG's reference clock is equivalent to the standard MSX PSG clock (1.7897725 MHz), so the frequency formulas below apply as they are.

### 4.4.1 Tone Divider (00h–05h)

These registers specify the square-wave frequency of each channel as a 12-bit divider TP, split into a low register (00h / 02h / 04h) and a high register (01h / 03h / 05h) per channel. The frequency f is given by:

- **f = 1789772.5 / (16 × TP)** (Hz)

The larger TP is, the lower the sound. A value of 0 is treated as 1, giving the highest frequency of about 111.9 kHz; at TP = 4095 the frequency is about 27.3 Hz. Table 4.3 gives a guide to the correspondence with note names.

### Table 4.3 Guide to Note Names and Tone Dividers

| Note | Frequency (Hz) | Divider TP |
|---|---|---|
| C4 | 261.6 | 427 |
| D4 | 293.7 | 381 |
| E4 | 329.6 | 339 |
| F4 | 349.2 | 320 |
| G4 | 392.0 | 285 |
| A4 | 440.0 | 254 |
| B4 | 493.9 | 227 |
| C5 | 523.3 | 214 |

### 4.4.2 Noise Divider (06h)

Specifies the frequency of the noise generator as a 5-bit divider NP. The noise reference frequency f is given by the following formula; the larger NP is, the lower (darker) the noise.

- **f = 1789772.5 / (16 × NP)** (Hz)

There is only one noise generator, shared by the three channels. Which channels the noise is sent to is selected with the mixer (07h). A value of 0 is treated as 1.

### 4.4.3 Mixer / I/O Control (07h)

This register enables or disables the tone and noise output of each channel. Its bit layout is shown in Figure 4.1.

![Bit layout of 07h (Mixer / I/O Control)](images/bf_ssg_mixer.png)

Note that TA / TB / TC and NA / NB / NC are all **negative logic**: **0 enables and 1 disables**. A channel's output is the logical OR of its enabled tone and noise; enabling both superimposes them. To stop a sound, besides setting the volume to 0, you can also disable both tone and noise in this register.

IOA / IOB specify the direction of I/O ports A / B: 0 is input and 1 is output (Section 4.5).

### 4.4.4 Volume (08h–0Ah)

Specifies each channel's volume in 4 bits. 0 is silent and 15 is maximum. The volume steps are logarithmic (about 3 dB per step), so the level does not drop abruptly at small values.

When the M bit (b4) is 1, that channel's volume follows the output of the envelope generator instead of the lower 4 bits. The envelope generator is shared by the three channels, so setting M on several channels applies the same envelope shape to each of them.

### 4.4.5 Envelope Period (0Bh, 0Ch)

Specifies the length of one envelope cycle as a 16-bit value EP. The period T is given by:

- **T = 256 × EP / 1789772.5** (seconds)

For example, EP = 6991 (1B4Fh) gives a period of about one second. The envelope shape consists of 32 steps per cycle (5-bit volume levels). There is only one EP for the whole envelope generator, shared by the three channels.

### 4.4.6 Envelope Shape (0Dh)

Selects the envelope shape with the four bits CONT / ATT / ALT / HOLD. The bit layout is shown in Figure 4.2, and the correspondence between the bits and the shapes in Figure 4.3.

![Bit layout of 0Dh (Envelope Shape)](images/bf_ssg_env.png)

![Envelope shapes (correspondence between CONT / ATT / ALT / HOLD of 0Dh and the shapes)](images/fig_env_ssg.png)

- **CONT**: When 1, the shape repeats. When 0, the shape is output for one cycle and then stops.
- **ATT**: When 1, the shape rises (from minimum to maximum); when 0, it falls (from maximum to minimum).
- **ALT**: When CONT = 1, inverts the polarity of the shape on each cycle. Combined with a sawtooth, this produces a triangle wave.
- **HOLD**: Holds the level reached when the repeat stops. Combined with ALT, the level held is on the inverted side.

Writing to this register restarts the envelope from the beginning of the shape (retrigger). The basic usage is to rewrite it at the start of a phrase, in time with the note.

## 4.5 I/O Ports (GPIO)

Registers 0Eh / 0Fh of each core are general-purpose I/O ports A / B. Their connections on the cartridge are as follows.

| Core | Port A (0Eh / 1Eh) | Port B (0Fh / 1Fh) |
|---|---|---|
| SSG1 | Not connected | Not connected |
| SSG2 | Input: the cartridge DIP switches (lower 2 bits; the upper bits are 0) | Not connected (the output is not connected) |

By reading SSG2 port A, the setting state of the DIP switches can be obtained. Keep the IOA bit of 07h / 17h at 0 (input).

## 4.6 Y8960 Extended Registers

### 4.6.1 Per-Channel Gain (20h–26h)

These registers adjust the final output level of each channel with 8 bits (SSG1: A = 20h, B = 21h, C = 22h; SSG2: A = 24h, B = 25h, C = 26h).

- The value range is 0–128, with **128 being the maximum** (unity gain); 0 produces silence.
- The default is 128.
- Because this gain acts on the output stage of the core, it also affects channels for which the envelope is selected in the volume register. It can be used to fine-tune, per channel, the balance of a sound created with the 4-bit volume (plus envelope).

On the mixer side there is also a volume for the SSG group as a whole (MMIO 7FF7h, 0 = OFF to 128 = MAX). The roles are divided as follows: the per-channel gain adjusts each channel, and the mixer volume adjusts the SSG group as a whole (see the chapter on the digital mixer).

### 4.6.2 Per-Channel Pan (28h–2Eh)

These registers specify the stereo positioning of each channel with 8 bits (SSG1: A = 28h, B = 29h, C = 2Ah; SSG2: A = 2Ch, B = 2Dh, C = 2Eh).

- **1 is the far left, 128 is center, and 255 is the far right.**
- The default is 128 (center).
- Noise and the envelope are constituent elements of a channel, and the pan and gain set for that channel apply to them as they are.

Since earlier SSG sound sources were monaural, playing existing music data as it is reproduces all channels positioned at center. By panning each channel, playback with a stereo image becomes possible.

## 4.7 Usage

### 4.7.1 Producing a Tone

The procedure for producing a single tone on the SSG is as follows.

1. Set the SSG bit of the I/O Enabler (MMIO 7FFFh) to 1 to enable the SSG's I/O ports (Chapter 3).
2. Write the value for the desired pitch to the tone dividers (00h–05h).
3. Enable that channel's tone in the mixer (07h) (set the corresponding bit to 0).
4. Write a value from 1 to 15 to the volume (08h–0Ah).

To stop the sound, set the volume to 0, or disable both tone and noise in the mixer. Sample SSG401 is a program that plays A4 (440 Hz) on SSG1 channel A (the file is included in the sample collection).

```
;-----------------------------------------------------------------------
;	SSG401.asm - SSG tone and envelope (Y8960)
;	Plays A4 (440 Hz) on SSG1 channel A, then switches to the
;	envelope (triangle wave, period about 1 second) after about
;	1 second. ROM format at 4000h. Assemble with zma.
;-----------------------------------------------------------------------
		org		4000h
		db		"AB"
		dw		start

;	Write an SSG1 register (A = register number, E = data)
ssg1w:
		out		[0a0h], a
		ld		a, e
		out		[0a1h], a
		ret

start:
		; Set the SSG bit of Enabler2 (MMIO 7FFFh) to enable the SSG
		ld		a, 02h
		ld		[7fffh], a

		; Ch.A tone divider = 254 (A4 = about 440 Hz)
		ld		a, 00h
		ld		e, 0feh
		call	ssg1w
		ld		a, 01h
		ld		e, 00h
		call	ssg1w

		; Mixer (07h): enable tone A only (3Eh, negative logic)
		ld		a, 07h
		ld		e, 3eh
		call	ssg1w

		; Ch.A volume (08h) = 15
		ld		a, 08h
		ld		e, 0fh
		call	ssg1w
		… (wait about 1 second)
		… (continues with the envelope setup in the next section)
```

### 4.7.2 Using the Envelope

The envelope lets the hardware handle the volume change over time. The procedure is only to set the period (0Bh / 0Ch) and the shape (0Dh), and to set the M bit of the volume register of the channel you want to use. The second half of SSG401 sets a triangle wave with a period of about one second (0Dh = 0Ah), so that the volume of channel A moves up and down with a one-second cycle.

```
		; Envelope period (0Bh/0Ch) = 6991 (period about 1 second)
		ld		a, 0bh
		ld		e, 4fh
		call	ssg1w
		ld		a, 0ch
		ld		e, 1bh
		call	ssg1w

		; Envelope shape (0Dh) = 0Ah (CONT=1, ATT=0, ALT=1, HOLD=0: triangle)
		; Writing it restarts the envelope
		ld		a, 0dh
		ld		e, 0ah
		call	ssg1w

		; Set the M bit of the Ch.A volume (08h) to switch to the envelope
		ld		a, 08h
		ld		e, 10h
		call	ssg1w
```

The envelope is shared by the three channels, and there is only one period and shape. If you need a different envelope per channel, split the work between SSG1 and SSG2, or use software rewriting of the volume registers instead.

# Chapter 5 OPLL-EX

## 5.1 Overview

OPLL-EX is an FM sound source equivalent to the YM2413 (OPLL). It is configured either as 9 melody channels, or as 6 melody channels + 5 rhythm sounds (bass drum, snare drum, tom-tom, top cymbal, and hi-hat). Its register configuration and basic operation are compatible with the YM2413, so the software assets of MSX-MUSIC can be used as they are.

The Y8960 extensions are the following two points, and this extended version is called OPLL-EX.

- **Addition of preset instrument banks**: In addition to the genuine YM2413 preset instruments, it contains the preset instrument sets of the OPLL-X (YM2423), the OPLL-P (YMF281), and the VRC7, which can be switched per channel (Section 5.4).
- **Per-channel stereo positioning (pan)**: An 8-bit pan can be specified for each of the 9 channels (Section 5.6). Since the YM2413 had monaural output, this is an extension unique to the Y8960.

## 5.2 Access Methods

### 5.2.1 I/O Ports

| Port | R/W | Function |
|---|---|---|
| 7Ch | W | Specifies the register address |
| 7Dh | W | Writes to a register |

The OPLL registers cannot be read. To write, write the register address to 7Ch, then write the data to 7Dh.

Immediately after power-on, the OPLL I/O ports are disabled. To use them, I/O Enabler 1 (the OPLL bit of MMIO 7FF6h) must be set to 1 to enable them (see Chapter 3).

### 5.2.2 Memory-Mapped I/O (Mirror)

| Address | R/W | Function |
|---|---|---|
| 7FF4h | W | Specifies the register address (same as 7Ch) |
| 7FF5h | W | Writes to a register (same as 7Dh) |

For the memory-state conditions under which the mirror is available, see Chapter 3.

[TBC] The specified values for the wait required when writing to a register (the waiting time after writing the address and after writing the data). The original chip, the YM2413, has specified values, but whether the same wait is required in the Y8960 implementation has not been confirmed.

## 5.3 Register Map

All registers are write-only. 00h–38h is the YM2413-compatible part, and 40h–48h and 50h–58h are registers newly added in the Y8960.

| Address | Contents | Main bit configuration |
|---|---|---|
| 00h | User instrument: modulator characteristics | AM, VIB, EGT, KSR, MULTI [3:0] |
| 01h | User instrument: carrier characteristics | AM, VIB, EGT, KSR, MULTI [3:0] |
| 02h | User instrument: modulator output level | KSL [7:6], TL [5:0] |
| 03h | User instrument: modulation depth / feedback | KSL [7:6], DC, DM, FB [2:0] |
| 04h | User instrument: modulator EG | AR [7:4], DR [3:0] |
| 05h | User instrument: carrier EG | AR [7:4], DR [3:0] |
| 06h | User instrument: modulator EG | SL [7:4], RR [3:0] |
| 07h | User instrument: carrier EG | SL [7:4], RR [3:0] |
| 08h–0Dh | Unused | − |
| 0Eh | Rhythm control | b5: R (rhythm mode), b4: BD, b3: SD, b2: TOM, b1: TC, b0: HH (key-on for each rhythm sound) |
| 0Fh | Test | Always write 0 |
| 10h–18h | Ch.1–9 F-number, low | F# [7:0] |
| 19h–1Fh | Unused | − |
| 20h–28h | Ch.1–9 control | SUS [5], KEY [4], BLOCK [3:1], F# [0] (most significant bit) |
| 29h–2Fh | Unused | − |
| 30h–38h | Ch.1–9 instrument / volume | INST [7:4] (instrument number), VOL [3:0] (volume) |
| 39h–3Fh | Unused | − |
| **40h–48h** | **Ch.1–9 preset instrument bank (new)** | BANK [1:0] (Section 5.4) |
| 49h–4Fh | Unused | − |
| **50h–58h** | **Ch.1–9 pan (new)** | PAN [7:0] (Section 5.6) |
| 59h–FFh | Unused | − |

### 5.3.1 User Instrument Registers (00h–07h)

The user instrument used when INST = 0 is defined by the parameters of two operators (the modulator and the carrier). OPLL FM uses a two-operator configuration in which the modulator modulates the carrier's frequency: the modulator-side parameters mainly determine the sound's brightness and harmonics, and the carrier side determines the volume envelope. The bit layout of each register is as follows.

![Bit layout of 00h/01h (operator characteristics)](images/bf_opll_inst_a.png)

![Bit layout of 02h (modulator output level)](images/bf_opll_inst_tl.png)

![Bit layout of 03h (modulation depth / feedback)](images/bf_opll_inst_fb.png)

![Bit layout of 04h/05h (AR / DR)](images/bf_opll_inst_eg1.png)

![Bit layout of 06h/07h (SL / RR)](images/bf_opll_inst_eg2.png)

- **MULTI**: The operator's frequency multiplier. The correspondence between value and multiplier is: 0 = 1/2, 1 = 1, 2 = 2, 3 = 3, 4 = 4, 5 = 5, 6 = 6, 7 = 7, 8 = 8, 9 = 9, 10 and 11 = 10, 12 and 13 = 12, 14 and 15 = 15. Changing the modulator's multiplier changes the harmonic structure.
- **TL**: The modulator's output level. The smaller the value, the deeper the modulation and the brighter the sound (more harmonics). The carrier's volume is determined not by TL but by the per-channel VOL (30h–38h).
- **KSL**: How much the operator's output is weakened as the pitch rises. With a larger value, high notes sound rounder (and, on the modulator side, darker).
- **FB**: The amount of feedback into the modulator itself. Larger values increase the harmonics and make the sound sharper.
- **AM / VIB**: When 1, the built-in LFO applies tremolo (amplitude modulation) / vibrato (frequency modulation) to that operator. The LFO depth is a fixed value common to all operators.
- **KSR**: When 1, each envelope rate becomes faster at higher pitches.
- **DC / DM**: Waveform selection for the operators. 0 is a sine wave and 1 is a half-wave waveform (a sine wave with the negative side set to 0), which contains more harmonics.

The envelope consists of the four stages AR (attack) → DR (decay) → SL (sustain level) → RR (release) (Figure 5.1). An operator with EGT = 1 (sustaining type) keeps holding SL while the key is on. With EGT = 0 (percussive type), the envelope continues to decay slowly even after reaching SL, and eventually becomes silent. On key-off, both types decay at the speed of RR.

![OPLL envelope (AR / DR / SL / RR and EGT)](images/fig_eg_opll.png)

### 5.3.2 Channel Registers (10h–38h)

The pitch of each channel is specified by the F-number (9 bits) and BLOCK (3 bits). The sounding frequency f is given by:

- **f = F# × 2^BLOCK × 3579545 / 37748736** (Hz)

BLOCK specifies the octave; with the same F-number, raising BLOCK by 1 raises the pitch by one octave. Table 5.1 gives a guide to the correspondence with note names at BLOCK = 4.

### Table 5.1 Guide to Note Names and F-Numbers (BLOCK = 4)

| Note | Frequency (Hz) | F-Number |
|---|---|---|
| C4 | 261.6 | 172 |
| D4 | 293.7 | 194 |
| E4 | 329.6 | 217 |
| F4 | 349.2 | 230 |
| G4 | 392.0 | 258 |
| A4 | 440.0 | 290 |
| B4 | 493.9 | 326 |
| C5 | 523.3 | 345 |

The bit layouts of the control registers and the instrument/volume registers are as follows.

![Bit layout of 20h–28h (channel control)](images/bf_opll_ctrl.png)

![Bit layout of 30h–38h (instrument / volume)](images/bf_opll_instvol.png)

- **KEY**: 1 is key-on (start of sound), 0 is key-off. The envelope starts from the beginning at the moment of key-on.
- **SUS**: While 1, even if KEY is set to 0, the envelope does not move to release and holds the sustain level (equivalent to a sustain pedal).
- **INST**: The instrument number. 0 is the user instrument (Section 5.3.1), and 1–15 are the preset instruments.
- **VOL**: The channel volume. Note that the direction is reversed: **the smaller the value, the larger the volume** (0 is the maximum).

## 5.4 Preset Instrument Banks

The preset instruments of the YM2413 family differ in content from chip to chip. The OPLL-EX contains the following four kinds of preset instrument sets (banks).

| Bank | Contents |
|---|---|
| OPLL | The preset instruments of the YM2413 |
| OPLL-X | The preset instruments of the YM2423 |
| OPLL-P | The preset instruments of the YMF281 |
| VRC7 | The preset instruments of the VRC7 |

For each channel, the **BANK (lower 2 bits)** of the additional registers 40h–48h (40h for Ch.1, …, 48h for Ch.9) selects the bank that the channel uses. INST (the instrument number) in 30h–38h points to a preset instrument within the selected bank. The user instrument with INST = 0 (the instrument defined in 00h–07h) is common regardless of the bank.

![Bit layout of 40h–48h (preset instrument bank)](images/bf_opll_bank.png)

Because the bank can be changed per channel, mixed use is possible, for example using VRC7 instruments for the melody and YM2413 instruments for the accompaniment.

The correspondence between the BANK values and the banks is: BANK = 0 is OPLL (YM2413), 1 is OPLL-X (YM2423), 2 is OPLL-P (YMF281), and 3 is VRC7. The VRC7 bank can also be selected via the BANK register.

## 5.5 Rhythm Mode

Setting the R bit of register 0Eh to 1 enters rhythm mode, and melody Ch.7–9 are replaced by rhythm sounds (BD / SD / TOM / TC / HH). The bit layout of 0Eh is as follows.

![Bit layout of 0Eh (rhythm control)](images/bf_opll_rhythm.png)

The correspondence between each rhythm sound, the operator that produces it, and its volume is as follows. The instrument follows the INST of the responsible channel. Note that in rhythm mode, the upper 4 bits of 37h / 38h are not an instrument number but are treated as the HH / TOM volume, respectively.

| Rhythm Sound | Content | Responsible Operator | Volume |
|---|---|---|---|
| BD | Bass drum | Ch.7 modulator and carrier | Lower 4 bits of 36h |
| HH | Hi-hat | Ch.8 modulator + noise | Upper 4 bits of 37h |
| SD | Snare drum | Ch.8 carrier + noise | Lower 4 bits of 37h |
| TOM | Tom-tom | Ch.9 modulator | Upper 4 bits of 38h |
| TC | Top cymbal | Ch.9 carrier + noise | Lower 4 bits of 38h |

The pitch of BD is determined by the F-number of Ch.7, and that of TOM by the F-number of Ch.9. To play a rhythm sound, first set the INST and volume of the responsible channel and (for BD / TOM) the F-number, then change the corresponding bit of 0Eh from 0 to 1. Leaving the bit at 1 does not retrigger the sound, so return the bit to 0 before setting it to 1 for each hit. While rhythm mode is active, Ch.7–9 cannot be used as melody channels.

## 5.6 Stereo Positioning (Pan)

The additional registers 50h–58h (50h for Ch.1, …, 58h for Ch.9) specify the stereo positioning for each channel.

- **1 is the far left, 128 is center, and 255 is the far right.**
- The default is 128 (center).

On the mixer side there is also a volume for the OPLL group as a whole (MMIO 7FF8h, 0 = OFF to 128 = MAX) (see the chapter on the digital mixer).

In rhythm mode, the pan of the five rhythm sounds also follows the pan of their responsible channels (56h–58h): BD follows 56h, HH and SD follow 57h, and TOM and TC follow 58h.

## 5.7 Usage

### 5.7.1 Playing a Melody

The procedure for playing a single melody note on the OPLL is as follows.

1. Set the OPLL bit of I/O Enabler 1 (MMIO 7FF6h) to 1 to enable the OPLL's I/O ports (Chapter 3).
2. Write INST and VOL to the channel's instrument/volume register (30h–38h).
3. Write the lower 8 bits of the pitch to the F-number low register (10h–18h).
4. Write BLOCK and the most significant bit of the F-number to the control register (20h–28h), and finally set KEY to 1 to start the sound.

To stop the sound, set KEY to 0. To play the next note, rewrite the F-number and set KEY to 1 again (if you change only the F-number while KEY = 1, the pitch changes without restarting the envelope; use this for legato playing).

Sample OPLL501 is a program that plays A4 with a preset instrument on Ch.1 (the file is included in the sample collection).

```
		; Ch.1 instrument/volume (30h): INST = 1 (violin), VOL = 0 (maximum)
		ld		a, 30h
		ld		e, 10h
		call	opllw
		; Ch.1 F-number low (10h) = 22h (F# = 290, A4 at BLOCK = 4)
		ld		a, 10h
		ld		e, 22h
		call	opllw
		; Ch.1 control (20h): KEY = 1, BLOCK = 4, top bit of F# = 1
		ld		a, 20h
		ld		e, 19h
		call	opllw
		… (wait about 1 second)
		; Key off (KEY = 0)
		ld		a, 20h
		ld		e, 09h
		call	opllw
```

### 5.7.2 Creating a User Instrument

Instead of a preset instrument, writing your own parameters to 00h–07h makes the user instrument available. There is only one user instrument, shared by all channels, and channels that select INST = 0 use it. Rewriting the parameters also changes the sound of channels that are currently playing, on the spot.

A guide to creating one is as follows. The carrier side determines the sound's envelope (AR = 15, DR for the decay feel, SL and RR for the tail), and the modulator side adjusts the brightness with TL and the harmonic structure with MULTI and FB. The second half of OPLL501 sets parameters close to a sustaining (EGT = 1) organ and plays the same A4 again with the user instrument.

```
		; Set the user instrument (00h-07h)
		ld		a, 00h			; Modulator: EGT=1, MULTI=1
		ld		e, 21h
		call	opllw
		ld		a, 01h			; Carrier: EGT=1, MULTI=1
		ld		e, 21h
		call	opllw
		ld		a, 02h			; Modulator TL = 24
		ld		e, 18h
		call	opllw
		ld		a, 03h			; Feedback = 5
		ld		e, 05h
		call	opllw
		ld		a, 04h			; Modulator AR=15, DR=8
		ld		e, 0f8h
		call	opllw
		ld		a, 05h			; Carrier AR=15, DR=6
		ld		e, 0f6h
		call	opllw
		ld		a, 06h			; Modulator SL=4, RR=6
		ld		e, 46h
		call	opllw
		ld		a, 07h			; Carrier SL=3, RR=6
		ld		e, 36h
		call	opllw
		; Switch Ch.1 to the user instrument (INST = 0), VOL = 2, and play
		ld		a, 30h
		ld		e, 02h
		call	opllw
		ld		a, 20h
		ld		e, 19h
		call	opllw
```

# Chapter 6 OPL2 + ADPCM

## 6.1 Overview

This block combines an FM sound source equivalent to the YM3812 (OPL2) with an ADPCM playback section equivalent to ADPCM-B. Its register map is configured to be **compatible with the MSX-AUDIO (Y8950)**, so existing software written for the MSX-AUDIO can be used.

- **FM section**: 2-operator FM, 9 channels. In rhythm mode, 6 melody channels + 5 rhythm sounds. It contains two timers (Timer 1 / Timer 2) and can generate interrupts. The Y8960 implementation uses a stereo-output core, and per-channel panning has been added as an extension (Section 6.7).
- **ADPCM section**: Sample playback using the ADPCM-B method. It has a dedicated 256KB memory, and plays back waveform data stored in memory using delta modulation. Playback with the CPU supplying data directly to the data register, without going through memory (CPU direct playback, Section 6.6), is also possible. The data port for recording and for memory read/write is also located at the same addresses as on the Y8950.

The outputs of the FM section and the ADPCM section are summed and saturated within the block, and are combined into a single group as the mixer's "OPL2" input. The mixer volume and pan are therefore common to the FM section and the ADPCM section (panning per channel can be set individually in each section).

The functions that existed on the Y8950 but were abolished on the Y8960 (keyboard I/O, the prescaler, direct DAC output, and so on) are listed in Section 6.5.

## 6.2 Access Methods

### 6.2.1 I/O Ports

| Port | R/W | Function |
|---|---|---|
| C0h | W | Specifies the register address |
| C0h | R | Reads the status register (Section 6.3) |
| C1h | W | Writes to a register |

To write, write the register address to C0h, then write the data to C1h. The register values themselves cannot be read back.

Immediately after power-on, the OPL2 I/O ports are disabled. To use them, set the OPL2 bit of I/O Enabler 2 (MMIO 7FFFh) to 1 to enable them (see Chapter 3).

### 6.2.2 Memory-Mapped I/O (Mirror)

| Address | R/W | Function |
|---|---|---|
| 7FF2h | W | Specifies the register address (same as C0h) |
| 7FF3h | W | Writes to a register (same as C1h) |

The mirror side is write-only, and the status cannot be read from it. For the memory-state conditions under which the mirror can be used, see Chapter 3.

[TBC] The specified wait times required when writing registers (the wait after writing an address and after writing data). The original chips, the YM3812 / Y8950, have specified values, but whether the same waits are required in the Y8960 implementation has not been confirmed.

## 6.3 Status Register

Reading C0h returns the status register. It is used to check interrupt sources.

| Bit | Name | Meaning |
|---|---|---|
| b7 | INT | An interrupt has occurred (one of the flags is set and interrupts are enabled) |
| b6 | T1 | Timer 1 flag |
| b5 | T2 | Timer 2 flag |
| b4 | EOS | The ADPCM has reached the stop address |
| b3 | BUF_RDY | Buffer ready (the ADPCM data register can be accessed) |
| b2–b1 | − | Fixed at 1 |
| b0 | PCM_BSY | 1 while playing (while START of Control 1 is set) |

Flags are masked and cleared using register 04h (flag control) (Section 6.4). For the handling of interrupts as a whole, see the chapter on interrupts.

The ADPCM-related flags behave as follows.

- Immediately after reset, the EOS / BUF_RDY flags are both masked, and the status reads 06h (no interrupt is raised by the ADPCM either). The masks are released with register 04h.
- EOS is set when playback reaches the stop address. In repeat playback, it is also set at the end of each loop.
- When non-repeat playback ends, START and the other bits of Control 1 are cleared automatically, and PCM_BSY also returns to 0.
- BUF_RDY stays 1 while idle and in memory transfer modes. During reads and writes through the data register, it is 0 until the access to the SRAM completes. In CPU direct playback (Section 6.6), it becomes 1 when a supplied byte has been consumed, and becomes 0 when the data register is written.

## 6.4 FM Section Registers

All registers are write-only. The address layout of the FM section and the meaning of each parameter are the same as on the YM3812, and are described in this section. The timer/flag-related registers are shown in Section 6.3 and in the table in this section.

| Address | Contents | Main bit composition |
|---|---|---|
| 01h | Test / waveform select enable | b5: WS enable (when 1, the waveform selection in E0h–F5h becomes effective). The other bits are for testing and should normally be 0 |
| 02h | Timer 1 | Counter value (8 bits) |
| 03h | Timer 2 | Counter value (8 bits) |
| 04h | Flag control | b7: IRQRST (flag reset), b6: T1MSK, b5: T2MSK, b4: MSKEDS (EOS mask), b3: MSKBR (BUF mask), b1: ST2 (start Timer 2), b0: ST1 (start Timer 1) |
| 08h | CSM / note select | b7: CSM (composite sine wave mode), b6: NSEL. Shared with ADPCM Control 2 (Section 6.5) |
| 20h–35h | Operator characteristics 1 | AM, VIB, EGT, KSR, MULTI [3:0] |
| 40h–55h | Operator characteristics 2 | KSL [7:6], TL [5:0] |
| 60h–75h | Operator EG 1 | AR [7:4], DR [3:0] |
| 80h–95h | Operator EG 2 | SL [7:4], RR [3:0] |
| A0h–A8h | Ch.1–9 F-number low byte | F# [7:0] |
| B0h–B8h | Ch.1–9 control | KON [5], BLOCK [4:2], F# [1:0] |
| BDh | Rhythm / AM/VIB depth | AM depth [7], VIB depth [6], R (rhythm mode) [5], BD [4], SD [3], TOM [2], TC [1], HH [0] |
| C0h–C8h | Ch.1–9 connection | FB [3:1], C (algorithm) [0] |
| E0h–F5h | Operator waveform select | WS [1:0] (selects from 4 waveforms) |

### 6.4.1 Operator Registers

Each channel has two operators, the modulator and the carrier. The address of an operator register is the base address of the register group plus the slot offset determined by the channel and the operator.

| Channel | Modulator | Carrier |
|---|---|---|
| Ch.1 | 00h | 03h |
| Ch.2 | 01h | 04h |
| Ch.3 | 02h | 05h |
| Ch.4 | 08h | 0Bh |
| Ch.5 | 09h | 0Ch |
| Ch.6 | 0Ah | 0Dh |
| Ch.7 | 10h | 13h |
| Ch.8 | 11h | 14h |
| Ch.9 | 12h | 15h |

For example, to set the AR / DR of the Ch.5 carrier, write to 60h + 0Ch = 6Ch. The bit layout of each register is as follows.

![Bit layout of 20h–35h (operator characteristics 1)](images/bf_opl2_op_a.png)

![Bit layout of 40h–55h (operator characteristics 2)](images/bf_opl2_op_tl.png)

![Bit layout of 60h–75h (operator EG 1)](images/bf_opl2_op_eg1.png)

![Bit layout of 80h–95h (operator EG 2)](images/bf_opl2_op_eg2.png)

![Bit layout of E0h–F5h (operator waveform select)](images/bf_opl2_op_ws.png)

Many parameters have the same meaning as on the OPLL (Section 5.3.1). The points specific to the OPL2 are as follows.

- **TL**: One step is about 0.75 dB, allowing finer adjustment than the OPLL. In FM connection, the carrier's TL is the channel volume as it is.
- **WS (waveform select)**: Selects each operator's waveform from four kinds: sine, half-sine, full-wave rectified, and pulse. The full-wave rectified and pulse waveforms contain many harmonics, and using them on the modulation side gives a brighter sound. Note that **unless bit 5 of register 01h is set to 1, WS has no effect and all operators use the sine wave**.
- **EG**: The envelope shape is as shown in Figure 6.1, and the EGT bit selects the sustaining / percussive type, as on the OPLL. An operator with AR = 0 does not sound (its attack never starts).

![OPL2 envelope (AR / DR / SL / RR and EGT)](images/fig_eg_opl2.png)

### 6.4.2 Channel Registers

The pitch of each channel is specified by the F-number (10 bits) and BLOCK (3 bits). The sounding frequency f is given by:

- **f = F# × 2^(BLOCK − 1) × 49716 / 524288** (Hz)

Table 6.1 gives a guide to the correspondence with note names at BLOCK = 4.

### Table 6.1 Guide to Note Names and F-Numbers (BLOCK = 4)

| Note | Frequency (Hz) | F-Number |
|---|---|---|
| C4 | 261.6 | 345 |
| D4 | 293.7 | 387 |
| E4 | 329.6 | 435 |
| F4 | 349.2 | 460 |
| G4 | 392.0 | 517 |
| A4 | 440.0 | 580 |
| B4 | 493.9 | 651 |
| C5 | 523.3 | 690 |

![Bit layout of B0h–B8h (channel control)](images/bf_opl2_ch_ctrl.png)

![Bit layout of C0h–C8h (channel connection)](images/bf_opl2_ch_conn.png)

- **CON**: The connection method of the two operators. With 0 (FM connection), the modulator modulates the carrier, and the output is taken from the carrier only. With 1 (additive connection), the outputs of both operators are added, and the modulator works as an independent sound source with feedback.
- **FB**: Specifies the feedback amount into the modulator, in both FM and additive connection.

### 6.4.3 Rhythm Mode

Setting the R bit of BDh to 1 enters rhythm mode, and melody Ch.7–9 are replaced by rhythm sounds (BD / SD / TOM / TC / HH). BDh combines rhythm control with the AM / VIB depth common to all operators.

![Bit layout of BDh (rhythm / AM/VIB depth)](images/bf_opl2_rhythm.png)

The correspondence between the rhythm sounds and the channels, and how to play them, are the same as in the OPLL's rhythm mode (Section 5.5). Set the instrument parameters and the carrier TL (corresponding to VOL) of the corresponding channels (Ch.7–9), and the F-number for BD / TOM, in advance, then change the corresponding bit of BDh from 0 to 1 to play the sound.

## 6.5 ADPCM Section Registers

The registers of the ADPCM section are laid out at the same addresses as on the Y8950.

| Address | R/W | Contents | Bit composition / description |
|---|---|---|---|
| 07h | W | Control 1 | b7: START (starts memory playback), b6: REC (for recording, but recording is not supported on the Y8960; used to select the memory write mode), b5: MEMD (data source select: 1 = memory, 0 = data register), b4: REPT (repeat playback), b3: SPOFF (1 stops the ADPCM output), b0: RST (resets the flags and counters) |
| 08h | W | Control 2 | b1: 64K, b0: ROM (memory type specification; see the text for their effects). SMPL / DA/AD have no effect. Shares its address with the FM section's CSM / NSEL |
| 09h | W | Start address low byte | Address [7:0] |
| 0Ah | W | Start address high byte | Address [15:8] (Section 6.6) |
| 0Bh | W | Stop address low byte | Address [7:0] |
| 0Ch | W | Stop address high byte | Address [15:8] (Section 6.6) |
| 0Fh | RW | ADPCM data | Data port used to read and write the ADPCM memory (Section 6.6) |
| 10h | W | DELTA-N low byte | Playback rate [7:0] |
| 11h | W | DELTA-N high byte | Playback rate [15:8] |
| 12h | W | EG control | ADPCM output level. OUT = VOICE × value/256 (256 steps). Reset value FFh (maximum); writing 00h gives silence. Effective for the ADPCM output only |

![Bit layout of 07h (ADPCM Control 1)](images/bf_adpcm_ctrl1.png)

![Bit layout of 12h (EG control)](images/bf_adpcm_eg.png)

### Abolished registers

The following Y8950 functions do not exist on the Y8960. Writing to them has no effect.

| Address | Function on the Y8950 | Notes |
|---|---|---|
| 05h / 06h | Keyboard input/output | Abolished |
| 0Dh / 0Eh | Prescaler | Abolished (the playback rate is set directly with DELTA-N) |
| 15h / 16h | DAC data | Abolished |
| 17h | Shift register | Abolished |
| 18h / 19h / 1Ah | I/O control, I/O data, PCM data | Abolished |

The memory type specification of register 08h is effective on the Y8960 as well. When **64K** is set, memory access addresses are masked to the lower 16 bits and wrap around within a 64KB range. When **ROM** is set, memory reads return 0 and writes are ignored (emulating a ROM bank). The SMPL / DA/AD bits have no effect. Playback that supplies samples directly through the data register (CPU direct playback) is supported: start it with MEMD of Control 1 set to 0 (Section 6.6).

**Recording (REC) is not supported.** Setting START and REC does not record anything, and there is no analog input path. The REC bit is used only to select the memory write mode (Section 6.6).

## 6.6 ADPCM Memory

The ADPCM section has a **dedicated 256KB memory** within the SerialSRAM. This area is separate from the CPU bank area (BANK#0–31), and its size and configuration cannot be switched (fixed).

- **Address specification**: The start address (09h / 0Ah) and the stop address (0Bh / 0Ch) are specified in **units of 4 bytes**. The 16-bit value written to the registers × 4 gives the byte address, so the entire 256KB can be addressed. Playback and transfers cover the range from start address × 4 to stop address × 4 + 3; the stop side includes its last 4 bytes.
- **Playback**: When START is set (MEMD = 1, REC = 0), data is read out in sequence from the start address to the stop address and played back. When REPT is set, playback returns to the start address after reaching the stop address and repeats. When the stop address is reached, the EOS flag in the status is set.
- **CPU direct playback**: When Control 1 is set to START = 1, REC = 0, MEMD = 0 (80h written to 07h), the value written to the data register (0Fh) is decoded as ADPCM data instead of memory contents. One byte carries two samples (the upper nibble first); a byte is consumed at the moment its upper nibble is decoded, and BUF_RDY becomes 1 at that point. Writing to the data register makes BUF_RDY 0, so the CPU watches BUF_RDY and writes the next byte. Immediately after starting, BUF_RDY is still 1, so write the first byte first and only then start waiting for BUF_RDY. If the supply does not keep up, the last written byte is used repeatedly. There is no end-of-data check against the start / stop addresses, and EOS is never set. Playback continues until Control 1 is rewritten, and PCM_BSY stays 1 throughout. No access to the SRAM occurs. DELTA-N, the EG control (12h), SPOFF, and the pan (FFh) work exactly as in memory playback.
- **Reading and writing from the CPU**: Performed through register 0Fh (ADPCM data). In write mode (START = 0, REC = 1, MEMD = 1), each write to 0Fh automatically advances the internal address; when the end of the stop address is reached, the EOS flag is set and the pointer returns to the start address (if you keep writing after the last byte, the data is overwritten from the beginning. Writes made while the pointer is beyond the stop address are ignored). In read mode (START = 0, REC = 0, MEMD = 1), the first two reads after setting Control 1 are dummy reads, and the prefetched data is returned from the third read on. Reading past the stop address returns 0 and sets the EOS flag. Before starting a read or write, set the start/stop addresses and MEMD and the other bits of Control 1. The BUF_RDY flag in the status indicates whether data transfer is possible.
- **Playback rate**: Set with DELTA-N (10h / 11h, 16 bits). The larger the value, the faster the playback (the higher the sampling rate).
- Memory access from the CPU is possible even during playback; accesses to the SRAM are arbitrated internally.

## 6.7 Pan and Volume

### 6.7.1 Per-Channel Pan (New)

These registers are new on the Y8960 and specify the stereo positioning for each channel.

| Address | Contents |
|---|---|
| F6h–FEh | Pan of FM Ch.1–9 |
| FFh | Pan of the ADPCM |

- **1 is the far left, 128 is the center, and 255 is the far right**.
- The default is 128 (center).

### 6.7.2 Group Volume

On the mixer side there is a volume for the OPL2 group (the sum of the FM section + the ADPCM section) (MMIO 7FF9h, 0 = OFF – 128 = MAX) (see the chapter on the digital mixer). The division of roles is that the volume of each channel is adjusted with the FM section's TL or the ADPCM's EG control, and the volume of the group as a whole is adjusted with the mixer volume.

## 6.8 Interrupts

This block has, as interrupt sources, the timeouts of Timer 1 / Timer 2 and the ADPCM's EOS and BUF. Each flag can be masked with register 04h, and when a flag is set and an unmasked source exists, the interrupt signal is asserted. For details, see the chapter on interrupts.

## 6.9 Usage

### 6.9.1 Producing an FM Sound

The procedure for producing a single FM sound on the OPL2 is as follows.

1. Set the OPL2 bit of the I/O Enabler (MMIO 7FFFh) to 1 to enable the OPL2's I/O ports (Chapter 3).
2. If you use waveform selection, set bit 5 of register 01h to 1.
3. Set the parameters of both operators of the channel (each group of 20h–F5h).
4. Set FB and CON in the connection register (C0h–C8h).
5. Write the F-number low byte (A0h–A8h), write BLOCK and the upper bits of the F-number to the control register (B0h–B8h), and finally set KON to 1.

To stop the sound, set KON to 0. Sample OPL601 is a program that sets a simple FM instrument on Ch.1 and plays A4 (the file is included in the sample collection).

```
		;--- Ch.1 modulator (slot 00h) ---
		ld		a, 20h			; MULTI = 1
		ld		e, 01h
		call	opl2w
		ld		a, 40h			; TL = 24
		ld		e, 18h
		call	opl2w
		ld		a, 60h			; AR = 15, DR = 6
		ld		e, 0f6h
		call	opl2w
		ld		a, 80h			; SL = 6, RR = 6
		ld		e, 66h
		call	opl2w

		;--- Ch.1 carrier (slot 03h) ---
		ld		a, 23h			; MULTI = 1
		ld		e, 01h
		call	opl2w
		ld		a, 43h			; TL = 0 (maximum)
		ld		e, 00h
		call	opl2w
		ld		a, 63h			; AR = 15, DR = 4
		ld		e, 0f4h
		call	opl2w
		ld		a, 83h			; SL = 4, RR = 6
		ld		e, 46h
		call	opl2w

		; Ch.1 connection (C0h): FB = 4, CON = 0 (FM connection)
		ld		a, 0c0h
		ld		e, 08h
		call	opl2w

		; Ch.1 F-number (A0h/B0h): F# = 580, BLOCK = 4 -> A4
		ld		a, 0a0h
		ld		e, 44h			; F# low byte (580 = 244h)
		call	opl2w
		ld		a, 0b0h
		ld		e, 32h			; KON = 1, BLOCK = 4, F# high bits = 2
		call	opl2w
```

### 6.9.2 Playing ADPCM

ADPCM playback is performed after writing the data to memory first. The general procedure is as follows (for register details, see Sections 6.5 and 6.6).

1. Set the start / stop addresses (09h–0Ch) in 4-byte units.
2. Set write mode (START = 0, REC = 1, MEMD = 1) in Control 1 (07h), and write the ADPCM data to the data register (0Fh) in order. The address advances automatically.
3. Set the playback rate in DELTA-N (10h / 11h).
4. Setting playback mode (START = 1, REC = 0, MEMD = 1) in Control 1 starts playback. To repeat, also set REPT.
5. The end of playback can be detected with the EOS flag of the status (Section 6.3).

Regarding the relationship between the playback rate and pitch, DELTA-N = 8000h gives a sampling rate of about 24.9 kHz. To play a sample back at its original speed, choose the DELTA-N that corresponds to the sampling rate used when encoding.

### 6.9.3 Playing ADPCM with Data Supplied Directly from the CPU

Playback is also possible without transferring the data to memory, by having the CPU keep supplying the data (CPU direct playback, Section 6.6). The procedure is as follows.

1. Set the playback rate in DELTA-N (10h / 11h).
2. Setting CPU direct playback (START = 1, REC = 0, MEMD = 0) in Control 1 (07h) starts playback.
3. Immediately write the first byte to the data register (0Fh). BUF_RDY is still 1 right after starting, so write it without waiting.
4. From then on, write the next byte to the data register each time BUF_RDY in the status becomes 1.
5. To stop, rewrite Control 1 (set START = 0, or set the RST bit).

With this method, the end of playback cannot be detected with EOS. The sample program ADCPU, which plays the contents of a file using this method, is included in the y8960_adpcm_test folder of the Y8960_Cartridge repository.

# Chapter 7 SCC

This chapter describes the SCC (waveform memory sound source) built into the Y8960 and its registers. The SCC is a block dedicated to memory-mapped I/O, and it also handles the bank control of the MegaROM. The bank control mechanism itself was described in Chapter 3, "3.5 Memory Map and Bank Control". This chapter mainly covers the registers as a sound source, and touches on bank control only within the scope related to the sound source.

## 7.1 Overview

The SCC of the Y8960 is based on IKASCC (a reproduction core of the Konami SCC). Its main specifications are as follows.

- Waveform memory sound source with 5 channels (Ch.A–Ch.E)
- Each channel has 32 bytes of waveform memory and produces sound by repeatedly reading out its contents. However, Ch.D and Ch.E share a single waveform memory (the same configuration as the original SCC)
- A frequency (12-bit period value) and a volume (4 bits) can be set for each channel
- As an extension unique to the Y8960, stereo positioning (pan) can be specified for each channel (Section 7.7)
- It also handles MegaROM bank control (the SCC banks), and has the role of making the cartridge's SerialSRAM appear in the MSX memory space

No I/O ports are assigned to the SCC. All registers are accessed by making the SCC register bank appear in the memory space.

## 7.2 How the SCC Register Bank Appears

The SCC registers appear within the bank in which BANK#63 has been made to appear (see Chapter 3, Section 3.5.3).

| Condition | Where it appears | Base address of the registers |
|---|---|---|
| BANK#63 made to appear in BANK2 (regardless of the RAM mode) | 8000h–9FFFh | 9800h–9FFFh |
| BANK#63 made to appear in BANK1 with RAM mode = 1 | 6000h–7FFFh | 7800h–7FFFh |

In the following description, the addresses for the case where it is made to appear in BANK2 (98xxh) are mainly used; for BANK1, read them as 78xxh.

## 7.3 Register Map

The arrangement of the registers within the SCC register bank is as follows. Addresses are given in the order: when appearing in BANK2 / when appearing in BANK1.

| Address | R/W | Contents |
|---|---|---|
| 9800h–981Fh / 7800h–781Fh | R/W | Ch.A waveform memory (32 bytes) |
| 9820h–983Fh / 7820h–783Fh | R/W | Ch.B waveform memory (32 bytes) |
| 9840h–985Fh / 7840h–785Fh | R/W | Ch.C waveform memory (32 bytes) |
| 9860h–987Fh / 7860h–787Fh | R/W | Ch.D/Ch.E waveform memory (32 bytes, shared) |
| 9880h–9881h / 7880h–7881h | W | Ch.A frequency register |
| 9882h–9883h / 7882h–7883h | W | Ch.B frequency register |
| 9884h–9885h / 7884h–7885h | W | Ch.C frequency register |
| 9886h–9887h / 7886h–7887h | W | Ch.D frequency register |
| 9888h–9889h / 7888h–7889h | W | Ch.E frequency register |
| 988Ah / 788Ah | W | Ch.A volume |
| 988Bh / 788Bh | W | Ch.B volume |
| 988Ch / 788Ch | W | Ch.C volume |
| 988Dh / 788Dh | W | Ch.D volume |
| 988Eh / 788Eh | W | Ch.E volume |
| 988Fh / 788Fh | W | Output switch |
| 9890h–989Fh / 7890h–789Fh | W | Mirror of 9880h–988Fh |
| 98A0h–98BFh / 78A0h–78BFh | − | Unused (do not access) |
| 98C0h–98DFh / 78C0h–78DFh | − | Unused (do not access) |
| 98E0h–98FFh / 78E0h–78FFh | W | Mode register (a single byte in substance) |
| 9900h / 7900h | W | Ch.A stereo positioning (pan) |
| 9901h / 7901h | W | Ch.B stereo positioning (pan) |
| 9902h / 7902h | W | Ch.C stereo positioning (pan) |
| 9903h / 7903h | W | Ch.D stereo positioning (pan) |
| 9904h / 7904h | W | Ch.E stereo positioning (pan) |
| 9905h–9FFFh / 7905h–7FEFh | − | Unused (do not access. Reserved for the future) |

Registers other than the waveform memory are write-only. The result of reading them is undefined. Do not read from or write to the regions marked "do not access".

## 7.4 Waveform Memory

The waveform memory of each channel is 32 bytes and stores signed waveform data of 8 bits per sample. While sound is being generated, the channel repeatedly reads out the waveform memory from the beginning and outputs it as a waveform of 32 samples per period. A sample value of 0 is the center of the waveform (the level at silence), and you write data that swings to positive and negative values. Figure 7.1 shows examples of basic waveforms.

![Examples of basic waveforms to write into the waveform memory (32 samples)](images/fig_scc_wave.png)

- The waveform memory can be read and written. If it is rewritten during sound generation, the waveform changes from that point on
- Ch.D and Ch.E share the waveform memory. Writing to 9860h–987Fh changes the instrument of both channels at the same time. To give them independent waveforms, some contrivance is needed, such as using only one of the channels

How the waveform is drawn determines the sound. A sine wave gives a soft sound without harmonics, while a square or sawtooth wave gives a bright sound rich in harmonics. Since an arbitrary waveform can be written, one period cut out of an instrument sound can also be used. The sine-wave data is included in the sample (SCC701) in Section 7.10.

## 7.5 Frequency Registers and Volume

The frequency register is 2 bytes per channel: the lower 8 bits of the period value are written to the lower address, and the upper 4 bits to the upper address (a 12-bit value).

The sound generation frequency is determined by the following formula, as on the original SCC.

> Sound generation frequency = 3.579545 MHz ÷ (32 × (period value + 1))

The larger the period value, the lower the sound. Table 7.1 gives a guide to the correspondence with note names.

### Table 7.1 Guide to Note Names and Period Values

| Note | Frequency (Hz) | Period Value |
|---|---|---|
| C4 | 261.6 | 426 |
| D4 | 293.7 | 380 |
| E4 | 329.6 | 338 |
| F4 | 349.2 | 319 |
| G4 | 392.0 | 284 |
| A4 | 440.0 | 253 |
| B4 | 493.9 | 225 |
| C5 | 523.3 | 213 |

The volume register is 1 byte per channel, of which the lower 4 bits are valid (0 = silence, 15 = maximum).

## 7.6 Output Switch

The output switch at 988Fh controls the output on/off of each channel.

| Bit | Target | Meaning |
|---|---|---|
| bit0 | Ch.A | 1 = output on, 0 = output off |
| bit1 | Ch.B | Same as above |
| bit2 | Ch.C | Same as above |
| bit3 | Ch.D | Same as above |
| bit4 | Ch.E | Same as above |
| bit7–5 | − | Not used |

![Bit layout of 988Fh (output switch)](images/bf_scc_outsw.png)

The value at reset is all bits 0, with all channels' output off. Setting only the frequency and volume does not produce sound. Set the bit of the channel to be sounded to 1.

## 7.7 Stereo Positioning (Pan)

9900h–9904h are per-channel stereo positioning registers added in the Y8960. The positioning is specified with 8 bits for each channel.

- 1 = far left
- 128 = center (the initial value at reset)
- 255 = far right

They are write-only (the read result is undefined). At reset, all channels return to 128 (center).

## 7.8 Mode Register

98E0h–98FFh is the mode register. The substance is a single byte for the entire region, and writing to any address within the range updates the same register. This corresponds to the test-related registers of the original SCC, and a normal performance program does not need to rewrite it (use it with the reset value of 00h as it is).

- [TBC] The function definition of each bit of the mode register is not given in the current specification documents. Details will be added to this section as they become known.

## 7.9 Relationship to Bank Control

The SCC core is a sound source and, at the same time, is responsible for the memory bank control of the entire cartridge. Only the programming points are listed here. For details, see Chapter 3, Section 3.5.

- There are four banks, 4000h–5FFFh (BANK0), 6000h–7FFFh (BANK1), 8000h–9FFFh (BANK2), and A000h–BFFFh (BANK3), each 8 KB
- The arrangement of the bank registers changes with RAM mode. With RAM mode = 0, writing is to addresses within each bank (5000h–57FFh, 7000h–77FFh, 9000h–97FFh, B000h–B7FFh); with RAM mode = 1, writing is to 4XFCh–4XFFh. The mode register (RAM mode specification) is at 4XFBh and appears at all times
- BANK#0–#15 are treated as ROM banks, and BANK#16–#31 as RAM banks. Writing to a RAM bank is valid only when RAM mode = 1
- BANK#63 is dedicated to the SCC register bank (Section 7.2). Even if it is made to appear in another bank, it does not function as registers
- At reset, BANK#0–#3 appear in BANK0–BANK3 in order, and RAM mode = 0

## 7.10 Procedure for Producing Sound

1. Make BANK#63 appear in BANK2 (or, with RAM mode = 1, in BANK1)
2. Write waveform data into the waveform memory
3. Set the frequency register and volume
4. If necessary, set the stereo positioning (9900h–9904h)
5. Set the bit of the channel to be sounded to 1 with the output switch (988Fh)

Sample SCC701 is a program that writes a sine wave to Ch.A and plays A4 (the file is included in the sample collection). You can see that the arrangement of the waveform data becomes the sound as it is.

```
		; Make BANK#63 (the SCC register bank) appear in BANK2 (8000h-9FFFh)
		; With RAM mode = 0, writing to 9000h switches the BANK2 bank
		ld		a, 3fh
		ld		[9000h], a

		; Write a sine wave into the Ch.A waveform memory (9800h-981Fh)
		ld		hl, sine_wave
		ld		de, 9800h
		ld		bc, 32
		ldir

		; Ch.A frequency (9880h/9881h): period value = 253 -> A4 (about 440 Hz)
		ld		a, 0fdh
		ld		[9880h], a
		ld		a, 00h
		ld		[9881h], a

		; Ch.A volume (988Ah) = 15
		ld		a, 0fh
		ld		[988ah], a

		; Output switch (988Fh): turn Ch.A on
		ld		a, 01h
		ld		[988fh], a
```

# Chapter 8 OPM

This chapter describes the OPM (equivalent to the YM2151) FM sound source built into the Y8960. The OPM was added to the Y8960's sound source blocks later, and was not described in the earlier draft documentation. This chapter is the official description in this manual.

## 8.1 Overview

The Y8960's OPM is based on IKAOPM (a reproduction core of the YM2151). Its main specifications are as follows.

- 4-operator FM sound source, 8 channels
- The algorithm (connection form) and feedback can be set for each channel
- Stereo output. For each channel, whether it is output to the left and right (the RL bits) can be specified
- Equipped with an LFO (for vibrato/tremolo) and a noise generator
- Contains Timer A / Timer B and can generate interrupts

The register configuration is compatible with the YM2151. In addition to the access methods and the Y8960-specific implementation (the write queue and so on), this chapter also explains the meaning of all registers.

## 8.2 Access Methods

The OPM has two access methods: I/O ports and memory-mapped I/O.

| Destination | Address register | Data register | Notes |
|---|---|---|---|
| I/O port | 7Eh | 7Fh | The status can be obtained by reading the data side |
| Memory-mapped I/O | 7FFBh | 7FFCh | Write-only |

The procedure for writing to a register is as follows.

1. Write the number of the OPM register to be written to the address register
2. Write the value to the data register

When using the I/O ports (7Eh / 7Fh), the I/O ports must be enabled in advance (the OPM bit of I/O Enabler2; see Chapter 3, Section 3.3). They are disabled immediately after power-on. Memory-mapped I/O can be used while the window of Chapter 3, Section 3.4 is open.

## 8.3 Write Queue and /WAIT

The YM2151 has the property that "if the next write arrives before the processing of the previous write has finished, that write is dropped," and on the actual chip it was necessary to write while watching the BUSY bit in the status.

In the Y8960's OPM, this restriction is absorbed on the hardware side.

- Writes from the CPU are stored in sequence in an internal queue (16 entries)
- Writes are taken from the queue one at a time, in step with the YM2151's processing timing, and written to the core (the hold times required for the address write and the data write respectively are ensured)
- When the queue becomes full, the CPU is made to wait by the slot's /WAIT signal. No write is ever dropped

A program can therefore write continuously at the pace of ordinary OUT instructions, without strictly monitoring BUSY. Note, however, that the queue depth is limited, so rewriting a large number of registers in a short time causes waits due to /WAIT, which lengthens the CPU processing time.

The BUSY bit of the status register (Section 8.4) is 1 while unprocessed writes remain in the queue or while the core is processing. To confirm that "all writes have been applied to the core," wait until BUSY becomes 0.

## 8.4 Status Register

Reading I/O port 7Fh returns the status register (it cannot be read from the memory-mapped I/O side).

| Bit | Name | Meaning |
|---|---|---|
| bit7 | BUSY | 1 = write processing in progress (writes remain in the queue, or the core is processing) |
| bit1 | FBT | Timer B overflow flag |
| bit0 | FTA | Timer A overflow flag |
| Others | － | 0 |

For how to clear the timer flags, see Section 8.7.

## 8.5 Register Map

The OPM's registers are laid out at the same addresses as on the YM2151. The details of each register are described from Section 8.5.1 onward.

| Register | Contents |
|---|---|
| 01h | Test register (normally left at 00h) |
| 08h | Key on / key off (specifies the channel and operators) |
| 0Fh | Noise control (NE: noise enable, NFRQ: noise frequency) |
| 10h | Timer A counter (upper 8 bits) |
| 11h | Timer A counter (lower 2 bits) |
| 12h | Timer B counter |
| 14h | Timer control (CSM, flag reset, interrupt enable, load) |
| 18h | LFO frequency |
| 19h | LFO amplitude modulation depth (AMD) / phase modulation depth (PMD). bit7 selects the target, and the value is written in two separate writes |
| 1Bh | LFO waveform select |
| 20h–27h | Channel control (RL: left/right output, FB: feedback amount, CON: algorithm) |
| 28h–2Fh | Key code (KC) for each channel |
| 30h–37h | Key fraction (KF) for each channel |
| 38h–3Fh | PMS (phase modulation sensitivity) / AMS (amplitude modulation sensitivity) for each channel |
| 40h–5Fh | Operator DT1 (detune 1) / MUL (frequency multiplier) |
| 60h–7Fh | Operator TL (total level) |
| 80h–9Fh | Operator KS (key scaling) / AR (attack rate) |
| A0h–BFh | Operator AME (AM enable) / D1R (first decay rate) |
| C0h–DFh | Operator DT2 (detune 2) / D2R (second decay rate) |
| E0h–FFh | Operator D1L (first decay level) / RR (release rate) |

In the per-channel registers (20h–3Fh), the lower 3 bits of the address select the channel; in the per-operator registers (40h–FFh), the lower 5 bits of the address select the channel and the operator (the same rules as the YM2151).

### 8.5.1 Global Registers

**Key On / Key Off (08h)**

Starting and stopping a sound is done with this register, independent of the instrument parameters. Because it can be specified per operator, uses such as keying off only the output-side (carrier-side) operators of an algorithm to change the tail of the sound are also possible.

![Bit layout of 08h (key on / key off)](images/bf_opm_kon.png)

**Noise Control (0Fh)**

![Bit layout of 0Fh (noise control)](images/bf_opm_noise.png)

When NE is 1, the output of Ch.8's C2 is replaced by noise. The volume and envelope of the noise are controlled by the parameters of Ch.8's C2 (TL and its EG).

**Timer Control (14h) and Counters (10h–12h)**

![Bit layout of 14h (timer control)](images/bf_opm_timer_ctrl.png)

The counter value of Timer A is 10 bits: write the upper 8 bits to 10h and the lower 2 bits to the lower bits of 11h. Timer B is the 8 bits of 12h. As a guide, the period of Timer A is (1024 − value) × about 17.9 µs, and that of Timer B is (256 − value) × about 286 µs. For usage, see Section 8.7.

**LFO (18h, 19h, 1Bh)**

The LFO is a low-frequency oscillator common to all channels, used for vibrato (phase modulation) and tremolo (amplitude modulation). 18h is the frequency (the larger the value, the faster; the range is roughly 0.008 Hz to 36 Hz), and 1Bh is the waveform. The modulation depths are set in 19h: bit 7 selects whether the write is AMD (amplitude modulation depth) or PMD (phase modulation depth), and the two are written separately. How the LFO actually affects each channel is determined by the per-channel PMS / AMS (Section 8.5.2) and the per-operator AME (Section 8.5.3).

![Bit layout of 19h (LFO modulation depth)](images/bf_opm_amd_pmd.png)

![Bit layout of 1Bh (LFO waveform select)](images/bf_opm_lfo_wf.png)

The **test register (01h)** should normally be left at 00h.

### 8.5.2 Channel Registers

![Bit layout of 20h–27h (channel control)](images/bf_opm_ch.png)

CON (algorithm) selects the connection pattern of the four operators from eight kinds. Figure 8.1 shows the connections and which operators become outputs. Feedback of the amount set by FB is applied to M1 in all algorithms. Algorithms with more series stages produce more complex sounds with more harmonics, while those with more parallel connections are suited to layering several sounds.

![Algorithms (operator connections for CON 0–7; ▼ marks an operator that is output)](images/fig_opm_alg.png)

The pitch is specified by KC and KF. The NOTE code of KC takes the values in Table 8.1 within an octave. Note that only C uses code 14 on the lower-octave side (for example, C4 is OCT = 3, NOTE = 14, KC = 3Eh).

![Bit layout of 28h–2Fh (key code)](images/bf_opm_kc.png)

### Table 8.1 NOTE Codes and KC Examples

| Note | NOTE Code | KC (Example) |
|---|---|---|
| C | 14 | 3Eh (C4) |
| C# | 0 | 40h (C#4) |
| D | 1 | 41h |
| D# | 2 | 42h |
| E | 4 | 44h |
| F | 5 | 45h |
| F# | 6 | 46h |
| G | 8 | 48h |
| G# | 9 | 49h |
| A | 10 | 4Ah (A4 = 440 Hz) |
| A# | 12 | 4Ch |
| B | 13 | 4Dh |

![Bit layout of 30h–37h (key fraction)](images/bf_opm_kf.png)

![Bit layout of 38h–3Fh (PMS / AMS)](images/bf_opm_pmsams.png)

PMS / AMS are the sensitivity with which that channel receives LFO modulation. On a channel with PMS = 0 or AMS = 0, no modulation is applied even if the LFO depth (19h) is set.

### 8.5.3 Operator Registers

The address of an operator register (40h–FFh) is the base address of the group plus "operator offset + channel number".

| Operator | Offset |
|---|---|
| M1 | 00h |
| M2 | 08h |
| C1 | 10h |
| C2 | 18h |

For example, the TL of C1 of Ch.3 (channel number 2) is 60h + 10h + 2 = 72h. The bit layout of each register is as follows.

![Bit layout of 40h–5Fh (DT1 / MUL)](images/bf_opm_dt1mul.png)

![Bit layout of 60h–7Fh (TL)](images/bf_opm_tl.png)

![Bit layout of 80h–9Fh (KS / AR)](images/bf_opm_ksar.png)

![Bit layout of A0h–BFh (AME / D1R)](images/bf_opm_amed1r.png)

![Bit layout of C0h–DFh (DT2 / D2R)](images/bf_opm_dt2d2r.png)

![Bit layout of E0h–FFh (D1L / RR)](images/bf_opm_d1lrr.png)

- **MUL / DT1 / DT2**: An operator's frequency is basically the channel's base frequency × MUL, with DT1 and DT2 adding a shift. DT1 is for fine adjustment: 0 and 4 mean no shift, 1–3 shift in the + direction in three steps, and 5–7 in the − direction. DT2 is a coarse shift: the pitch shift is 0 = none, 1 = about +600 cents, 2 = about +781 cents, 3 = about +950 cents. Changing the frequency ratio on the modulator side changes the harmonic structure.
- **TL**: On output-side (carrier-side) operators it is the volume itself; on modulation-side operators it determines the modulation depth (the brightness of the sound).
- **Envelope**: A four-stage structure proceeding in the order AR → D1R → D1L → D2R (Figure 8.2). While the key is on, the envelope continues to decay at the speed of D2R even after reaching D1L (with D2R = 0, D1L is held). On key-off, it decays at the speed of RR. An operator with AR = 0 does not sound.

![OPM envelope (AR / D1R / D1L / D2R / RR)](images/fig_opm_eg.png)

## 8.6 Stereo Output (RL Bits)

Using the RL bits of registers 20h–27h, you can specify, for each channel, whether it is sent to the left output, the right output, or both.

| bit7 (R) | bit6 (L) | Output |
|---|---|---|
| 0 | 0 | Output to neither left nor right |
| 0 | 1 | Left only |
| 1 | 0 | Right only |
| 1 | 1 | Both left and right (center) |

The OPM's stereo positioning consists entirely of these RL bits; there is no fine per-channel pan setting on the mixer side (for the mixer, see Chapter 9). If fine positioning is required, one approach is to assign the same instrument to two channels and vary the TL of the left and right channels to reproduce it.

## 8.7 Timers and Interrupts

The OPM contains Timer A and Timer B.

- Timer A has a 10-bit counter value and Timer B an 8-bit counter value; they are set with registers 10h–12h
- Register 14h controls the loading (count start) of each timer, interrupt enable, and flag reset
- When a counter overflows, the corresponding flag (FTA / FBT) in the status register (Section 8.4) is set. If interrupts are enabled, the cartridge's interrupt output also becomes active (see Chapter 10, Section 10.4)
- A flag is set only while the corresponding timer's interrupt is enabled. If the interrupt is not enabled, the flag stays 0 even on overflow. Therefore, even when you do not use interrupts, you must set the interrupt enable bit to poll the flags
- Flags are cleared with the flag reset bits of register 14h. Until cleared, a flag remains set and the interrupt continues

In addition to using the timers as a timing source for periodic processing, the CSM mode (a function that performs key-on in synchronization with a Timer A overflow) can also be used, as on the YM2151.

## 8.8 Usage

The procedure for producing a single sound on the OPM is as follows.

1. Set the OPM bit of the I/O Enabler (MMIO 7FFFh) to 1 to enable the OPM's I/O ports (Chapter 3).
2. Set RL, FB, and CON (algorithm) in the channel control register (20h–27h).
3. Set the pitch with KC / KF (28h–37h).
4. Set the parameters of the four operators (40h–FFh).
5. Write the operator selection and the channel number to the key-on register (08h) to start the sound.

To stop the sound, write the same channel number to 08h with the operator selection set to 0. Thanks to the write queue (Section 8.3), the many writes of steps 2–4 can also be issued in succession without watching BUSY.

Sample OPM801 is a program that sets an ALG0 instrument (four operators in series) on Ch.1 and plays A4 (the file is included in the sample collection). Setting the four operators is a repetition of the same pattern, so the part for M1 and the start of the sound are quoted here.

```
		; Ch.1 channel control (20h): RL = both, FB = 4, CON = 0 (ALG0)
		ld		a, 20h
		ld		e, 0e0h
		call	opmw
		; Ch.1 KC (28h) = 4Ah (A4), KF (30h) = 0
		ld		a, 28h
		ld		e, 4ah
		call	opmw
		ld		a, 30h
		ld		e, 00h
		call	opmw

		;--- M1 (offset +0) ---
		ld		a, 40h			; DT1 = 0, MUL = 1
		ld		e, 01h
		call	opmw
		ld		a, 60h			; TL = 24
		ld		e, 18h
		call	opmw
		ld		a, 80h			; KS = 0, AR = 28
		ld		e, 1ch
		call	opmw
		ld		a, 0a0h			; D1R = 10
		ld		e, 0ah
		call	opmw
		ld		a, 0c0h			; DT2 = 0, D2R = 4
		ld		e, 04h
		call	opmw
		ld		a, 0e0h			; D1L = 6, RR = 6
		ld		e, 66h
		call	opmw
		… (M2, C1, and C2 are set in the same way at addresses +8, +16, and +24)

		; Key on (08h): all operators, channel 0
		ld		a, 08h
		ld		e, 78h
		call	opmw
```

# Chapter 9 Digital Mixer

This chapter describes the digital mixer that combines the outputs of all of the Y8960's sound sources, and the I2S output in the final stage.

## 9.1 Overview

All of the Y8960's sound source blocks support stereo, and their outputs are summed by a digital mixer inside the FPGA and sent via an I2S interface to a DAC (PCM5102A). No mixing is performed in the analog stage.

The mixer inputs are the following five groups.

| Group | Contents | Stereo method | Details |
|---|---|---|---|
| SSG | The sum of the outputs of the SSG × 2 cores | Pan for each channel | Chapter 4 |
| OPLL | OPLL-EX | Pan for each channel | Chapter 5 |
| OPL2 | OPL2 and ADPCM summed internally | Pan for each channel (including ADPCM) | Chapter 6 |
| SCC | SCC 5 channels | Pan for each channel | Chapter 7 |
| OPM | OPM 8 channels | RL bits for each channel (left/right output specification) | Chapter 8 |

The pan (stereo positioning) settings are made on the side of each sound source block. The role of the mixer is volume adjustment and summation for each group, and applying the master volume.

Note that ADPCM has no independent group volume. The ADPCM volume follows the volume of the OPL2 group (Section 9.2).

## 9.2 Per-Group Volumes and the Master Volume

The volume registers are memory-mapped I/O (they can be written when the window of Chapter 3, Section 3.4 is open). All of them are write-only.

| Address | Contents |
|---|---|
| 7FF7h | SSG Volume |
| 7FF8h | OPLL Volume |
| 7FF9h | OPL2 Volume (including ADPCM) |
| 7FFAh | SCC Volume |
| 7FFDh | OPM Volume |
| 7FFEh | Master Volume |

Each register is 8 bits, and the meanings of the values are as follows.

- 0 = OFF (that group becomes silent)
- 1–128 = volume. 128 is the maximum
- If a value of 129–255 is written, it is treated the same as 128 (the maximum)

The initial value at reset is 128 (the maximum) for all registers.

The processing inside the mixer is performed in the following order.

1. Multiply the input of each group by the volume of that group
2. Sum the five groups, with 24-bit saturation
3. Multiply the summed result by the master volume and output it

## 9.3 Saturation and Clipping

The summation is 24-bit saturation processing. Values that exceed the range are clamped to the maximum value / minimum value (clip), so no abnormal sound is produced by wraparound, but the waveform is flattened and becomes distorted.

No attenuation is applied after the summation. Even a single group playing a 16-bit full-scale source at group volume 128 (×1) reaches −6dBFS at the output, so playing multiple groups simultaneously at high volumes clips easily.

If all groups are played simultaneously at high volumes, clipping is more likely to occur. If distortion is a concern, lowering the group volumes while taking the balance on the group volume side, rather than with the master volume, makes it easier to preserve the relative balance of each sound source.

## 9.4 I2S Output

The mixer output (24-bit stereo) is sent to the DAC via the I2S interface.

| Item | Specification |
|---|---|
| Format | I2S (MSB first) |
| Slot configuration | 32 bits × 2 channels. The valid data is 24 bits |
| BCLK | Approx. 6.04 MHz |
| LRCLK (sampling frequency) | Approx. 94.4 kHz (obtained by dividing the I2S clock of approx. 24.16 MHz) |
| MCLK | Not output (the DAC is configured to operate without MCLK) |

Programs normally do not need to be aware of I2S. The settings related to volume and pan are made with the registers in Section 9.2 and the registers of each sound source block.

# Chapter 10 System Functions

This chapter describes the system functions other than the sound source blocks — the System Controller and the MSX-TIMER — and also summarizes the reset operation, the overall picture of interrupts, and notes on use.

## 10.1 System Controller

The System Controller is a block that provides identification of the cartridge and access to the built-in Config ROM (SPI flash). It uses I/O ports 40h–4Fh. This port range is outside the scope of the sound source blocks' I/O enablers (Chapter 3, Section 3.3), and the System Controller has its own enabling procedure.

### 10.1.1 Enabling and Device Identification

At power-on, the System Controller is in the disabled state and does not respond to reads of 40h–4Fh. The procedure for enabling and identification is as follows.

1. Writing 80h to I/O 40h enables the System Controller
2. In the enabled state, reading I/O 40h returns 7Fh (all bits of 80h inverted). A program can confirm the presence of the System Controller from this value
3. Write a device ID to I/O 41h (device select). Only the device whose own ID matches responds to a read of 41h with "all bits of the ID inverted" (because another device may respond, a device that does not match is designed not to respond)
4. The ID of the Y8960 Cartridge is 02h. After writing 02h to 41h, if reading 41h returns FDh, the Y8960's System Controller has been selected

The assignment of device IDs is as follows.

| ID | Device |
|---|---|
| 00h | N/A |
| 01h | V9968 Cartridge |
| 02h | Y8960 Cartridge (this cartridge) |
| 03h | FPGA MSXtR CPU Board |
| 04h | FPGA MSXtR VDP Board |
| 05h | FPGA MSXtR SND Board |
| 06h–FEh | Reserved |
| FFh | N/A |

### 10.1.2 Function Select

I/O 42h is the function select. It functions when the System Controller is enabled and 02h (the device itself) is selected in 41h.

| Value written to 42h | Function |
|---|---|
| 01h | Config ROM Reader/Writer |
| Others | N/A |

After writing 01h, reading 42h returns FEh. If a value other than 01h is written, FFh is returned. While the System Controller is disabled, or while another device is selected, there is no response to reads of 42h.

### 10.1.3 Config ROM Reader/Writer

When function 01h is selected, I/O 43h–47h are assigned as follows.

| I/O | Meaning |
|---|---|
| 43h | Lowest 8 bits of the address |
| 44h | Middle 8 bits of the address |
| 45h | Highest 8 bits of the address |
| 46h | Command (reading returns FFh) |
| 47h | Data |
| 48h–4Fh | Reserved (no response to reads or writes) |

Set the Config ROM address (24 bits) in 43h–45h, then write a command to 46h to operate it.

| Command | Operation |
|---|---|
| 00h | Read. After completion, the data can be read from 47h |
| 01h | Write |
| 02h | Sector erase (in units of 64KB. The lower 16 bits of the address are ignored) |
| 03h | Chip erase |
| 04h | Status read. After completion, status register 1 of the Config ROM can be read from 47h (bit0 = BUSY) |
| 05h–FFh | Reserved (ignored) |

For a write, a sector erase, and a chip erase, issuing the command is all that is done. Confirm completion by repeatedly reading the status until BUSY = 0.

Note that while a command is executing (a few µs), the System Controller does not accept I/O accesses (no /WAIT is asserted during this time). After writing a command to 46h, keep reading 40h and perform the next access only after 7Fh is returned.

- [TBC] A version display register, a function for setting the boot mode, and a write-protect function for the Config ROM could not be confirmed in the current specification documents or RTL. Whether they exist is being checked.

### 10.1.4 Boot Copy at Power-On

At power-on, the System Controller automatically copies 7E0000h–7FFFFFh (128KB) of the Config ROM to 00000h–1FFFFh of the SerialSRAM. During the copy, the other modules are stopped, and the MSX itself is also stopped by the slot's /WAIT signal. Therefore, by the time a program on the MSX side starts running, the copy has already completed, and there is no need to wait on the program side.

With this mechanism, the cartridge's programs/data are placed in the SerialSRAM from immediately after power-on, and can be executed and referenced via the SCC banks (Chapter 3, Section 3.5).

## 10.2 MSX-TIMER

The MSX-TIMER is a block that contains four independent timer cores. It can be used to generate periodic interrupts and to measure elapsed time.

### 10.2.1 Ports and Access Methods

It uses I/O ports B0h–B3h. It is disabled at power-on, so enable it in advance by setting the TIMER bit (bit7) of I/O Enabler2 to 1 (see Chapter 3, Section 3.3).

| Port | Read | Write |
|---|---|---|
| B0h | Index (current value) | Sets the index |
| B1h | The value of the register pointed to by the index | Sets the value of the register pointed to by the index |
| B2h | Interrupt flags (bit3–0 correspond to cores 3–0; the upper 4 bits are 0) | Flag clear (writing 1 to bit3–0 clears the flag of the corresponding core) |
| B3h | The current count value of the selected core | Selects the core whose counter is to be read (value 0–3) |

The format of the index is as follows.

| Bit | Meaning |
|---|---|
| bit3–2 | Core number (0–3) |
| bit1–0 | Register number within the core (0–2; next section) |

![Bit layout of B0h (index)](images/bf_timer_index.png)

![Bit layout of B2h (interrupt flags)](images/bf_timer_flag.png)

If a value other than 0–3 (a value in which any of bit7–2 is 1) is written as the core selection of B3h, reading B3h returns FFh.

Reading a register (B1h) takes a few cycles for internal processing, during which the hardware inserts a wait. No special wait processing is required on the program side.

### 10.2.2 Registers Within a Core

Each timer core has the following registers.

| Register number | Name | Contents |
|---|---|---|
| 0 | Mode register | bit7: interrupt enable, bit6–4: resolution (RESO), bit0: repeat |
| 1 | Count register | Count value until time-up (8 bits) |
| 2 | Control register | bit0: count enable, bit1: counter clear (writing 1 returns the counter to 0) |
| 3 | － | Not implemented (reads return 00h) |

![Bit layout of the mode register](images/bf_timer_mode.png)

![Bit layout of the control register](images/bf_timer_ctrl.png)

The mode register, the count register, and the control register can all be read back.

### 10.2.3 Operation

- Setting bit0 of the control register to 1 starts counting
- RESO selects the prescaler and determines the unit time of one count. The counter has a wide bit width internally, and the range used for comparison switches according to RESO, so the unit time becomes 4 times longer each time RESO increases by 1
- When the count value reaches the value of the count register, time-up occurs and the interrupt flag is set
- If repeat (mode register bit0) is 0, the timer is one-shot, and counting stops at the same time as time-up. If it is 1, the counter automatically returns to 0 and counting repeats
- The interrupt flag is set regardless of whether interrupts are enabled. The flag is held until it is explicitly cleared by a write to B2h. While interrupt enable is 1, if there is a core whose flag is set, the cartridge's interrupt output becomes active (Section 10.4)
- The current count value can be read with B3h (see Section 10.2.1)

The unit time is 2^(10 + 2×RESO) ÷ f, where f is the core's clock. The time until time-up is approximately (count value + 1) × unit time. The table below gives reference values calculated with f = 42.95454 MHz.

| RESO | Unit time (reference) | Period at count value 255 (reference) |
|---|---|---|
| 0 | Approx. 23.8 µs | Approx. 6.1 ms |
| 1 | Approx. 95.4 µs | Approx. 24 ms |
| 2 | Approx. 382 µs | Approx. 98 ms |
| 3 | Approx. 1.53 ms | Approx. 391 ms |
| 4 | Approx. 6.10 ms | Approx. 1.56 s |
| 5 | Approx. 24.4 ms | Approx. 6.25 s |
| 6 | Approx. 97.7 ms | Approx. 25 s |
| 7 | Approx. 391 ms | Approx. 100 s |

- The base clock of the timers is 42.95454 MHz, and the table above is calculated with this clock.

### 10.2.4 Example Usage Procedure

The following is the flow for using core 0 as a periodic timer.

1. Enable the TIMER bit of I/O Enabler2
2. Write 00h (core 0, mode register) to B0h, and write the mode (interrupt enable, RESO, repeat) to B1h
3. Write 01h (core 0, count register) to B0h, and write the count value to B1h
4. Write 02h (core 0, control register) to B0h, and write 03h (counter clear + count enable) to B1h
5. In the interrupt handler, read B2h to check the flags, and write 1 to the bit of the core that was handled to clear its flag

## 10.3 Reset Behavior

The state of each block at power-on and at reset is as follows.

| Item | State at reset |
|---|---|
| I/O ports of the sound source blocks (SSG / OPLL / OPL2 / OPM / MSX-TIMER) | All disabled (I/O Enabler1/2 are all 0). No response even if accessed |
| Mixer volumes (per group and master) | All 128 (maximum) |
| SCC bank registers | BANK#0–#3 in BANK0–BANK3, RAM mode = 0 |
| SCC stereo positioning | All channels 128 (center) |
| SCC output switches | All channels off |
| OPM write queue | Empty (BUSY eventually becomes 0) |
| MSX-TIMER | All cores stopped, interrupt flags cleared, interrupt enable 0 |
| System Controller | Disabled (enable it with the procedure of Section 10.1.1 when using it) |
| Config ROM → SerialSRAM boot copy | Executed at power-on (see Section 10.1.4) |

While the I/O ports are disabled, the sound source chips cannot be accessed, so effectively no sound is produced. The recommended initialization flow is as follows.

1. Enable the I/O ports of the sound sources to be used with I/O Enabler1/2
2. Initialize the registers of each sound source chip, and set the instruments and volumes
3. As necessary, set the mixer's per-group volumes and the pan of each channel
4. If timers or interrupts are used, set and enable them last

- [TBC] Whether the boot copy is executed again when the MSX itself is reset, and what happens to the enabled state of the System Controller, is being confirmed.

## 10.4 Interrupts

The Y8960 activates the cartridge's interrupt output (/INT) for the following three groups of sources.

| Source | Occurrence condition | Checking and clearing the flag |
|---|---|---|
| MSX-TIMER | One of the cores reaches time-up and interrupts are enabled | Check with B2h, and clear by writing to B2h (Section 10.2) |
| OPL2 built-in timers | Overflow of Timer A / Timer B (when interrupts are enabled) | Check with the OPL2 status register, and clear with the reset bit (Chapter 6) |
| OPM built-in timers | Overflow of Timer A / Timer B (when interrupts are enabled) | Check with the status register (read of 7Fh), and clear with register 14h (Chapter 8) |

The interrupt outputs of the three groups are combined internally and go out to the slot's /INT. /INT remains active as long as even one source remains. In the interrupt handler, check the flags of all three groups, clear all of them that have occurred, and then return. If a source is left uncleared, an interrupt will occur again immediately after returning.

The SSG, OPLL, and SCC have no interrupt output.

## 10.5 Notes on Use

- **I/O address conflicts**: The Y8960's sound source ports are all disabled at power-on. This is a specification intended to avoid conflicts even if the addresses overlap with devices of other cartridges or the MSX itself. Enable only the ports you use. Note in particular that A0h–A3h of the SSG are in the same address range as the MSX's built-in PSG, and enabling them causes writes to be made to the built-in PSG at the same time (see Chapter 4)
- **Enabling conditions for memory-mapped I/O**: Depending on the state of the RAM mode and BANK1, the window for memory-mapped I/O such as the volumes and the I/O enablers (7FF0h–7FFFh) may be closed and access may not be possible (see Chapter 3, Section 3.4). If settings are not reflected, check the state of the window
- **Consecutive writes to the OPM**: The OPM prevents dropped writes with its write queue and /WAIT, but rewriting a large number of registers in a short time makes the CPU wait, which may delay playback processing and the like (see Chapter 8, Section 8.3)
- **Rewriting the Config ROM**: The Config ROM Reader/Writer is a function for maintenance and updating of the cartridge. Do not use it from ordinary playback programs. Erasure is performed in units of 64KB sectors or for the whole chip, and an incorrect operation will lose data required for the cartridge to boot
- **Access-prohibited areas of the SCC**: The unused areas within the SCC register bank (98A0h–98DFh, 9905h–9FFFh, etc.) are prohibited from access (see Chapter 7, Section 7.3)
- **Fast consecutive accesses**: Consecutive accesses in a fast loop may occupy the bus and cause sound dropouts. It is recommended to keep register rewrites to the minimum necessary

# Index

An index of the important terms used in this manual and the sections that mainly describe them. The references are links: selecting one takes you to the corresponding passage.

| Term | Reference |
|---|---|
| ADPCM | [6.5 ADPCM Section Registers](#65-adpcm-section-registers), [6.6 ADPCM Memory](#66-adpcm-memory) |
| Bank register | [3.5.2 RAM Mode and Bank Register Layout](#352-ram-mode-and-bank-register-layout) |
| Bank switching | [3.5 Memory Map and Bank Control](#35-memory-map-and-bank-control) |
| Boot copy | [2.3 Behavior at Power-On](#23-behavior-at-power-on), [10.1.4 Boot Copy at Power-On](#1014-boot-copy-at-power-on) |
| Config ROM | [10.1.3 Config ROM Reader/Writer](#1013-config-rom-readerwriter) |
| Device ID | [10.1.1 Enabling and Device Identification](#1011-enabling-and-device-identification) |
| Digital mixer | [Chapter 9 Digital Mixer](#chapter-9-digital-mixer) |
| Enabler1 | [3.3 State at Power-On and Enabling the I/O Ports](#33-state-at-power-on-and-enabling-the-io-ports) |
| Enabler2 | [3.3 State at Power-On and Enabling the I/O Ports](#33-state-at-power-on-and-enabling-the-io-ports) |
| Function select | [10.1.2 Function Select](#1012-function-select) |
| Gain | [4.6.1 Per-Channel Gain (20h–26h)](#461-per-channel-gain-20h26h) |
| GPIO | [4.5 I/O Ports (GPIO)](#45-io-ports-gpio) |
| Group volume | [6.7.2 Group Volume](#672-group-volume), [9.2 Per-Group Volumes and the Master Volume](#92-per-group-volumes-and-the-master-volume) |
| I2S | [9.4 I2S Output](#94-i2s-output) |
| Interrupts | [10.4 Interrupts](#104-interrupts) |
| Master volume | [9.2 Per-Group Volumes and the Master Volume](#92-per-group-volumes-and-the-master-volume) |
| Memory map | [3.5 Memory Map and Bank Control](#35-memory-map-and-bank-control) |
| Memory-mapped I/O | [3.4 Memory-Mapped I/O (7FF0h–7FFFh)](#34-memory-mapped-io-7ff0h7fffh) |
| MMIO | [3.4 Memory-Mapped I/O (7FF0h–7FFFh)](#34-memory-mapped-io-7ff0h7fffh) |
| Mode register (SCC) | [7.8 Mode Register](#78-mode-register) |
| MSX-TIMER | [10.2 MSX-TIMER](#102-msx-timer) |
| OPL2 | [Chapter 6 OPL2 + ADPCM](#chapter-6-opl2--adpcm) |
| OPLL-EX | [Chapter 5 OPLL-EX](#chapter-5-opll-ex) |
| OPM | [Chapter 8 OPM](#chapter-8-opm) |
| Output switch | [7.6 Output Switch](#76-output-switch) |
| Pan | [4.6.2 Per-Channel Pan (28h–2Eh)](#462-per-channel-pan-28h2eh), [5.6 Stereo Positioning (Pan)](#56-stereo-positioning-pan) |
| Preset instrument bank | [5.4 Preset Instrument Banks](#54-preset-instrument-banks) |
| Register bank (SCC) | [3.5.3 SCC Register Bank](#353-scc-register-bank), [7.2 How the SCC Register Bank Appears](#72-how-the-scc-register-bank-appears) |
| Reset behavior | [10.3 Reset Behavior](#103-reset-behavior) |
| Rhythm mode | [5.5 Rhythm Mode](#55-rhythm-mode) |
| Saturation and clipping | [9.3 Saturation and Clipping](#93-saturation-and-clipping) |
| SCC | [Chapter 7 SCC](#chapter-7-scc) |
| SerialSRAM | [2.2 SerialSRAM Organization](#22-serialsram-organization) |
| SPI ROM | [10.1.3 Config ROM Reader/Writer](#1013-config-rom-readerwriter) |
| SSG | [Chapter 4 SSG](#chapter-4-ssg) |
| Stereo output (RL bits) | [8.6 Stereo Output (RL Bits)](#86-stereo-output-rl-bits) |
| System Controller | [10.1 System Controller](#101-system-controller), [3.2.4 System Controller](#324-system-controller) |
| Waveform memory | [7.4 Waveform Memory](#74-waveform-memory) |
| Write queue | [8.3 Write Queue and /WAIT](#83-write-queue-and-wait) |

---

Y8960 APPLICATION MANUAL

October 31, 2026

Written by Takayuki Hara (HRA!)
