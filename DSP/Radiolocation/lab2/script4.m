clear all
close all

fd = 1000;
prf1 = 900;
prf2 = 1000;
N = 10;
n = 1:N;

x1 = exp(1j*2*pi*fd/prf1*n);
x2 = exp(1j*2*pi*fd/prf2*n);

X1 = fftshift(abs(fft(x1)));
X2 = fftshift(abs(fft(x2)));

f1 = linspace(-0.5, 0.5-1/N, N)*prf1;
f2 = linspace(-0.5, 0.5-1/N, N)*prf2;

plot(f1,X1,f2,X2)