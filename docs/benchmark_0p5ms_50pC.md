# Benchmark note: 0.5 ms / 50 pC / open input

## Purpose

To quantify the short-term noise of the DDC112 readout and to isolate the effect of connecting the aluminum enclosure to circuit ground.

## Conversion used

Nominal charge LSB:

`50 pC / 2^20 = 0.0477 fC/count`

Equivalent average current for 0.5 ms integration:

`0.0477 fC / 0.5 ms = 0.0954 pA/count`

## Results

| condition             | channel   |   mean_count |   A_B_offset_count |   raw_sd_count |   A_B_corrected_sd_count |   equivalent_noise_fC_rms |   equivalent_input_current_pA_rms |
|:----------------------|:----------|-------------:|-------------------:|---------------:|-------------------------:|--------------------------:|----------------------------------:|
| case_ground_connected | IN1       |      3759    |           145.137  |        72.8394 |                  6.19079 |                  0.2952   |                          0.5904   |
| case_ground_connected | IN2       |      3747.16 |            81.8802 |        41.4282 |                  6.31404 |                  0.301077 |                          0.602154 |
| case_ground_isolated  | IN1       |      3738.99 |            98.382  |       208.506  |                202.619   |                  9.66165  |                         19.3233   |
| case_ground_isolated  | IN2       |      3732.6  |           158.644  |       219.293  |                204.442   |                  9.74853  |                         19.4971   |

## Notes

- First 10 samples were excluded from the steady-state statistics.
- A/B correction was performed by subtracting the mean of each parity group independently.
- Open-input data are useful for evaluating pickup, shielding, leakage sensitivity, and short-term electronic stability.
- These data do not establish absolute current accuracy or linearity.

## 60 Hz pickup in the isolated-enclosure condition

An FFT of the steady-state open-input data (2 kS/s nominal sampling) shows a dominant peak at approximately **60.1 Hz** in both IN1 and IN2 when the enclosure is isolated from GND, with a weaker component near **120 Hz**. This supports the interpretation that the large common fluctuation is mainly mains-frequency pickup rather than independent channel noise.
