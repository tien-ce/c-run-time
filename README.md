# STM32F103 Bare-Metal C Runtime & Startup

A minimal, bare-metal C runtime (CRT0) and startup implementation from scratch for the **STM32F103RB** microcontroller (ARM Cortex-M3).

## Overview

This project demonstrates what happens before `main()` executes.

---

### Prerequisites

Ensure you have the GNU Arm Embedded Toolchain installed:

```bash
sudo apt-get install gcc-arm-none-eabi
```

### Building the Project

- **Build ELF binary and disassembly dump:**
  ```bash
  make
  ```
- **Generate disassembly only:**
  ```bash
  make dump
  ```
- **Clean build artifacts:**
  ```bash
  make clean
  ```

---

## References

- [STM32F10xxx Reference Manual / Datasheet (Keil / ST)](https://www.keil.com/dd/docs/datashts/st/stm32f10xxx.pdf)
- [How a Microcontroller Starts - Low Level Learning (YouTube)](https://www.youtube.com/watch?v=MhOba73z-dQ&t=920s)
# c-run-time
