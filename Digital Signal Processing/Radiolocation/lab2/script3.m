close all
clear all

N = 10;
Nfft =  20;
fd = 275;
prf = 1000;

n = 1:N;
x = exp(1j*2*pi*fd/prf*n).*hamming(N)';

X = fftshift(fft(x, Nfft));

f = linspace(-0.5, 0.5-1/Nfft, Nfft)*prf;

plot(f, abs(X))