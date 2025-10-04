# 📡 OFDM Transceiver Simulation in MATLAB  

This repository contains a MATLAB implementation of a **basic Orthogonal Frequency Division Multiplexing (OFDM) transceiver**, one of the core technologies powering **4G LTE and 5G NR** wireless standards.  

The project explores key system components, performance evaluation, and fundamental trade-offs in OFDM-based communication.  

---

## 🔹 System Features  
- **QPSK Modulation/Demodulation**  
- **OFDM Modulation (IFFT/FFT) with Cyclic Prefix**  
- **Frequency-Selective Rayleigh Fading Channel (multi-tap)**  
- **Additive White Gaussian Noise (AWGN)**  
- **Zero-Forcing Equalizer** (assuming channel knowledge per OFDM symbol)  

---

## 🔹 Simulation Results  

### 1️⃣ BER vs. SNR Curve  
- Evaluates system reliability under fading + AWGN.  
- Demonstrates expected QPSK performance with ZF equalization.  

### 2️⃣ Constellation Diagram (Post-Equalization)  
- Verifies symbol recovery for QPSK at a chosen SNR point.  

### 3️⃣ PAPR Analysis  
- Peak-to-Average Power Ratio (PAPR) measured across OFDM symbols.  
- **CCDF Plot** shows probability distribution of high PAPR events.  
- Typical values observed:  
  - Mean PAPR ≈ **6.7 dB**  
  - 99th percentile ≈ **9.3 dB**  

---

## 🔹 Insights & Takeaways  
- **OFDM** provides robustness against multipath fading, ensuring reliable transmission in wireless channels.  
- **High PAPR** is an inherent drawback, leading to power amplifier efficiency challenges.  
- These trade-offs are central to why OFDM has become the foundation of modern wireless communication.  

---

## 📂 Repository Structure  
├── ofdm_main.m # Main MATLAB script

├── utils/ # (Optional) Helper functions if modularized

├── results/ # Simulation figures (BER, Constellation, PAPR CCDF)

└── README.md # Project documentation

---

## 🚀 How to Run  
1. Clone the repository:  
   git clone https://github.com/akshat-137/OFDM-Model-Simulation.git

   cd OFDM-Model-Simulation
3. Open OFDM_simulation.m in MATLAB/Octave.
4. Run the script to generate BER, constellation, and PAPR plots.

---

## 📖 References
- S. Haykin, Digital Communication Systems
- T. Rappaport, Wireless Communications: Principles and Practice
- NPTEL Course: Principles of CDMA, MIMO, and OFDM Wireless Communications

----

## 👨‍🎓 Author

Akshat

Pre-final year B.Tech in Electronics & Communication Engineering

Exploring Wireless Communications, Signal Processing, and Analog VLSI

