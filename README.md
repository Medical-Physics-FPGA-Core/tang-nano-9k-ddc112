<img width="1536" height="2048" alt="IMG_5650" src="https://github.com/user-attachments/assets/f4167270-3db4-4d87-b112-6cfbf8c4dc7e" />
# tang-nano-9k-ddc112

Experimental FPGA readout implementation for the TI DDC112 using the Sipeed Tang Nano 9K.

This project is intended as a minimal working example for medical physics instrumentation and detector readout experiments.

## Status

- DVALID falling-edge detection confirmed
- DXMIT control implemented
- 40 DCLK pulse readout implemented
- DOUT response to photodiode light confirmed on oscilloscope
- CH1 / CH2 readout confirmed

## Hardware

- Sipeed Tang Nano 9K
- TI DDC112
- Photodiode input
- External level shifting may be required depending on logic levels

## Notes

This repository contains experimental FPGA readout code developed for medical physics instrumentation research.

This is an experimental implementation, not an official TI reference design.
Timing and pin assignments should be verified for each hardware setup.

Constraint files are currently placed under src/ for simplicity.
