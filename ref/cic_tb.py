import numpy as np
import matplotlib.pyplot as plt
from cic import decimator


print('################## CIC Decimator TB #####################')

# parameters
B = 16		# bit width
R = 64		# decimation factor
N = 4		# number of stages
M = 1		# differentiator delay
NFFT = 2048


#s = zeros(R*NFFT,1); s(1) = 1;
s = np.zeros(shape=(R*NFFT, 1), dtype=np.int64)
s[0] = 1
#s = np.ones(shape=(R*NFFT, 1), dtype=np.int64)

y = decimator(s, B, N=N, M=M, R=R, delay=2, decimOff=False)

print(y[0:20])
#plt.plot(np.log10(np.fft.fftshift(np.abs(np.fft.fft(y)))))
#plt.show()
