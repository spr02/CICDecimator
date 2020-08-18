import numpy as np

def decimator(s, B, N=1, M=1, R=8, decimOff=False, delay=0):
	print("CIC Decimator")
	
	B = B + N * int(np.log2(R * M)) # register growth due to amplification
	if B > 64:
		error('Bit size is too large to be simulated using int64');
	print(B)
	
	ints = np.zeros(shape=(len(s), N+1), dtype=np.int64)
	ints[:, 0] = s[:, 0]
	for i in range(0, N):
		ints[:, i+1] = np.cumsum(ints[:, i])
		
	
	print(ints[1:20, -1])
	
	if decimOff:
		ds = ints[:, -1]
		diff = np.zeros(shape=(len(s), N+1), dtype=np.int64)
		diff[:, 0] = ds
	else:
		# start downsampling after p.R integrator steps (pipeline delay)
		ds = ints[R+delay-1::R, -1]
		print(R+delay-1)
		print(ints[R+delay-1, -1])
		diff = np.zeros(shape=(int(np.ceil(len(s)/R)), N+1), dtype=np.int64)
		diff[:, 0] = np.concatenate((ds, np.zeros(shape=(1,), dtype=np.int64)))
	
	# comb stages, i.e. diff[:, -1] is the output of last comb
	print(ds[0:20])
	for i in range(0, N):
		if decimOff:
			diff_dly = np.concatenate((np.zeros(shape=(R*M,), dtype=np.int64), diff[0:-R*M, i]))
		else:
			diff_dly = np.concatenate((np.zeros(shape=(M,), dtype=np.int64), diff[0:-M, i]))
		diff[:, i+1] = diff[:, i] - diff_dly
	y = diff[:, -1]
	
	print(diff[0:20, -1])
	
	y = np.mod(y + np.power(2, B - 1), np.power(2, B)) - np.power(2, B - 1)

#%     y = y / 2^(B_in-B_out);

	return y
