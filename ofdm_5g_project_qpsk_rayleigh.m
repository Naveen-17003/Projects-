%% OFDM QPSK over AWGN + Rayleigh Fading (Correct Model)
% Fresher / GET resume-ready implementation

clear; clc; close all;

%% System Parameters
Nsub  = 64;      % Number of subcarriers
cpLen = 16;      % Cyclic prefix length
Nsym  = 1000;    % Number of OFDM symbols
bps   = 2;       % bits per symbol (QPSK)

SNRdB = 0:2:20;  % SNR range (dB)

%% Bit Generation
numSymbols = Nsub * Nsym;
numBits    = numSymbols * bps;

txBits = randi([0 1], numBits, 1);

%% QPSK Modulation (Manual)
bitPairs = reshape(txBits, bps, []).';

I = 2*bitPairs(:,1) - 1;
Q = 2*bitPairs(:,2) - 1;
txSymbols = (I + 1j*Q) / sqrt(2);   % Unit power

%% OFDM Mapping
dataGrid = reshape(txSymbols, Nsub, Nsym);

%% IFFT (OFDM Modulation)
txIFFT = ifft(dataGrid, [], 1);

%% Add Cyclic Prefix
cp = txIFFT(end-cpLen+1:end, :);
txWithCP = [cp; txIFFT];            % (Nsub+cpLen) x Nsym

%% Rayleigh Channel (Flat-fading per OFDM symbol)
h = (randn(1, Nsym) + 1j*randn(1, Nsym)) / sqrt(2);

%% BER Initialization
ber = zeros(size(SNRdB));

%% SNR Loop
for k = 1:length(SNRdB)

    %% Channel Application
    rxWithCP = zeros(Nsub+cpLen, Nsym);
    for n = 1:Nsym
        rxWithCP(:, n) = h(n) * txWithCP(:, n);
    end

    %% Add AWGN
    rxSerial = awgn(rxWithCP(:), SNRdB(k), 'measured');

    %% Receiver Processing
    rxWithCP = reshape(rxSerial, Nsub+cpLen, Nsym);
    rxNoCP   = rxWithCP(cpLen+1:end, :);

    %% FFT (OFDM Demodulation)
    rxFFT = fft(rxNoCP, [], 1);

    %% Equalization (Perfect CSI)
    for n = 1:Nsym
        rxFFT(:, n) = rxFFT(:, n) / h(n);
    end

    rxSymbols = rxFFT(:);

    %% QPSK Demodulation
    rxBitsI = real(rxSymbols) > 0;
    rxBitsQ = imag(rxSymbols) > 0;
    rxBits  = reshape([rxBitsI rxBitsQ].', [], 1);

    %% BER Calculation
    ber(k) = sum(txBits ~= rxBits) / numBits;

    fprintf('SNR = %2d dB, BER = %.6g\n', SNRdB(k), ber(k));
end

%% BER Plot
figure;
semilogy(SNRdB, ber, '-o', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('OFDM QPSK over AWGN + Rayleigh Fading');
