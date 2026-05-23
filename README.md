# EEG & ECG Signal Processing in MATLAB

<br>
<div align="center">
  <img width="600" alt="system_flowchart" src="https://github.com/user-attachments/assets/3cb20942-b6fb-4198-a183-54d705d29ff0" />
</div>
<br>

This repository contains MATLAB source code for simulating, preprocessing, analyzing, and extracting features from two primary physiological signals: Electrocardiogram (ECG) and Electroencephalogram (EEG).

## 🎯 Code Objectives

### 1. Electrocardiogram (ECG) Signal (`ECG.m`)

<br>
<div align="center">
  <img width="407" height="321" alt="ecg_theory png" src="https://github.com/user-attachments/assets/039f6ce6-f636-47b0-be1d-d96a4cf254c9" />
</div>
<br>

This script focuses on a step-by-step ECG signal processing pipeline:

- **Simulation & Noise Addition:** Generates a synthetic sample ECG signal and simulates real-world noises (DC offset, baseline wander, 50Hz powerline interference, and random Gaussian noise).
- **Preprocessing:** Removes DC offset, normalizes amplitude, applies a Notch filter to eliminate the 50Hz powerline noise, and utilizes a Bandpass filter (0.5 - 40Hz) to clean the signal.
- **Feature Extraction:**
  - R-peak detection.
  - Calculates average Heart Rate (BPM).
  - Computes time-domain Heart Rate Variability (HRV) parameters, including SDNN and RMSSD.

<br>
<img width="100%" alt="ecg_processing_results png" src="https://github.com/user-attachments/assets/e9969f6e-aac6-4f25-b3e4-ba9e145c4845" />
<br>

- **Automated Evaluation:** Basic classification of heart rate states (Normal, Bradycardia, Tachycardia) based on calculated BPM.

### 2. Electroencephalogram (EEG) Signal (`EEG.m`)

This script performs in-depth simulation and analysis of characteristic brain wave bands:

- **Brainwave Simulation:** Generates a composite EEG signal by combining specific frequency bands (Delta, Theta, Alpha, Beta, Gamma) with added noise.

<br>
<div align="center">
  <img width="530" height="726" alt="simulation_parameters png" src="https://github.com/user-attachments/assets/867c1c08-6776-44e4-bc0e-e8dcbe910cd9" />
</div>
<br>

- **Preprocessing:** Removes DC components and applies a Bandpass filter (1 - 45Hz).
- **Frequency & Time-Frequency Analysis:**
  - Frequency spectrum analysis using Fast Fourier Transform (FFT).
  - Spectrogram visualization to observe frequency distribution changes over time.
  - Continuous Wavelet Transform (CWT) analysis for evaluating non-stationary and non-linear signals.
- **Energy Calculation:** Extracts and compares the power levels (µV²) of individual brainwave bands (Delta, Theta, Alpha, Beta, Gamma).

<br>
<img width="100%" alt="eeg_cwt_spectrogram png" src="https://github.com/user-attachments/assets/ae0924cd-de96-4e82-b4ba-0344a7730d65" />
<br>

## 🛠️ Prerequisites

To run these scripts without errors, your MATLAB environment must have the following toolboxes installed:

- **MATLAB** (R2019a or later recommended)
- **Signal Processing Toolbox** (Required for functions such as `butter`, `filtfilt`, `iirnotch`, `findpeaks`, `spectrogram`)
- **Wavelet Toolbox** (Required for the `cwt` function in `EEG.m`)

## 🚀 How to Use

1. Clone this repository to your local machine or download the two `.m` files directly.
2. Open MATLAB and navigate the **Current Folder** to the directory containing the source code.
3. Open either `ECG.m` or `EEG.m` and click **Run** (or press F5). View the output metrics in the Command Window and observe the generated visualizations (Figures).
