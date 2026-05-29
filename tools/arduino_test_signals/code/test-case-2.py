"""
Pulse Generator with Random Glitch Pulse
"""

import numpy as np
import matplotlib.pyplot as plt

# Signal configuration
PERIOD_US = 50.0  # 20 kHz
NORMAL_WIDTH_US = 1.5 
GLITCH_EXTRA_US = 12.0

NUM_PERIODS = 5
# Choose one pulse to become the glitch pulse
glitch_index = 2

# Time axis
t_end = NUM_PERIODS * PERIOD_US
t = np.linspace( 0, t_end, 50000 )

signal = np.zeros_like(t)
# Generate pulses
for i in range(NUM_PERIODS):
    pulse_start = i * PERIOD_US
    # Normal pulse width
    width = NORMAL_WIDTH_US
    # Inject glitch pulse
    if i == glitch_index:
        width += GLITCH_EXTRA_US
    pulse_end = pulse_start + width
    signal[ (t >= pulse_start) & (t < pulse_end) ] = 1

# Plot
plt.figure(figsize=(12, 4))
signal = 5.0 * signal # VCC=5V
plt.plot(t, signal, linewidth=2)
plt.title("Pulse Train with Random Glitch Pulse")
plt.xlabel("Time [us]")
plt.ylabel("Voltage [V]")
plt.ylim(-0.1, 5.5)
plt.grid(True)
# Annotate glitch pulse
glitch_time = glitch_index * PERIOD_US
plt.annotate(
    "Glitch Pulse",
    xy=(glitch_time+10, 5.1),
    xytext=(glitch_time+25,5.2),
    arrowprops=dict(arrowstyle="->")
)
plt.tight_layout()
plt.show()
