%% 1
a_1 = [-0.9 -1 -1.1];
for i = 1:3
    B = 1; A = [1, a_1(i)];
    subplot(3,3,i)
    zplane(B, A); 
    [H, f] = freqz(B, A, [], 1); 
    subplot(3,3,3+i)
    plot(f, 20*log10(abs(H))); grid; 
    subplot(3,3,6+i)
    impz (B, A); 
end
%% 2
N = 1000; w = randn(N, 1); 
[R, lags] = xcorr(w, 'biased'); 
figure(1)
plot(lags, R); grid; 
title('estymata funkcji autokorelacji')

[S_per, f] = periodogram(w, [], [], 1);
figure(2)
plot(f, 10*log10(S_per)); grid;
title('periodogram')

S_cor = abs(fftshift(fft(R))); 
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(3)
plot(f, 10*log10(S_cor)); grid; 
title('korelogram')
%% 3
a_1 = -0.9; 
B = 1; A = [1, a_1];
x = filter(B, A, w);
[R, lags] = xcorr(x, 'biased'); 
plot(lags, R); grid; 
title('AR(1)')

[S_per, f] = periodogram(x, [], [], 1); 
figure(4)
plot(f, 10*log10(S_per)); grid; 
title('periodogram')

S_cor = abs(fftshift(fft(R))); 
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(5)
plot(f, 10*log10(S_cor)); grid; 
title('korelogram')

figure(100)
hold on
plot(x)
plot(w)
legend('AR(1)', 'szum')
%% 4
p = [1, 2, 3, 5, 10];
for i = 1:5
    [S_yw, f_x] = pyulear(x, p(i));
    subplot(1,5,i)
    plot(f_x/(2*pi), 10*log10(S_yw)); grid;
    title(strcat("p: ", num2str(p(i)), "  E: ", num2str(E(i))))
    [A_est{i}, E(i)] = aryule(x, p(i));
end
%% 3.2.1
B = 1; A = [1, -1.7, 1.1];
figure(1)
zplane(B, A); 
[H_m, f_m] = freqz(B, A); 
figure(2)
plot(f_m/(2*pi), 20*log10(abs(H_m))); grid; 

figure(3)
impz (B, A); 
 %%
N = 1000; w = randn(N,1); 
x = filter(B, A, w); 

figure(100)
hold on
plot(x)
plot(w)
legend('AR(2)', 'szum')
%%
[R, lags] = xcorr(x, 'biased');
figure(1)
plot(lags, R); grid; 
title('estymata funkcji autokorelacji')
[Sxx, f_x] = periodogram(x); 
figure(2)
plot(f_x/(2*pi),10*log10(Sxx)); grid; 
title('periodogram')
S_cor = abs(fftshift(fft(R)));
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(3)
plot(f, 10*log10(S_cor)); grid;
title('korelogram')
%%
p = [1, 2, 3, 5, 10];
for i = 1:5
    [S_yw, f_x] = pyulear(x, p(i));
    subplot(1,5,i)
    plot(f_x/(2*pi), 10*log10(S_yw)); grid;
    title(strcat("p: ", num2str(p(i)), "  E: ", num2str(E(i))))
    [A_est{i}, E(i)] = aryule(x, p(i));
end
%% idelane
y_id = filter(A, B, x); 
R_id = xcorr(y_id, 'biased'); 
figure(1)
plot(-N+1:N-1, R_id); grid; 
title('funkcji autokorelacji')

S_cor = abs(fftshift(fft(R_id))); 
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(2)
plot(f, 10*log10(S_cor)); grid;
title('korelogram')

% estymowane
p = 5;
[A_est, E] = aryule(x, p) 
y_est = filter(A_est, B, x); 
[R_est, lags] = xcorr(y_est, 'biased'); 
figure(3)
plot(lags, R_est); grid 
title('estymata funkcji autokorelacji')

S_cor = abs(fftshift(fft(R_est))); 
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(4)
plot(f, 10*log10(S_cor)); grid;
title('korelogram estymowany')
%% 
clear A_est, E;
p = [1,2,5];
for i = 1:length(p)
    [A_est, E(i)] = aryule(x, p(i));
    A_est_save{i} = A_est;
    x_p = filter(-A_est(2:p(i)+1), 1, x);
    subplot(3,1,i)
    plot(1:N-1, x(2:N), 'r', 1:N-1, x_p(1:N-1), 'g'); grid; 
    title(strcat("p: ", num2str(p(i)), "  E: ", num2str(E(i))))
    abs(sum(sqrt(x.^2-x_p.^2))/length(x))
