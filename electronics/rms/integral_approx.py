import numpy as np
import matplotlib.pyplot as plt

# Constants
f = 50  # Frequency in Hz
T = 1 / f  # Period
phi = np.deg2rad(45)  # Phase shift in radians

# Time array for two periods
T_total = T  # Total time for one period
num_points = 1000  # Number of points for smooth plotting
t = np.linspace(0, T_total, num_points)

# Voltage and current waveforms
Vm = 1.0 # Amplitude for voltage [V]
Im = 1.0 # Amplitude for current [A]
v_t = Vm * np.sin(2 * np.pi * f * t)
i_t = Im * np.sin(2 * np.pi * f * t + phi)
p_t = v_t * i_t  # Instantaneous power

# Compute (p(t))^2
p_t_squared = p_t**2

# Number of small sub-intervals for Riemann sum
N = 50  # Number of sub-intervals
dt = T / N  # Time step for sub-intervals
t_sub = np.linspace(0, T, N+1)  # Sub-interval time points
p_t_sub = Vm * np.sin(2 * np.pi * f * t_sub) * Im * np.sin(2 * np.pi * f * t_sub + phi)  # p(t) at sub-intervals
p_t_squared_sub = p_t_sub**2  # (p(t))^2 at sub-intervals

# Adjust the shapes to match
t_sub[:-1] = t_sub[:-1]  # Keep this for the bar positions
p_t_squared_sub = p_t_squared_sub[:-1]  # Trim the extra point in p_t_squared_sub

# Create subplots
fig, axs = plt.subplots(3, 1, figsize=(10, 6))

# Instantaneous Power plot
axs[0].plot(t, p_t, label='$p(t)$', color='purple')
axs[0].fill_between(t, p_t, where=(t <= 2*T), color='purple', alpha=0.3)
axs[0].set_xlabel('Time (s)')
axs[0].set_ylabel('Amplitude')
axs[0].set_title('Instantaneous Power $p(t)$ for One Period')
axs[0].legend()
axs[0].grid()

# Plot for (p(t))^2 and filled color under curve for the first period
axs[1].plot(t, p_t_squared, label='$(p(t))^2$', color='green')
axs[1].fill_between(t, p_t_squared, where=(t <= T), color='green', alpha=0.3)
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('Amplitude')
axs[1].set_title('Integral of Squared Instantaneous Power $(p(t))^2$ for One Period')
axs[1].legend()
axs[1].grid()

# Numerical integration (Riemann sum) visualized with bars
axs[2].plot(t, p_t_squared, label='$(p(t))^2$', color='green')  # Plot the curve
axs[2].bar(t_sub[:-1], p_t_squared_sub, width=dt, align='edge', 
           color='blue', alpha=0.5, label='Approximation')  # Add bars
axs[2].set_xlabel('Time (s)')
axs[2].set_ylabel('Amplitude')
axs[2].set_title('Simple Numerical Integration')
axs[2].legend()
axs[2].grid()

# Adjust layout
plt.tight_layout()
plt.show()

