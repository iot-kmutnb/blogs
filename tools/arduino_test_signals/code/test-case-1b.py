"""
Four PWM Waveforms (Phase-Correct PWM)
"""

import numpy as np
import matplotlib.pyplot as plt

# PWM Configuration
PWM_PERIOD_US = 2040.0

channels = [
    ("PWM1", 10), ("PWM2", 25),("PWM3", 50), ("PWM4", 75),
]

# Show multiple periods
NUM_PERIODS = 3

# Phase-correct PWM generator
def phase_correct_pwm(time_us, duty_percent, period_us):
    high_width = period_us * duty_percent / 100.0
    # Center-align the pulse
    center = period_us / 2.0
    start = center - high_width / 2.0
    end   = center + high_width / 2.0
    phase = np.mod(time_us, period_us)
    return ((phase >= start) & (phase <= end)).astype(float)

# Plot with 4 subplots
fig, axes = plt.subplots( 4, 1, figsize=(12, 9), sharex=True )
fig.suptitle( "Four Phase-Correct PWM Signals", fontsize=16 )

# Time axis
t = np.linspace( 0, PWM_PERIOD_US * NUM_PERIODS, 20000 )

# Draw each channel
for ax, (pin, duty) in zip(axes, channels):
    y = phase_correct_pwm( t, duty, PWM_PERIOD_US )
    y = 5.0 * y # Vcc=5V
    pulse_width = PWM_PERIOD_US * duty / 100.0
    ax.plot(t, y, linewidth=2)
    ax.set_ylim(-0.2, 5.5)
    ax.set_ylabel(pin)
    ax.grid(True)
    ax.set_title(
        f"{pin}: Duty={duty}%   "
        f"Pulse Width={pulse_width:.0f} us"
    )

# Common X-axis
axes[-1].set_xlabel("Time [us]")
plt.tight_layout()
plt.show()
