"""
Two complementary 20 kHz signals with:
Normal Operation:
- Non-overlapping complementary outputs
- Dead time inserted at EVERY transition
- During dead time: A = LOW and B = LOW

Fault Condition
- One corrupted A-rising edge
- A rises BEFORE B falls
- Temporary overlap: A = HIGH and B = HIGH

Timing:
-------
Frequency        : 20 kHz
Period           : 50 us
Half-period      : 25 us
Dead time        : 2 us
Fault overlap    : 5 us
"""

import numpy as np
import matplotlib.pyplot as plt

# Signal Configuration
PERIOD_US = 50.0
HALF_PERIOD_US = 25.0
DEAD_TIME_US = 2.0
OVERLAP_US = 5.0
# Number of Periods
NUM_PERIODS = 4
# Must be EVEN (rising transition)
GLITCH_HALF_INDEX = 2

# Time axis
t_end = NUM_PERIODS * PERIOD_US
t = np.linspace( 0, t_end, 300000 )

signal_a = np.zeros_like(t)
signal_b = np.zeros_like(t)

# Initial state: A = LOW B = HIGH
signal_b[:] = 1

state_a = False

for half_counter in range(int(NUM_PERIODS * 2)):
    transition_time = half_counter * HALF_PERIOD_US
    state_a = not state_a
    if state_a:
        # FAULT CASE
        if half_counter == GLITCH_HALF_INDEX:
            # A -> HIGH immediately
            signal_a[t >= transition_time] = 1
            # B remains HIGH during overlap
            overlap_end = transition_time + OVERLAP_US
            # B -> LOW after overlap
            signal_b[t >= overlap_end] = 0

        # NORMAL CASE
        else:
            # B -> LOW immediately
            signal_b[t >= transition_time] = 0
            # A -> HIGH after dead time
            a_rise_time = transition_time + DEAD_TIME_US
            signal_a[t >= a_rise_time] = 1

    else:
        # A -> LOW immediately
        signal_a[t >= transition_time] = 0
        # B -> HIGH after dead time
        b_rise_time = transition_time + DEAD_TIME_US
        signal_b[t >= b_rise_time] = 1

signal_a = 5.0 * signal_a
signal_b = 5.0 * signal_b

# Plot
fig, axes = plt.subplots(2, 1, figsize=(13, 6), sharex=True )

# Signal A
axes[0].plot(t, signal_a, linewidth=2, label="Signal A")
axes[0].set_title("Signal A")
axes[0].set_ylabel("Voltage [V]")
axes[0].set_ylim(-0.2, 5.5)
axes[0].grid(True)
axes[0].legend()

# Signal B
axes[1].plot(t, signal_b, linewidth=2, label="Signal B")
axes[1].set_title("Signal B")
axes[1].set_xlabel("Time [us]")
axes[1].set_ylabel("Voltage [V]")
axes[1].set_ylim(-0.2, 5.5)
axes[1].grid(True)
axes[1].legend()

# Highlight dead time region
normal_transition = 2 * HALF_PERIOD_US
axes[0].annotate(
    "Dead Time\nViolation",
    xy=(normal_transition + 1, 3.0),
    xytext=(normal_transition + 10, 3.1),
    arrowprops=dict(arrowstyle="->")
)
# Highlight overlap fault
fault_time = GLITCH_HALF_INDEX * HALF_PERIOD_US
axes[1].annotate(
    "Overlap interval\n(A=1, B=1)",
    xy=(fault_time + 0.5, 3.5),
    xytext=(fault_time + 7, 4.0),
    arrowprops=dict(arrowstyle="->")
)

plt.tight_layout()
plt.show()
