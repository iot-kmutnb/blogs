import numpy as np
import matplotlib.pyplot as plt
from sympy import Rational

# Parameters
A = 1      # Numeric Amplitude
T = 2      # Numeric Period
omega = 2 * np.pi / T  # Angular frequency
N = 1000
ts = [0, 3*T]
t = np.linspace(ts[0], ts[1], N)  # Time array

t_mod = np.mod(t, T)
x_t = np.piecewise(
        t_mod,
        [t_mod < T/2, t_mod >= T/2],
        [lambda t: (2*A/T)*t,
         lambda t: (2*A/T)*(T - t)]
)

# Create plot
plt.figure(figsize=(10, 4))
plt.plot(t, x_t, label=r'$x(t)$', color='b')

# Customizing axis labels
plt.axhline(0, color='black', linewidth=0.8, linestyle='--')
plt.axvline(0, color='black', linewidth=0.8, linestyle='--')
plt.xlabel('Time (t)')
plt.ylabel('Amplitude')

# Title and legend
plt.title('Triangular Wave')
plt.legend(loc="upper right")

# Generate tick positions with intervals of T/4
T_ticks = np.arange(ts[0], ts[1]+T, T)
# Generate corresponding labels for the ticks
T_labels = [r'{}T'.format(i) if i>0 else r'{}'.format(i)
            for i in range(len(T_ticks))]
# Replace T in labels with the symbolic form
print(T_labels)
T_labels = [t for t in T_labels]
plt.xticks(T_ticks, T_labels)

# Custom y-ticks showing A
plt.yticks([0, A], [r'$0$', r'$A$'])

plt.grid(False)
plt.show()
