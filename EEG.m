%% 1. TẠO TÍN HIỆU EEG MÔ PHỎNG
clear; clc; close all;

fs = 512;               
T  = 20;               
t  = 0:1/fs:T-1/fs;

% Tạo dải sóng EEG 
delta = 60*sin(2*pi*1.5*t);    
theta = 35*sin(2*pi*5*t);      
alpha = 25*sin(2*pi*12*t);     
beta  = 15*sin(2*pi*25*t);     
gamma = 8*sin(2*pi*40*t);      

% Tín hiệu tổng hợp
eeg = delta + theta + alpha + beta + gamma + 8*randn(size(t)); 

%% 2. TIỀN XỬ LÝ & LỌC
% Loại bỏ DC
eeg_dc = eeg - mean(eeg);

% Lọc band-pass 1–45 Hz
[b,a] = butter(4, [1 45]/(fs/2), 'bandpass'); 
eeg_f = filtfilt(b, a, eeg_dc);

%% 3. PHÂN TÍCH FFT
N = length(eeg_f);
f = (0:N-1)*(fs/N);
EEG_FFT = abs(fft(eeg_f));

%% 4. SPECTROGRAM 
window   = 1024;        
noverlap = 512;         
nfft     = 2048;        
[S, Freq, Time] = spectrogram(eeg_f, window, noverlap, nfft, fs);

%% 5. WAVELET CWT 
[cfs, freqCW] = cwt(eeg_f, fs);

%% 6. NĂNG LƯỢNG CÁC DẢI SÓNG 
P = abs(fft(eeg_f)/N).^2;
P = P(1:N/2);
f_half = f(1:N/2);

band_energy = @(f1,f2) sum(P(f_half>=f1 & f_half<=f2));

E_delta = band_energy(1,4);    
E_theta = band_energy(4,8);
E_alpha = band_energy(8,13);
E_beta  = band_energy(13,30);
E_gamma = band_energy(30,45);

fprintf("Năng lượng dải EEG (µV^2)\n");
fprintf("Delta (1–4 Hz):     %.4f\n", E_delta);
fprintf("Theta (4–8 Hz):     %.4f\n", E_theta);
fprintf("Alpha (8–13 Hz):    %.4f\n", E_alpha);
fprintf("Beta  (13–30 Hz):   %.4f\n", E_beta);
fprintf("Gamma (30–45 Hz):   %.4f\n", E_gamma);

%% 7. ĐỒ THỊ
figure;

subplot(4,1,1);
plot(t, eeg); grid on;
title('Tín hiệu EEG mô phỏng (Gốc)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,2);
plot(t, eeg_f); grid on;
title('Tín hiệu EEG sau lọc');
xlabel('Time (s)');

subplot(4,1,3);
plot(f_half, P); grid on;
title('Phổ FFT');
xlabel('Frequency (Hz)'); ylabel('Power');

subplot(4,1,4);
spectrogram(eeg_f, window, noverlap, nfft, fs, 'yaxis');
title('Spectrogram'); ylabel('Frequency (Hz)');

figure;
cwt(eeg_f, fs);
title('Wavelet Transform (CWT)');
