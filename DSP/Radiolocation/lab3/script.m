% CELL AVERAGING

B = 5e6;
Timp = 10e-6;
r0 = 10e3;
fs = 10e6;

r = 0:3e8/fs/2:20e3;

x = mychirp(r,r0,B,Timp);

w = randn(size(r)) + 1j*randn(size(r));

x = x + w;
rh = (-Timp/2:1/fs:Timp/2)*3e8/2;

h = mychirp(rh,0,B,Timp);
y = filter(h,1,x);
figure(1)
plot(r,db(y))
%% zad 1 z lab 1
% rozró¿nialnoœæ odleg³oœciowa
% delta_r = c/2*B;
clc
clear all, close all;

B = 5e6;
r0 = 10e3;
fs = 10e6;

Timp = 10e-6;
r = 0:3e8/fs/2:20e3;

delta_r = 3e8/(2*B);

x1 = mychirp(r,r0,B,Timp);

x = x1;

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

%%
N_ref = 8;
N_guard = 3;
T = 10^(13/20); 
%T = 13;

[noise_est, det_vect] = ca_cfar(abs(y), N_ref, N_guard, T);

plot(rf, db(y),rf,db(noise_est),rf,db(noise_est)+13,rf,det_vect)

%% rozró¿nialnoœæ odleg³oœciowa 2 obiekty obok siebie
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
x2 = mychirp(r,r0+100,B,Timp);

x = x1 + x2;

w = 0.1*randn(size(r)) + 0.1j*randn(size(r));
w(round(end/2):end)=10*w(round(end/2):end);%---------------------

x = x + w;


rh = (-Timp/2:1/fs:Timp/2)*3e8/2;
h = mychirp(rh,0,B,Timp);
h = conj(h(end:-1:1));
h = h.*hamming(length(h))'; %filtr niedopasowany

y = filter(h,1,x);

rf = r - Timp/2*3e8/2;

figure(3)
plot(rf,20*log10(abs(y)))
%%
w(round(end/2):end)=10*w(round(end/2):end);

%%
%% krawedz clutteru
% rozró¿nialnoœæ odleg³oœciowa
% delta_r = c/2*B;
clc
clear all, close all;

B = 5e6;
r0 = 9.4e3;
fs = 10e6;

Timp = 10e-6;
r = 0:3e8/fs/2:20e3;

delta_r = 3e8/(2*B);

x1 = mychirp(r,r0,B,Timp);

x = x1;

w = 0.1*randn(size(r)) + 0.1j*randn(size(r));
w(round(end/2):end)=10*w(round(end/2):end);%---------------------

x = x + w;


rh = (-Timp/2:1/fs:Timp/2)*3e8/2;
h = mychirp(rh,0,B,Timp);
h = conj(h(end:-1:1));
h = h.*hamming(length(h))'; %filtr niedopasowany

y = filter(h,1,x);

rf = r - Timp/2*3e8/2;

figure(3)
plot(rf,20*log10(abs(y)))
%%
N_ref = 32;
N_guard = 10;
T = 10^(13/20); 
%T = 13;

[noise_est, det_vect] = os_cfar(abs(y), N_ref, N_guard, T);

plot(rf, db(y),rf,db(noise_est),rf,db(noise_est)+13,rf,det_vect)