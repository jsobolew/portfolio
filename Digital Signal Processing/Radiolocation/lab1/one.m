clc
clear all, close all;

B = 5e6;
Timp = 10e-6;
r0 = 10e3;
fs = 10e6;

r = 0:3e8/fs/2:20e3;

x = mychirp(r,r0,B,Timp);

figure(1)
plot(r,real(x),r,imag(x))
%% filtr dopasowany
rh = (-Timp/2:1/fs:Timp/2)*3e8/2;

h = mychirp(rh,0,B,Timp);

h = conj(h(end:-1:1));

figure(2)
plot(rh,real(h),rh,imag(h))

y = filter(h,1,x);

rf = r - Timp/2*3e8/2;

figure(3)
plot(rf,abs(y))
%% ró¿ne d³ugoœci impulsów
clc
clear all, close all;

B = 5e6;
r0 = 10e3;
fs = 10e6;

Timp1 = 10e-6;
Timp2 = 100e-6;

r = 0:3e8/fs/2:50e3;
r0 = 10e3;

x1 = mychirp(r,r0,B,Timp1);
x2 = mychirp(r,r0,B,Timp2);

w = randn(size(r)) + 1j*randn(size(r));

x1 = x1 + w;
x2 = x2 + w;

rh1 = (-Timp1/2:1/fs:Timp1/2)*3e8/2;
h1 = mychirp(rh1,0,B,Timp1);
h1 = conj(h1(end:-1:1));
y1 = filter(h1,1,x1)/length(h1);
rf1 = r - Timp1/2*3e8/2;

rh2 = (-Timp2/2:1/fs:Timp2/2)*3e8/2;
h2 = mychirp(rh2,0,B,Timp2);
h2 = conj(h2(end:-1:1));
y2 = filter(h2,1,x2)/length(h2);
rf2 = r - Timp2/2*3e8/2;

figure(3)
plot(rf1,20*log10(abs(y1)),rf2,20*log10(abs(y2)))
legend('y1','y2')
%% rozró¿nialnoœæ odleg³oœciowa
% delta_r = c/2*B;
clc
clear all, close all;

B = 5e6;
r0 = 10e3;
fs = 10e6;

Timp = 10e-6;
r = 0:3e8/fs/2:20e3;

delta_r = 3e8/(2*B)

x1 = mychirp(r,r0,B,Timp);
x2 = mychirp(r,r0+60,B,Timp);

x = x1 + x2;

w = 0.1*randn(size(r)) + 0.1j*randn(size(r));

x = x + w;


rh = (-Timp/2:1/fs:Timp/2)*3e8/2;
h = mychirp(rh,0,B,Timp);
h = conj(h(end:-1:1));
h = h.*hamming(length(h))'; %filtr niedopasowany

y = filter(h,1,x);

rf = r - Timp/2*3e8/2;

figure(3)
plot(rf,20*log10(abs(y)))

%% to samo plus doppler
clc
clear all, close all;

B = 5e6;
r0 = 10e3;
fs = 10e6;

Timp = 10e-6;
r = 0:3e8/fs/2:20e3;

lambda = 3e-2;
Vr = 3000;

fd = -2*Vr/lambda;

x1 = mychirp(r,r0,B,Timp);
x2 = x1.*exp(1j*2*pi*fd/fs*(1:length(r)));

w = 0.1*randn(size(r)) + 0.1j*randn(size(r));
x1 = x1 + w;
x2 = x2 + w;


rh = (-Timp/2:1/fs:Timp/2)*3e8/2;
h = mychirp(rh,0,B,Timp);
h = conj(h(end:-1:1));

y1 = filter(h,1,x1);
y2 = filter(h,1,x2);

rf = r - Timp/2*3e8/2;

figure(3)
plot(rf,20*log10(abs(y1)),rf,20*log10(abs(y2)))





