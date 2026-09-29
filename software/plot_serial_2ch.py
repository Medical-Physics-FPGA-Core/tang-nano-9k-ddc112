import serial
import time
import re
from collections import deque

import matplotlib.pyplot as plt
import matplotlib.animation as animation

# ===== set =====
PORT = "COM5"        # my COM number
BAUD = 115200       # same with FPGA/BL702
MAX_POINTS = 120    # for about 60s if 0.5s interval

ser = serial.Serial(PORT, BAUD, timeout=1)

t_data = deque(maxlen=MAX_POINTS)
in1_data = deque(maxlen=MAX_POINTS)
in2_data = deque(maxlen=MAX_POINTS)

start_time = time.time()

fig, ax = plt.subplots()
line_in1, = ax.plot([], [], label="IN1")
line_in2, = ax.plot([], [], label="IN2")

ax.set_xlabel("Time [s]")
ax.set_ylabel("ADC code")
ax.set_ylim(0, 0x110000)   # fix to 20 bit ADC code
#ax.set_ylim(0, 0x2FFF)
ax.grid(True)
ax.legend()

# 例: IN2=0AED9 IN1=0AD51
pattern = re.compile(r"IN2=([0-9A-Fa-f]+)\s+IN1=([0-9A-Fa-f]+)")

def parse_line(line: str):
    line = line.strip()

    m = pattern.search(line)
    if not m:
        print("Parse error:", line)
        return None

    in2_hex = m.group(1)
    in1_hex = m.group(2)

    in2 = int(in2_hex, 16)
    in1 = int(in1_hex, 16)

    return in1, in2

def update(frame):
    while ser.in_waiting:
        raw = ser.readline()

        try:
            line = raw.decode("ascii", errors="ignore")
        except UnicodeDecodeError:
            continue

        result = parse_line(line)
        if result is None:
            continue

        in1, in2 = result
        t = time.time() - start_time

        t_data.append(t)
        in1_data.append(in1)
        in2_data.append(in2)

        print(f"{t:8.2f} s  IN1={in1:6d}  IN2={in2:6d}")

    if len(t_data) > 0:
        line_in1.set_data(t_data, in1_data)
        line_in2.set_data(t_data, in2_data)

        ax.set_xlim(max(0, t_data[0]), max(10, t_data[-1]))

    return line_in1, line_in2

ani = animation.FuncAnimation(fig, update, interval=100, blit=False)

plt.show()

ser.close()
