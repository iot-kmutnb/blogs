"""
Signal A:
    - Aperiodic pulses
    - Pulse width = 20 us
    - Random LOW interval = 1-2 ms

Signal B: 
    - Triggered AFTER A falls
    - Pulse width = 20 us

Delay measured:
    A-falling edge -> B-rising edge

Normal delay: 3-15 us
Fault delay: 21-100 us
Fault rate: 1 per 50 pulses
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# Signal Configuration
PULSE_WIDTH_US   = 20
DELAY_NORMAL_MIN = 3
DELAY_NORMAL_MAX = 15
DELAY_FAULT_MIN  = 21
DELAY_FAULT_MAX  = 100
INTERVAL_MIN_US  = 1000  # 1 ms
INTERVAL_MAX_US  = 2000  # 2 ms

# Number of pulses
N_PULSES = 3
# Number of pulses to display
NUM_PULSES_TO_SHOW = 3
# Select one fault pulse
fault_pulse_idx = random.randint(0, N_PULSES - 1)

# Build waveform event list
events_a = []
events_b = []

current_time = 0.0

for pulse_idx in range(NUM_PULSES_TO_SHOW):
    fault = (pulse_idx == fault_pulse_idx)
    if fault:
        delay_fr = random.randint(
            DELAY_FAULT_MIN,
            DELAY_FAULT_MAX
        )
    else:
        delay_fr = random.randint(
            DELAY_NORMAL_MIN,
            DELAY_NORMAL_MAX
        )

    # Signal A pulse
    a_rise = current_time
    a_fall = a_rise + PULSE_WIDTH_US
    events_a.append((a_rise, 1))
    events_a.append((a_fall, 0))

    # Signal B pulse
    b_rise = a_fall + delay_fr
    b_fall = b_rise + PULSE_WIDTH_US
    events_b.append((b_rise, 1))
    events_b.append((b_fall, 0))

    # Random interval before next pulse
    interval_us = random.randint(
        INTERVAL_MIN_US, INTERVAL_MAX_US
    )

    current_time = b_fall + interval_us

# Convert event lists to sampled waveforms
t_end = current_time + 200
t = np.linspace(0, t_end, 300000)

signal_a = np.zeros_like(t)
signal_b = np.zeros_like(t)

# Build signal A
level = 0
for i in range(len(events_a)):
    time_i, new_level = events_a[i]
    if i < len(events_a) - 1:
        next_time = events_a[i + 1][0]
    else:
        next_time = t_end
    signal_a[ (t >= time_i) & (t < next_time) ] = new_level

# Build signal B
for i in range(len(events_b)):
    time_i, new_level = events_b[i]
    if i < len(events_b) - 1:
        next_time = events_b[i + 1][0]
    else:
        next_time = t_end
    signal_b[ (t >= time_i) & (t < next_time) ] = new_level

signal_a = 5.0 * signal_a 
signal_b = 5.0 * signal_b

# Plot
fig, axes = plt.subplots(
    2, 1,
    figsize=(14, 6), sharex=True
)

# Signal A
axes[0].plot( t, signal_a, linewidth=2 )
axes[0].set_title( "Signal A - Aperiodic Pulses"
)
axes[0].set_ylabel("Voltage [V]")
axes[0].set_ylim(-0.2, 5.5)
axes[0].grid(True)

# Signal B
axes[1].plot( t, signal_b, linewidth=2 )
axes[1].set_title( "Signal B - Response Pulse" )
axes[1].set_xlabel("Time [us]")
axes[1].set_ylabel("Voltage [V]")
axes[1].set_ylim(-0.2, 5.5)
axes[1].grid(True)

plt.tight_layout()
plt.show()
