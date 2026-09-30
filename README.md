# tang-nano-9k-ddc112

FPGA controller and Verilog/SystemVerilog readout implementation for the Texas Instruments DDC112 dual-channel 20-bit current-input ADC using the Sipeed Tang Nano 9K and Gowin FPGA.

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

### Complete prototype
<p align="center">
  <img src="images/system_overview.jpg" width="850">
</p>
Tang Nano 9K FPGA controller connected to the custom DDC112 analog front-end.

### Custom DDC112 board
<p align="center">
  <img src="images/ddc112_board.jpg" width="650">
</p>
Custom PCB based on the Texas Instruments DDC112 dual-channel current-input ADC.

<!-- <img width="1536" height="2048" alt="IMG_5650" src="https://github.com/user-attachments/assets/f4167270-3db4-4d87-b112-6cfbf8c4dc7e" /> --->

## Notes

This repository contains experimental FPGA readout code developed for medical physics instrumentation research.

This is an experimental implementation, not an official TI reference design.
Timing and pin assignments should be verified for each hardware setup.

Constraint files are currently placed under src/ for simplicity.

## Demo

Real-time photodiode measurement using the Tang Nano 9K and DDC112.
[Watch the demonstration video on YouTube](https://youtu.be/cdM2_N08YOs)

## 5000-sample noise test

A 5000-sample open-input test at 0.5 ms integration and 50 pC full scale showed approximately **0.6 pA RMS equivalent input-current noise** after correcting the fixed A/B integrator offset, when the aluminum enclosure was connected to circuit GND.

Grounding the enclosure reduced the corrected RMS fluctuation by roughly **33–32×** compared with the isolated case.

See [`README_noise_test.md`](./docs/README_noise_test.md) for details.

The isolated-enclosure waveform contains a dominant \~60 Hz component in both channels, consistent with mains pickup; this component is strongly suppressed when the enclosure is grounded.

## Acknowledgements

The DDC112 analog front-end design was developed with reference to
Frédérik Berthiaume's Picoammeter project on Hackaday.io:
https://hackaday.io/project/176095-picoammeter

