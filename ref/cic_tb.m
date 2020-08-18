%% parameters
B = 16;        % bit width
R = 64;        % decimation factor
N = 4;        % number of stages
M = 1;        % differentiator delay

% fs = 2000;
% ts = 1/fs;
% t = 0:ts:2;

NFFT = 1024;
f = (-NFFT/2:NFFT/2-1) / NFFT; % normalized frequency vector
% f = (-NFFT/2*R:NFFT/2*R-1) / NFFT; 

% pulse
s = zeros(R*NFFT,1); s(1) = 1;
s = ones(R*NFFT, 1) * (2^15-1);%  * sin(2*pi*0.01*(0:1023))';
%% Fixed point decimator
% y = CICDecimator(s, 'M',M, 'N',N, 'R',R);
% y = CICDecimator(s, 'M',M, 'N',N, 'R',R,'decimOff',true);
y = CICDecimator(s, 'M',M, 'N',N, 'R',R,'compatibilityMode','hw');

%% Matlab DSP CIC decimator
cicDecim = dsp.CICDecimator(R,M,N,'FixedPointDataType','Minimum section word lengths','OutputWordLength',16, 'OutputFractionLength', 0);
% cicDecim = dsp.CICDecimator(R,M,N,'FixedPointDataType','Full Precision','OutputWordLength',16);
y_dsp = cicDecim(s);

%% Calculation of response in passband
G_max = (R*M)^(N-1);
H_f = abs(sin(pi*f*M)./sin(pi*f/R)).^N / M / R;
H_f(isnan(H_f)) = G_max;

% inverse respone (compensation filter)
% f = 0:0.01:0.5;
% H_f = ones(size(f));
% H_f(2:end) = abs(M*R*sin(pi*f(2:end)/R)./sin(pi*M*f(2:end))).^N;
% Mp = ones(1,length(fp)); %% Pass band response; Mp(1)=1
% Mp(2:end) = abs( M*R*sin(pi*fp(2:end)/R)./sin(pi*M*fp(2:end))).^N;
 

%% Plot
figure(1); clf;
plot(f, 20*log10(fftshift(abs(fft(y_dsp)))))
hold on
plot(f, 20*log10(fftshift(abs(fft(y)))))
plot(f, 20*log10(H_f))
% axis([xlim, -80, 80]);
legend('reference','MATLAB DSP','Calculated'); 


