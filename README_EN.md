# AsProgrammer (FlashBridge fork)

[English](README_EN.md) | [简体中文](README.md)

A fork of [nofeletru/UsbAsp-flash](https://github.com/nofeletru/UsbAsp-flash) for programming memory chips over the SPI, I2C and MicroWire protocols.

Supported programmers:
- CH341
- CH347
- FT232H
- USBasp (requires reflashing)
- Arduino
- AVRISP-mkII (requires reflashing)
- FlashBridge (new in this fork)

## Changes in this fork

- New FlashBridge backend: CH347 handles SPI/I2C/MicroWire timing, CH32V002 controls the VIO voltage via the CH347 UART virtual COM port
- Fixed CH347 I2C ACK detection (0x80); the SDA line no longer hangs after an interrupted write
- Updated chiplist.xml (added vcc voltage info), CH34X drivers and CH341DLL/CH347DLL

## Usage

1. Extract the release package and run AsProgrammer.exe
2. On first use, install the drivers: `drivers/CH34X/CH343SER.EXE` (serial) and `CH341PAR.EXE` (parallel / SPI-I2C)
3. Select FlashBridge as the programmer, pick the chip, then read/write
4. VIO voltage range is 1200–3300mV; below 1.4V a timed hold mode is used and the voltage is restored automatically when the timer expires