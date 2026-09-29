import csv
import re
from datetime import datetime

import serial

# ============================================================
# User settings
# ============================================================

PORT = "COM5"          # Change this to the COM port used by Tang Nano 9K / BL702
BAUD = 115200
NUM_SAMPLES = 5_000
TINT_MS = 0.5

# Expected FPGA UART line:
#   IN2=0AED9 IN1=0AD51
pattern = re.compile(r"^IN2=([0-9A-Fa-f]{5}) IN1=([0-9A-Fa-f]{5})$")


def main():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"ddc112_5000samples_{timestamp}.csv"

    print(f"Opening {PORT} at {BAUD} bit/s...")

    count = 0

    with serial.Serial(PORT, BAUD, timeout=1) as ser, \
            open(filename, "w", newline="", encoding="utf-8") as f:

        # Discard any old bytes that were already waiting in the PC serial buffer.
        ser.reset_input_buffer()

        print("Serial port is ready.")
        print("Now reset or reprogram the FPGA.")
        print("The FPGA captures 5,000 samples first (2.5 s at TINT = 0.5 ms),")
        print("then transmits the stored data over UART.")
        print("Press Ctrl+C to stop.\n")

        writer = csv.writer(f)
        writer.writerow([
            "sample",
            "nominal_time_ms",
            "parity",
            "IN1_hex",
            "IN1_dec",
            "IN2_hex",
            "IN2_dec",
        ])

        try:
            while count < NUM_SAMPLES:
                raw = ser.readline()

                if not raw:
                    continue

                line = raw.decode("ascii", errors="ignore").strip()
                m = pattern.match(line)

                if not m:
                    print(f"Ignored: {line}")
                    continue

                in2_hex = m.group(1).upper()
                in1_hex = m.group(2).upper()

                in2_dec = int(in2_hex, 16)
                in1_dec = int(in1_hex, 16)

                writer.writerow([
                    count,
                    count * TINT_MS,
                    "even" if (count % 2 == 0) else "odd",
                    in1_hex,
                    in1_dec,
                    in2_hex,
                    in2_dec,
                ])

                count += 1

                if count % 1000 == 0:
                    print(f"{count:5d} / {NUM_SAMPLES} samples received")

        except KeyboardInterrupt:
            print("\nStopped by user.")

    print(f"\nSaved {count} samples to:")
    print(filename)

    if count == NUM_SAMPLES:
        print("Acquisition completed successfully.")


if __name__ == "__main__":
    main()
