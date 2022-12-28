clear all, close all;

N = 500;
%noise
w = randn(N,1) + 1j*randn(N,1);
W = fftshift(fft(w));

% krzywa dzwonowa
sigc = 0.05;
f= linspace(-0.5,0.5-1/N,N);
G = exp(-f.^2/(2*sigc^2));
W = W.*G';
% clutter signal
c = ifft(fftshift(W));

n = 1:N;
plot(n,real(w),n,real(c))

h2 = [1,-1];
h3 = [1,-2,1];

y2 = filter(h2,1,c);
y3 = filter(h3,1,c);

figure(1)
plot(n,real(c),n,real(y2),n,real(y3))

figure(2)
plot(n,abs(W),n,abs(fftshift(fft(y2))),n,abs(fftshift(fft(y3))))

% charakterystyki filtrów
H2 = fftshift(abs(fft(h2,N)));
H3 = fftshift(abs(fft(h3,N)));

figure(3)
plot(n,H2,n,H3)
