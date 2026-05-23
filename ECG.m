%% KHOI TAO MOI TRUONG
clc; clear; close all;

% Tham so he thong
fs = 360;               % Tan so lay mau (Hz) 
T = 10;                 % Thoi gian thu thap (giay)
t = 0:1/fs:T-1/fs;      % Vector thoi gian

%% BƯỚC 1: TIỀN XỬ LÝ TÍN HIỆU (Preprocessing)
fprintf('--- BƯỚC 1: TIỀN XỬ LÝ TÍN HIỆU ---\n');

% 1.1. Doc tin hieu 
% Tao tin hieu ECG 
try
    ecg_template = ecg(round(0.8*fs)); 
catch
    ecg_template = [0.1*ones(1,20), 0.5, 1.5, -0.5, 0.1*ones(1,20)]; 
end
ecg_clean = repmat(ecg_template, 1, ceil(length(t)/length(ecg_template)));
ecg_clean = ecg_clean(1:length(t));

% Them cac loai nhieu thuc te de thu nghiem bo loc:
% - Nhieu DC 
% - Nhieu duong nen 
% - Nhieu luoi dien 
noise_dc = 2.5; 
noise_baseline = 0.3 * sin(2*pi*0.2*t); 
noise_50hz = 0.15 * sin(2*pi*50*t);
noise_random = 0.05 * randn(size(t));

ecg_raw = ecg_clean + noise_dc + noise_baseline + noise_50hz + noise_random;

% 1.2. Loai bo DC va Chuan hoa 
% Loai bo thanh phan DC 
ecg_no_dc = ecg_raw - mean(ecg_raw);

% Chuan hoa bien do ve khoang [-1, 1] 
ecg_norm = ecg_no_dc / max(abs(ecg_no_dc));

% 1.3. Loc Notch 
f0 = 50;                % Tan so can loc (Hz)
Q = 35;                 % He so chat luong 
wo = f0/(fs/2);         
bw = wo/Q;
[b_notch, a_notch] = iirnotch(wo, bw);
ecg_notch = filtfilt(b_notch, a_notch, ecg_norm);

% 1.4. Loc Thong Dai & Loai bo troi duong nen )
f_low = 0.5;
f_high = 40;
[b_bp, a_bp] = butter(4, [f_low f_high]/(fs/2), 'bandpass');
ecg_final = filtfilt(b_bp, a_bp, ecg_notch);

fprintf('-> Da hoan tat loc nhieu DC, 50Hz va Baseline wander.\n');

%% BƯỚC 2: TRÍCH XUẤT ĐẶC TRƯNG 
fprintf('\n--- BƯỚC 2: TRÍCH XUẤT ĐẶC TRƯNG ---\n');

% 2.1. Phat hien dinh R (R-peak detection)
min_height = 0.5 * max(ecg_final); % Nguong thich nghi
min_dist = 0.5 * fs;               % Khoang cach toi thieu giua 2 dinh (0.5s)

[pks, locs] = findpeaks(ecg_final, 'MinPeakHeight', min_height, ...
                                   'MinPeakDistance', min_dist);

% 2.2. Tinh toan nhip tim (Heart Rate)
% Tinh khoang RR (RR Intervals) don vi giay
rr_intervals = diff(locs) / fs; 

% Nhip tim tuc thoi (BPM)
heart_rate_bpm = 60 ./ rr_intervals;
mean_bpm = mean(heart_rate_bpm);

% 2.3. Trich xuat thong so Bien thien nhip tim (HRV - Time Domain)
sdnn = std(rr_intervals) * 1000; % Don vi ms

% RMSSD: Can bac hai cua trung binh binh phuong hieu so RR lien ke
diff_rr = diff(rr_intervals);
rmssd = sqrt(mean(diff_rr.^2)) * 1000; % Don vi ms

fprintf('-> So dinh R phat hien: %d\n', length(locs));
fprintf('-> Nhip tim trung binh: %.2f BPM\n', mean_bpm);
fprintf('-> HRV (SDNN): %.2f ms\n', sdnn);
fprintf('-> HRV (RMSSD): %.2f ms\n', rmssd);

%% BƯỚC 3: PHÂN TÍCH VÀ ĐÁNH GIÁ (Analysis & Evaluation)
fprintf('\n--- BƯỚC 3: PHÂN TÍCH VÀ ĐÁNH GIÁ ---\n');

% 3.1. Hien thi tin hieu de kiem chung 
figure('Name', 'He Thong Xu Ly ECG', 'Color', 'w', 'Position', [100 100 1000 600]);

subplot(3,1,1);
plot(t, ecg_raw, 'k');
title('1. Tin hieu goc (Raw Signal) - Nhieu DC, 50Hz, Baseline');
ylabel('Bien do'); grid on; xlim([0 5]);

subplot(3,1,2);
plot(t, ecg_final, 'b', 'LineWidth', 1.2);
title('2. Tin hieu sau Tien xu ly (Filtered) - Sach nhieu');
ylabel('Bien do (Norm)'); grid on; xlim([0 5]);

subplot(3,1,3);
plot(t, ecg_final, 'b'); hold on;
plot(t(locs), pks, 'ro', 'MarkerFaceColor', 'r');
for i = 1:length(locs)-1
    text(t(locs(i))+0.1, pks(i), sprintf('RR: %.2fs', rr_intervals(i)));
end
title(['3. Trich xuat dac trung (BPM: ' num2str(round(mean_bpm)) ')']);
xlabel('Thoi gian (s)'); ylabel('Bien do'); grid on; xlim([0 5]);

% 3.2. So sanh voi gia tri tham chieu (Rule-based Check)
% Nhip tim binh thuong: 60 - 100 BPM
fprintf('-> Danh gia trang thai: ');
if mean_bpm < 60
    fprintf('Nhip tim cham (Bradycardia)\n');
    label = 0; % Nhan cho Machine Learning
elseif mean_bpm > 100
    fprintf('Nhip tim nhanh (Tachycardia)\n');
    label = 2;
else
    fprintf('Nhip tim binh thuong (Normal)\n');
    label = 1;
end
