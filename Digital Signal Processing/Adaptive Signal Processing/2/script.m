%% 3.2.1
clear variables;
close all;
clc

M = 1000;
x1 = randn(1, M);
x2 = cos(2*pi*0.1*(0:M-1));

EX1 = mean(x1.^2);
EX2 = mean(x2.^2);

L = [5, 10, 20];
h = [1 0 0 0 0];

for i = 1:length(L)
    alfa_max_x1(i) = 2/(L(i)*EX1);
    alfa_max_x2(i) = 2/(L(i)*EX2);
end

coef = [1.001 1 0.9 0.8];
for i = 1:length(coef)
    [e, y, ff] = lms1(x2, x2, L(1), alfa_max_x2(1)*coef(i));
    
    vn = ff - h';
    for j = 1:length(vn)
        err(:,j) = vn(:,j)'*vn(:,j);
    end
    figure(1)
    ax1 = subplot(2,2,i);
    semilogy(ax1, err)
    xlabel('próbka')
    ylabel('błąd')
    title(strcat("coef: ", num2str(coef(i)))) % norma błędu estymaty współczynników
    
    figure(2)
    ax2 = subplot(2,2,i);
    plot(ax2, ff')
    xlabel('próbka')
    ylabel('wartość współczynników')
    title(strcat("coef: ", num2str(coef(i))))

    figure(3)
    semilogy(e.^2)
    title('kwadrat błedu')
    legend(string(coef))
    hold on
end

%% 3.2.2
L=5;
x11=(2*rand(1,M)-1)';
x12=(2*rand(1,M)-1)';

EX=mean(x12.^2);
alfa_max=2/(L*EX);

figure(3)

coef = [0.05 0.2 0.5 0.8];
for i = 1:length(coef)

    [e, y, ff] = lms1(x12, x11, L, coef(i)*alfa_max);
    semilogy(e.^2)
    hold on
end


legend(string(coef))
hold off
%% 3.3.1
clear variables;
close all;
clc

h = [1, -0.8, 0.6, -0.4, 0.2];
L = 5;
M = 500;
sigma_d = 0.001;

x = randn(1, M); 
d = filter(h, 1, x) + sigma_d*randn(1, M);

alfa = [0.025, 0.05, 0.1, 0.2];

for i = 1:length(alfa)
    [e, y, ff] = lms1(x, d, L, alfa(i));
    
    vn = ff - h';
    for j = 1:length(vn)
        err(:,j) = vn(:,j)'*vn(:,j);
    end
    figure(1)
    ax1 = subplot(2,2,i);
    semilogy(ax1, err)
    xlabel('próbka')
    ylabel('błąd')
    title(strcat("alfa: ", num2str(alfa(i)))) % norma błędu estymaty współczynników
    
    figure(2)
    ax2 = subplot(2,2,i);
    plot(ax2, ff')
    xlabel('próbka')
    ylabel('wartość współczynników')
    title(strcat("alfa: ", num2str(alfa(i))))

    figure(3)
    semilogy(e.^2)
    title('kwadrat błedu')
    legend(string(alfa))
    hold on
end
%% 3.3.2 i 3.3.3
clear variables;
close all;
clc

K = 5000;
h = [1, -0.8, 0.6, -0.4, 0.2];
M = 500;
sigma_d = 0.001;
alpha = [0.025, 0.05, 0.1, 0.2];

for i = 1:length(alpha)
    [MSE_e, MSE_f, Mean_f] = lms1_loop(K, M, h, sigma_d, alpha(i)); 
    
    L = length(h);
    Jmin=1e-6;
    blad_teoretyczny(i)=Jmin*(1+(alpha(i)/2)*L*1);
    blad_empiryczny(i)=mean(MSE_e(400:500));
    niedopasowanie_teoretyczne(i)=(blad_teoretyczny(i)-Jmin)/Jmin;
    niedopasowanie_empiryczne(i)=(blad_empiryczny(i)-Jmin)/Jmin;

    figure(1)
    subplot(2,2,i)
    semilogy(MSE_e)
    title(strcat("alfa: ", num2str(alpha(i))))
    
    figure(2)
    subplot(2,2,i)
    plot(MSE_f')
    title(strcat("alfa: ", num2str(alpha(i))))
    
    figure(3)
    subplot(2,2,i)
    plot(Mean_f')
    title(strcat("alfa: ", num2str(alpha(i))))
end


