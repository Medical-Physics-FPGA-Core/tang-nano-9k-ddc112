## 5000-sample noise test

A 5000-sample open-input test at 0.5 ms integration and 50 pC full scale showed approximately **0.6 pA RMS equivalent input-current noise** after correcting the fixed A/B integrator offset, when the aluminum enclosure was connected to circuit GND.

Grounding the enclosure reduced the corrected RMS fluctuation by roughly **33–32×** compared with the isolated case.

See [`README_noise_test.md`](README_noise_test.md) for details.

The isolated-enclosure waveform contains a dominant ~60 Hz component in both channels, consistent with mains pickup; this component is strongly suppressed when the enclosure is grounded.
