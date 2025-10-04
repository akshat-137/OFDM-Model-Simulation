clc;
clear ;
close all;

subcarriers = 64 ;
cp_len = 16 ; % Cyclic Prefix Length
data_symbols = 2000 ;
mod_order = 4 ; % for QPSK
bits_per_sym = log2(mod_order) ;
SNR_db = 0:2:20 ;

taps = 4 ;
tap_delay = 0:(taps-1) ;
tap_power_db = [0 -3 -6 -9] ; % assumption
tap_power = 10.^(tap_power_db/10) ;
tap_power = tap_power / sum(tap_power) ;

num_bits = data_symbols * subcarriers * bits_per_sym ;
rng(1) ; % rng(): Random Number Generator 

QPSK_mod = @(bits) (1/sqrt(2)) * ((1-2*bits(:,1)) + 1*j*(1-2*bits(:,2))) ;
QPSK_demod = @(sym) [ real(sym) < 0 , imag(sym) < 0 ] ;

bits = randi([0 1] , num_bits , 1) ;

bits_reshaped = reshape(bits , bits_per_sym , []).' ;
symbols = QPSK_mod(bits_reshaped);

symbols = reshape( symbols , subcarriers , []) ;

papr_vals = zeros(1 , size(symbols,2)) ;
for i = 1 : size(symbols,2) 
    tx_ifft = ifft(symbols(:,i) , subcarriers) ;
    P_peak = max(abs(tx_ifft).^2) ;
    P_avg = mean(abs(tx_ifft).^2); 
    papr_vals(i) = 10*log10(P_peak / P_avg); 
end

papr_threshold = 0:0.25:12 ;
ccdf = zeros(size(papr_threshold)) ;
for idx = 1:length(papr_threshold)
    ccdf(idx) = mean(papr_vals > papr_threshold(idx)) ;
end

BER = zeros(size(SNR_db)) ;

for k = 1:length(SNR_db)
    snr_db = SNR_db(k) ;
    snr_lin = 10^(snr_db/10) ;
    error_bits = 0 ;
    total_bits = 0 ;
    for sym_k = 1 : size(symbols ,2)
        %....TRANSMITTER...
        X = symbols(: , sym_k) ; % Freq. domain QPSK symbol
        x_time = ifft(X , subcarriers) ; % Time Domain OFDM Symbol 
        tx_with_cp = [ x_time(end - cp_len + 1 : end) ; x_time] ;
        % CHANNEL : freq. selective block fading
        h_taps = (randn(taps,1) + 1*j*randn(taps,1))/sqrt(2) ;
        for tt = 1:taps
            h_taps(tt) = h_taps(tt) * sqrt(tap_power(tt)) ;
        end
        h = zeros(max(tap_delay) + 1 , 1) ; % channel impulse response vector
        h(tap_delay + 1) = h_taps;
        rx_channel = conv(tx_with_cp , h) ;
        %....AWGN....
        signal_power = mean(abs(tx_with_cp).^2) * sum(abs(h).^2) ; 
        noise_var = signal_power / snr_lin ;
        noise = sqrt(noise_var / 2) * (randn(size(rx_channel)) + 1*j*randn(size(rx_channel))) ;
        rx = rx_channel + noise ;
        %....RECIEVER....
        rx_no_cp = rx(cp_len + 1 : cp_len + subcarriers) ;
        Y = fft(rx_no_cp , subcarriers) ; 
        H = fft(h , subcarriers) ; % freq. response of channel on subcarriers
        X_hat = Y ./ H ; % zero forcing equalization

        rx_bits_mat = QPSK_demod(X_hat).' ;
        rx_bits = rx_bits_mat(:) ;

        orig_bits_start = (sym_k - 1) * subcarriers * bits_per_sym + 1 ;
        orig_bits_end = sym_k * subcarriers * bits_per_sym ;
        orig_bits = bits(orig_bits_start : orig_bits_end) ;

        error_bits = error_bits + sum(orig_bits ~= rx_bits) ;
        total_bits = total_bits + length(orig_bits) ;
    end
    BER(k) = error_bits / total_bits;
    fprintf('SNR = %2d dB , BER = %.5e\n' , snr_db , BER(k)) ;
end

figure(1) ;
semilogy(papr_threshold ,ccdf , 'LineWidth', 2) ;
grid on ;
xlabel('Peak to Avg. Power Ratio (PAPR) threshold (dB)') ;
ylabel('CCDF (Pr(PAPR > threshold))') ;
title('OFDM PAPR CCDF (per OFDM symbol , QPSK , N = 64)') ;
xlim([0 max(papr_threshold)]) ;
ylim([1e-4 1]) ;

figure(2) ;
semilogy(SNR_db ,BER , '-o' , 'LineWidth', 2);
grid on ;
xlabel('SNR (dB)') ;
ylabel('Bit Error Rate') ;
title('BER vs SNR - OFDM over Rayleigh Multipath + AWGN (ZF equalizer)') ;
xlim([min(SNR_db) max(SNR_db)]) ;

mid_idx = ceil(length(SNR_db)/2) ;
snr_db = SNR_db(mid_idx) ;
snr_lin = 10^(snr_db/10) ;

sym_idx = 1 ;
X = symbols(:,sym_idx) ;
x_time = ifft(X,subcarriers) ;
tx_with_cp = [x_time(end-cp_len + 1 : end) ; x_time] ;

h_taps = (randn(taps,1) + 1*j*randn(taps,1))/sqrt(2);
for tt = 1 : taps
    h_taps(tt) = h_taps(tt) * sqrt(tap_power(tt)); 
end
h = zeros(max(tap_delay) + 1, 1);
h(tap_delay + 1) = h_taps;
rx_channel = conv(tx_with_cp, h); % Channel response
signal_power = mean(abs(tx_with_cp).^2) * sum(abs(h).^2); 
noise_var = signal_power / snr_lin; 
noise = sqrt(noise_var / 2) * (randn(size(rx_channel)) + 1*j*randn(size(rx_channel))); 
rx = rx_channel + noise; % Received signal after adding noise
rx_no_cp = rx(cp_len + 1 : cp_len + subcarriers);
Y = fft(rx_no_cp, subcarriers);
H = fft(h, subcarriers); % Frequency response of channel on subcarriers
X_hat = Y ./ H; % Zero forcing equalization

figure(3) ;
scatter(real(X_hat) , imag(X_hat) , 10 , 'filled') ; 
axis equal ;
grid on ;
xlabel('In - Phase') ;
ylabel(' Quadrature') ;
title( sprintf('Post-equalization constellation ( SNR = %d dB)' , snr_db)) ;

fprintf('\n Peak to Average Power Ratio Statistics (per OFDM symbol , dB) : \n') ;
fprintf(' Minimum Peak to Avg. Power Ratio = %.2f dB\n' , min(papr_vals)) ;
fprintf(' Median = %.2f dB\n' , median(papr_vals)) ;
fprintf(' Mean = %.2f dB\n' , mean(papr_vals)) ; 
fprintf(' 99th percentile = %.2f dB\n' , prctile(papr_vals , 99)) ;