end
%%
B = [1, 1.5, 0.95]; A = [1, -1.7, 0.95]; 
subplot(1,3,1)
zplane(B, A);
[H_m, f_m] = freqz(B, A); 
subplot(1,3,2)
plot(f_m/(2*pi), 20*log10(abs(H_m))); grid;
subplot(1,3,3)
impz (B, A);
%%
N = 1024; w = randn(N,1); 
x = filter(B, A, w); 

figure(100)
hold on
plot(x)
plot(w)
legend('AR(2,2)', 'szum')
%%
[R, lags] = xcorr(x, 'biased');
figure(1)
plot(lags, R); grid; 
title('estymata funkcji autokorelacji')
[Sxx, f_x] = periodogram(x); 
figure(2)
plot(f_x/(2*pi),10*log10(Sxx)); grid; 
title('periodogram')
S_cor = abs(fftshift(fft(R)));
S_cor = [S_cor(N); 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
figure(3)
plot(f, 10*log10(S_cor)); grid;
title('korelogram')
%%
p = [1, 2, 5, 10, 20];
for i = 1:length(p)
    [S_yw, f_x] = pyulear(x, p(i));
    subplot(length(p),1,i)
    plot(f_x/(2*pi),10*log10(S_yw)); grid; 
    title(strcat("p: ", num2str(p(i))))
end
%% 3.4
N = 1000; 
s1 = sin(2*pi*0.15*(1:N)); 
s2 = sin(2*pi*0.16*(1:N)); 
w = 2*randn(1, N); 
s = s1 + s2 + w; 
%%
subplot(3,1,1)
plot(s); 
title('sygnał')

[R, lags] = xcorr(s, 'biased'); 
subplot(3,1,2)
plot(lags, R); grid; 
title('estymata funkcji autokorelacji')

S_cor = abs(fftshift(fft(R))); 
S_cor = [S_cor(N), 2*S_cor(N+1:2*N-1)]; 
f = (0:N-1)/(2*N-1); 
subplot(3,1,3)
plot(f, 10*log10(S_cor)); grid;
title('korelogram')
%%
clear A_est;
p = [5, 10, 20, 50, 60];
% p = [8];
for i  = 1:length(p)
    [S_yw, f_s] = pyulear(s, p(i)); 
    subplot(length(p),1,i)
    [A_est{i}, E(i)] = aryule(s, p(i));
    plot(f_s/(2*pi),10*log10(S_yw)); grid;
    title(strcat("p: ", num2str(p(i)), "  E: ", num2str(E(i))))
end
%% dodatkowe
v = 1:5;
p = 50;
for i  = 1:length(v)
    N = 1000; 
    s1 = sin(2*pi*0.15*(1:N)); 
    s2 = sin(2*pi*0.25*(1:N)); 
    w = v(i)*randn(1, N); 
    s = s1 + s2 + w; 
    [S_yw, f_s] = pyulear(s, p); 
    subplot(length(v),1,i)
    [A_est{i}, E(i)] = aryule(s, p);
    plot(f_s/(2*pi),10*log10(S_yw)); grid;
    title(strcat("p: ", num2str(p),"  var: ", num2str(v(i)^2), "  E: ", num2str(E(i))))
end
%% var vs p
p = 1:500;
v = 1:10;
for i = 1:length(p)
    for j = 1:length(v)
    N = 1000; 
    s1 = sin(2*pi*0.15*(1:N)); 
    s2 = sin(2*pi*0.25*(1:N)); 
    w = v(j)*randn(1, N); 
    s = s1 + s2 + w; 
    [S_yw, f_s] = pyulear(s, p(i)); 
    [~, E(i,j)] = aryule(s, p(i));
    plot(f_s/(2*pi),10*log10(S_yw)); grid;
    end
end

surf(E)
xlabel('zadane odchylenie standardowe')
ylabel('zadany rząd p')
zlabel('wartość wariancji estymaty')

