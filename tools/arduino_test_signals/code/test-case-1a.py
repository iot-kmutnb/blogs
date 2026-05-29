"""
Plot four PWM waveforms (Freq.=490.2 Hz, Period=2040 us)
PWM Duty Cycles:
    PWM1 -> 10%
    PWM2 -> 25%
    PWM3 -> 50%
    PWM4 -> 75%
"""

import numpy as np
import matplotlib.pyplot as plt

# PWM configuration
PWM_PERIOD_US = 2040

channels = [
    ("PWM1", 10), ("PWM2", 25),("PWM3", 50), ("PWM4", 75),
]

# PWM signal generator
def pwm_signal(time_us, duty_percent, period_us):
    high_time = period_us * duty_percent / 100.0
    phase = np.mod(time_us, period_us)
    return (phase < high_time).astype(float)

# Plot setup
fig, axes = plt.subplots( 4, 1, figsize=(12, 8), sharex=True )
fig.suptitle("Four PWM Signals", fontsize=16)

# Number of periods
num_periods = 3
# Time axis
t = np.linspace(
    0, PWM_PERIOD_US * num_periods, 12000
)

# Plot each PWM channel
for ax, (pin, duty) in zip(axes, channels):
    y = 5.0 * pwm_signal(t, duty, PWM_PERIOD_US)
    ax.plot(t, y, linewidth=2)
    pulse_width = PWM_PERIOD_US * duty / 100.0
    ax.set_ylim(-0.5, 5.5)
    ax.set_ylabel(pin)
    ax.grid(True)
    ax.set_title(
        f"{pin}: Duty Cycle = {duty}%   "
        f"Pulse Width = {pulse_width:.0f} us"
    )

# Common X-axis
axes[-1].set_xlabel("Time [us]")
plt.tight_layout()
plt.show()
