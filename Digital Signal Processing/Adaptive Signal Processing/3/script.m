%% 3.2 Identyfikacja nieznanego systemu za pomocą algorytmu RLS
close all;
clear all;
clc;

h = [1, 0.9, -0.7, 0.5, -0.3, 0.1];

N = 500;
x = randn(1, N);

sigma_d = 0.001;
d = filter(h, 1, x) + sigma_d*randn(1, N);

L = 6;
lambda = 1;

gamma = [1 10 100 1000];

for i = 1:length(gamma)
    [e, y, ff] = rls1(x, d, L, lambda, gamma(i));

    vn = ff - h';
    for j = 1:length(vn)
        err(:,j) = vn(:,j)'*vn(:,j);
    end
    figure(1)
    ax1 = subplot(2,2,i);
    semilogy(ax1, err)
    xlabel('próbka')
    ylabel('błąd')
    title(strcat("gamma: ", num2str(gamma(i)))) % norma błędu estymaty współczynników
    sgtitle('norma błedu estymaty') 
    
    figure(2)
    ax2 = subplot(2,2,i);
    plot(ax2, ff')
    xlabel('próbka')
    ylabel('wartość współczynników')
    title(strcat("gamma: ", num2str(gamma(i))))
    sgtitle('estymowane wartości współczynników filtru') 

    figure(3)
    semilogy(e.^2)
    title('kwadrat błedu')
    legend(string(gamma))
    hold on
end

%% Wnioski
% Większa wartość gammy pozwala szybciej zmniejszyć kwadar błędu i norme błedu estymaty. Wartości
% współczynników szybciej osiągają swoją wartość


%% 3.3. Porównanie szybkości zbieżności oraz poziomu błędu w stanie ustalonym dla algorytmów RLS i LMS
close all;
clear all;
clc;

K = 1000;
N = 500;

sigma_d = 0.001;
gamma = 100;
h = [1, 0.9, -0.7, 0.5, -0.3, 0.1];

lambda = [1, 0.95, 0.9, 0.8];

for i = 1:length(lambda)
    [MSE_e, MSE_f, Mean_f] = rls1_loop(K, N, h, sigma_d, lambda(i), gamma);

    figure(1)
    semilogy(MSE_e)
    hold on
    legend(string(lambda))
    title('Błąd MSE_e')

    avg_err(i) = mean(MSE_e(200:end));

    
    figure(3)
    subplot(2,2,i)
    plot(Mean_f')
    title(strcat("lambda: ", num2str(lambda(i))))
    sgtitle('średnie estymowane wartości współczynników filtru') 
end
avg_err
%% Wnioski
% Większa lambda pozwala szybciej zmniejszyć błąd, ale potem utrzymuje się
% na wyższym poziomie. Lambda  = 1 pozwoliła osiągnać najmniejszy błąd MSE.
alpha = 0.1;

[MSE_e, MSE_f, Mean_f] = lms1_loop(K, N, h, sigma_d, alpha); 

figure(1)
semilogy(MSE_e)
hold on
legend([string(lambda), "LMS"])

figure(4)
plot(Mean_f')
title(strcat("średnie estymowane wartości współczynników filtru alpha: ", num2str(alpha)))
avg_err = mean(MSE_e(200:end))
%% Wnioski
% Algorytm LMS pozwala otrzymać porównywalnie dobre wyniki jednakże czas
% adaptacji jest znacznie dłuższy. Dla algorytm RLS jest to mniej niż 25
% próbek, dla LMS około 100. Algorytm RLS jest szybciej zbieżny, ale wymaga
% większych nakładów obliczeniowych.
%% 3.4. Badania wpływu charakterystyk sygnału wejściowego na zbieżność algorytmów RLS i LMS 
close all;
clear all;
clc;

K = 1000;
N = 500;

sigma_d = 0.001;
gamma = 100;
h = [1, 0.9, -0.7, 0.5, -0.3, 0.1];

lambda = [1, 0.95, 0.9, 0.8];

for i = 1:length(lambda)
    [MSE_e, MSE_f, Mean_f] = rls1_loop_modified(K, N, h, sigma_d, lambda(i), gamma);

    figure(1)
    semilogy(MSE_e)
    hold on
    legend(string(lambda))
    title('Błąd MSE_e')
    avg_err(i) = mean(MSE_e(200:end));
       
    figure(3)
    subplot(2,2,i)
    plot(Mean_f')
    title(strcat("lambda: ", num2str(lambda(i))))
    sgtitle('średnie estymowane wartości współczynników filtru') 
end
avg_err

alpha = 0.1;

[MSE_e, MSE_f, Mean_f] = lms1_loop_modified(K, N, h, sigma_d, alpha); 

figure(1)
semilogy(MSE_e)
hold on
legend([string(lambda), "LMS"])

figure(4)
plot(Mean_f')
title(strcat("średnie estymowane wartości współczynników filtru alpha: ", num2str(alpha)))

avg_err = mean(MSE_e(200:end))

%% Wnioski
% Błąd przy adptacji algorytmem LMS rośnie, algorytm nie działa pooprawnie
% przetwarzając sygnał MA. Algorytm RLS dobrze sobie radzi z przetwarzaniem
% sygnału MA, nie widać zauważalnych różnic jakościowych względem
% poprzedniego punktu.

%% 3.5 Badania możliwości śledzenia zmian parametrów obiektów przez algorytmy RLS i LMS (zadanie dla chętnych) 
close all;
clear all;
clc;

N = 500;
x = randn(1, N); 
h1 = [1, 0.9, -0.7, 0.5, -0.3, 0.1];
h2 = h1 + 0.5;
step_index = 250;
sigma_d = 0.001;
d = step_filter(h1, h2, step_index, x);
d = step_filter(h1, h2, step_index, x) + sigma_d*randn(1,N);


L = 6;
lambda = 1;

gamma = 1000;

% 6x500
h(1:length(h1),1:step_index) = repmat(h1',[1 step_index]);
h(1:length(h1),step_index+1:N) = repmat(h2',[1 step_index]);

% RLS
[e, y, ff] = rls1(x, d, L, lambda, gamma);

vn = ff - h;
for j = 1:length(vn)
    err(:,j) = vn(:,j)'*vn(:,j);
end
figure(1)
ax1 = subplot(2,1,1);
semilogy(ax1, err)
xlabel('próbka')
ylabel('błąd')
title(strcat("RLS gamma: ", num2str(gamma))) % norma błędu estymaty współczynników
sgtitle('norma błedu estymaty') 

figure(2)
ax2 = subplot(2,1,1);
plot(ax2, ff')
xlabel('próbka')
ylabel('wartość współczynników')
title(strcat("RLS gamma: ", num2str(gamma)))
sgtitle('estymowane wartości współczynników filtru') 

figure(3)
semilogy(e.^2)
title('kwadrat błedu')
hold on

% LMS
alpha = 0.1;
[e, y, ff] = lms1(x, d, L, alpha);

vn = ff - h;
for j = 1:length(vn)
    err(:,j) = vn(:,j)'*vn(:,j);
end
figure(1)
ax1 = subplot(2,1,2);
semilogy(ax1, err)
xlabel('próbka')
ylabel('błąd')
title(strcat("LMS alpha: ", num2str(alpha))) % norma błędu estymaty współczynników
sgtitle('norma błedu estymaty') 

figure(2)
ax2 = subplot(2,1,2);
plot(ax2, ff')
xlabel('próbka')
ylabel('wartość współczynników')
title(strcat("LMS alpha: ", num2str(alpha)))
sgtitle('estymowane wartości współczynników filtru') 

figure(3)
semilogy(e.^2)
title('kwadrat błedu')
legend('RLS', 'LMS')
hold on
%% Wnioski
% algorytm LMS znacznie lepiej sobie radzi z śledzeniem zmian parametrów
% obiektu. Błąd maleje znacznie szybciej. Początkowo algorytm RLS szybciej
% dostosowywuje się do sygnału, ale nie radzi sobie ze zmianami.
%% 3.5.1
close all;
clc;

K = 1000;
M = 500;


% RLS
[MSE_e, MSE_f, Mean_f] = rls1_step_loop(K, M, h1, h2, step_index, sigma_d, lambda, gamma);

figure(1)
semilogy(MSE_e)
hold on
title('Błąd MSE_e')
   
figure(3)
subplot(2,1,1)
plot(Mean_f')
title(strcat("RLS lambda: ", num2str(lambda)))
sgtitle('średnie estymowane wartości współczynników filtru') 

% LMS
[MSE_e, MSE_f, Mean_f] = lms1_step_loop(K, M, h1, h2, step_index, sigma_d, alpha);

figure(1)
semilogy(MSE_e)
hold on
title('Błąd MSE_e')
legend('RLS', 'LMS')
   
figure(3)
subplot(2,1,2)
plot(Mean_f')
title(strcat("LMS alpha: ", num2str(alpha)))
sgtitle('średnie estymowane wartości współczynników filtru') 
%% Wnioski
% Podobnie jak w poprzednium punkcie. LMS niezależnie od tego czy zaczyna
% od początku, czy musi się dostosowac do nowego procesu adaptuje się tak
% samo szybko, wolniej niż pierwsza adaptacja RLS, natomiast RLS nie jest w
% stanie się zaadaptować na nowo po zmianie parametrów obiektu. Błąd wtedy
% maleje bardzo wolno.