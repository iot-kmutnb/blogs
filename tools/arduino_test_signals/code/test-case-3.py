"""
Test signal: Periodic pulse signal
- Frequency = 10 kHz, Period = 100 us
Normally: One short pulse per interrupt period
Fault condition: Three (burst) pulses instead of one.
"""

import numpy as np
import matplotlib.pyplot as plt

# Signal configuration
PERIOD_US = 100.0     # 10 kHz
PULSE_WIDTH_US = 3.0  # approximate narrow pulse width
# Number of pulses
NUM_PERIODS = 6
# Select one period containing the pulse burst
burst_period = 2
# Time spacing between burst pulses
BURST_SPACING_US = 6.0

# Time axis
t_end = NUM_PERIODS * PERIOD_US
t = np.linspace( 0, t_end, 100000 )
signal = np.zeros_like(t)

# Generate signal
for period_index in range(NUM_PERIODS):
    base_time = period_index * PERIOD_US
    # Normal period -> one pulse
    pulse_times = [base_time]
    # Burst period -> three pulses
    if period_index == burst_period:
        pulse_times = [
            base_time,
            base_time + BURST_SPACING_US,
            base_time + 2 * BURST_SPACING_US
        ]
    # Draw pulses
    for pulse_start in pulse_times:
        pulse_end = pulse_start + PULSE_WIDTH_US
        signal[(t >= pulse_start)&(t < pulse_end)] = 1

# Plot
plt.figure(figsize=(12, 4))
signal = 5.0 * signal # VCC=5V
plt.plot(t, signal, linewidth=2)
plt.title("Pulse Burst Signal")
plt.xlabel("Time [us]")
plt.ylabel("Voltage [V]")
plt.ylim(-0.1, 5.5)
plt.grid(True)
# Annotate burst region
burst_time = burst_period * PERIOD_US
plt.annotate(
    "3-Pulse Burst",
    xy=(burst_time + 10, 5.0),
    xytext=(burst_time + 30, 5.1),
    arrowprops=dict(arrowstyle="->")
)
plt.tight_layout()
plt.show()
