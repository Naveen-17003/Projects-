import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, lfilter, freqz

# Sampling Parameters
fs = 1000
t = np.arange(0, 1, 1/fs)

# Clean Signal = sum of 2 frequencies
clean = np.sin(2*np.pi*50*t) + 0.5*np.sin(2*np.pi*150*t)

# Add noise
noise = 0.3 * np.random.randn(len(t))
noisy_signal = clean + noise

# Filter specifications
num_taps = 101  # FIR filter length

# Low-pass filter (cutoff 100 Hz)
lp_cutoff = 100
lp_filter = firwin(num_taps, lp_cutoff/(fs/2), pass_zero=True)

# Apply filter
lp_output = lfilter(lp_filter, 1.0, noisy_signal)

# Frequency Response
w, h = freqz(lp_filter)

# Plot signals
plt.figure(figsize=(12,8))

plt.subplot(3,1,1)
plt.plot(t, clean)
plt.title("Original Clean Signal")

plt.subplot(3,1,2)
plt.plot(t, noisy_signal)
plt.title("Noisy Signal")

plt.subplot(3,1,3)
plt.plot(t, lp_output)
plt.title("Filtered Signal (Low-Pass Output)")
plt.tight_layout()
plt.show()

# Plot frequency response
plt.figure(figsize=(6,4))
plt.plot(w*np.pi/fs, 20*np.log10(np.abs(h)))
plt.title("Low-Pass FIR Filter Frequency Response")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.grid()
plt.show()
