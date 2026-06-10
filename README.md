# tang-nano-9k-ddc112
This is an experimental FPGA implementation for reading out the TI DDC112 charge-input ADC using the Sipeed Tang Nano 9K.

The design detects DVALID, controls DXMIT, generates 40 DCLK pulses, and shifts out 40-bit data from DOUT. It is intended as a minimal working example for laboratory experiments with photodiode or radiation detector readout.

This project is not an official TI reference design.
