%% APSG lab 5
% Jakub Sobolewski
%% 3.2.1 Generacja sekwencji treningowej i testowej symboli modulacji QAM 
clc
clear all
close all
M = 64; 
x = (0: M - 1)'; 
q = qammod(x, M, 'InputType','integer','UnitAveragePower', true, 'PlotConstellation', true);


scatterplot(q); 
title('Constellation'); grid;

%% 3.2.2
N_train = 2000; 
train_sym_ind = [9; 13; 41; 45]; 
train_bit_mat = de2bi(train_sym_ind, log2(M), 'left-msb'); 
train_bit_seq = reshape(train_bit_mat', 1, []); 
train_symbols = qammod(train_bit_seq', M, 'InputType', 'bit' ,'UnitAveragePower', true); 
train_sig_sent = train_symbols(randi([1 length(train_sym_ind)], N_train, 1)); 

%% 3.2.3
h = [1, 0, 0, 0.2*exp(1j*pi/6), 0, 0, 0.1*exp(-1j*pi/5), 0, 0, 0.05*exp(1j*pi/4)].'; 
SNR = 25 ;
train_sig_rec = awgn(filter(h, 1, train_sig_sent), SNR);

scatterplot(train_sig_rec);

%% 3.2.4
N_test = 8000; 
test_bit_seq = randi([0,1], N_test*log2(M), 1); 
test_sig_sent = qammod(test_bit_seq, M, 'InputType', 'bit', 'UnitAveragePower', true); 

%% 3.2.5
test_sig_rec = awgn(filter(h, 1, test_sig_sent), SNR); 

scatterplot(test_sig_rec);


%% 3.2.6

EVM_test = 20*log10(1/length(test_sig_rec)*sum(abs(test_sig_rec - test_sig_sent)));

test_bit_demod = qamdemod(test_sig_rec, M, 'OutputType', 'bit', 'UnitAveragePower', true); 
BER_test = sum(abs(test_bit_demod - test_bit_seq))/length(test_bit_seq); 

%% 3.3.1 Korekcja charakterystyki kanału za pomocą algorytmu LMS

figure(8)
plot(train_sig_rec,'.')
hold on
plot(train_sig_sent,'.')
hold off
legend('odebrana','wysłana')

L = 10;
alpha = 0.005;

x = train_sig_rec;
d = train_sig_sent;

[e, y, ff] = lms1(x, d, L, alpha);

figure(9)
plot(abs(e))
title('błąd')

figure(10)
plot(abs(ff'))
title('współczynniki filtru')
%% 3.3.2 Obserwacje
% System się adaptuje. Błąd maleje, wartości współczynników się ustalają. 
%% 3.3.3
h = ff(:,end);
test_sig_filtered = filter(h,1,test_sig_rec);

figure(11)
plot(test_sig_rec,'.')
hold on
plot(test_sig_filtered,'.')
plot(test_sig_sent,'.')
hold off
legend('odebrana','przefitrowana','wysłana')
title('sekwencje testowe')

EVM_filtered = 20*log10(1/length(test_sig_filtered)*sum(abs(test_sig_filtered - test_sig_sent)));

test_bit_demod = qamdemod(test_sig_filtered, M, 'OutputType', 'bit', 'UnitAveragePower', true); 
BER_fitered = sum(abs(test_bit_demod - test_bit_seq))/length(test_bit_seq); 
%% Wnioski
% EVM_test = -13.32 EVM_filtered = -25.55
%
% BER_test = 0.11 BER_fitered = 8.33e-5
%
% Metryki znacznie zmalały, a pozycje znaków z sekwencji przefiltrowanej są znacznie bliższe pozycjom sekwencji wysłanej.
%% 3.4 Korekcja charakterystyki kanału dla różnych wartości SNR
SNR = [35; 30; 20; 15;];
%% 35 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3(35);
BER_test_all = [BER_test];
BER_filtered_all = [BER_fitered];
EVM_test_all = [EVM_test];
EVM_filtered_all = [EVM_filtered];
%% 30 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3(30);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% 20 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3(20);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% 15 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3(15);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% Porównanie
LMS = table(SNR, BER_test_all, BER_filtered_all, EVM_test_all, EVM_filtered_all)
%% Wnioski
% W każdym przypadku udało się poprawić metryki. BER malał o rząd wielkości
% lub nawet do 0. EVM malało do około wartości SNR.
% Jeżeli chodzi o dane na wykresach przy SNR = 20 lub mniej wygląda na to,
% że mogą się pojawić problem z odszyfrowaniem symboli nawet po filtracji.
% Jakość jest trochę lepsze po filtracji, ale możliwe, że nie
% wystarczająco.
%% 3.5 Korekcja charakterystyki kanału za pomocą algorytmu RLS
SNR = [35; 30; 25; 20; 15;];
%% 35 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3_rls(35);
BER_test_all = [BER_test];
BER_filtered_all = [BER_fitered];
EVM_test_all = [EVM_test];
EVM_filtered_all = [EVM_filtered];
%% 30 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3_rls(30);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% 25 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3_rls(25);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% 20 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3_rls(20);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% 15 dB
[BER_test, BER_fitered, EVM_test, EVM_filtered] = task3_2and3_3_rls(15);
BER_test_all = [BER_test_all; BER_test;];
BER_filtered_all = [BER_filtered_all; BER_fitered;];
EVM_test_all = [EVM_test_all; EVM_test;];
EVM_filtered_all = [EVM_filtered_all; EVM_filtered;];
%% Porównanie
RLS = table(SNR, BER_test_all, BER_filtered_all, EVM_test_all, EVM_filtered_all)
LMS
%% Wsnioski
% Algorytm LMS ma trochę mniejsze wartości BER i EVM. Najbardziej widać
% różnicę dla SNR = 20 dB. LMS pozwala jeszcze w miarę dobrze rozróżnić
% grupy odpowiadające odpowiednim znakom. Algorytm RLS radzi sobie trochę
% gorzej przy 20 dB i symbole mogą być nie rozróżnialne.
% Warto tu zauważyć, że algorytm RLS szybciej się adaptuje niż LMS,
% jednakże jak pokazane wyżej daje gorszy wynik ostatecznie. Być może nie
% dobrałem optymalnych parametrów algorytmu. Jest to zadanie dodatkowe i
% nie jest celem laboratorium poszukiwanie optymalnych parametrów, więc nie
% badałem dalej zagadnienia.