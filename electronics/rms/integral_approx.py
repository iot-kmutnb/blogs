import numpy as np
import matplotlib.pyplot as plt

# Constants
f = 50  # Frequency in Hz
T = 1 / f  # Period

# Time array for one period
T_total = T  # Total time for one period
num_points = 1000  # Number of points for smooth plotting
t = np.linspace(0, T_total, num_points)
A = 1.0  # Amplitude
x_t = A * np.sin(2 * np.pi * f * t)
x_t_squared = x_t**2

# Number of small sub-intervals for Riemann sum
N = 50  # Number of sub-intervals
dt = T / N  # Time step for sub-intervals
t_sub = np.linspace(0, T, N+1)  # Sub-interval time points
x_t_squared_sub = (A * np.sin(2 * np.pi * f * t_sub))**2

# Adjust the shapes to match
t_sub[:-1] = t_sub[:-1]  # Keep this for the bar positions
x_t_squared_sub = x_t_squared_sub[:-1]

# Create subplots
fig, axs = plt.subplots(3, 1, figsize=(8, 8))

# Instantaneous Power plot
axs[0].plot(t, x_t, label='$x(t)$', color='purple')
axs[0].fill_between(t, x_t, where=(t <= T), color='purple', alpha=0.3)
axs[0].set_xlabel('Time (s)')
axs[0].set_ylabel('Amplitude')
axs[0].set_title('$x(t)$ for One Period')
axs[0].legend()
axs[0].grid()

# Plot for (p(t))^2 and filled color under curve for the first period
axs[1].plot(t, x_t_squared, label='$(x(t))^2$', color='green')
axs[1].fill_between(t, x_t_squared, where=(t <= T), color='green', alpha=0.3)
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('Amplitude')
axs[1].set_title('$(x(t))^2$ for One Period')
axs[1].legend()
axs[1].grid()

# Numerical integration (Riemann sum) visualized with bars
axs[2].plot(t, x_t_squared, label='$(x(t))^2$', color='green')  # Plot the curve
axs[2].bar(t_sub[:-1], x_t_squared_sub, width=dt, align='edge',
           color='blue', alpha=0.5, label='Approximation')  # Add bars
axs[2].set_xlabel('Time (s)')
axs[2].set_ylabel('Amplitude')
axs[2].set_title('Simple Numerical Integration')
axs[2].legend()
axs[2].grid()

# Adjust layout
plt.tight_layout()
plt.show()



