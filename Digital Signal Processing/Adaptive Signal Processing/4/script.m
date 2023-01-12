%% 3.1 Usuwanie zakłóceń pochodzących od sieci energetycznej z sygnału EKG
% Jakub Sobolewski 300371
%% 3.1.1
close all
clear all

load ecg; 
N = length(s); 
f_s = 1e3; 
x1 = sin(2*pi*(1:N)*50/f_s + pi/6); 
x2 = cos(2*pi*(1:N)*50/f_s + pi/6); 
d= s;
alpha = [0.1 0.5 0.9 1];


for i = 1:length(alpha)
[e, y, ff] = lms_ecg(x1, x2, d, alpha(i)); 

figure(1)
plot(e.^2)
hold on
title('kwadrat błedu')
end
legend(string(alpha))
hold on
%% 3.1.2
close all

v_0 = 0.3*cos(2*pi*(1:N)*50/f_s + 0.75*pi); 
d = s + v_0;


for i = 1:length(alpha)
[e, y, ff] = lms_ecg(x1, x2, d, alpha(i)); 

figure(2)
plot(e.^2)
hold on
title('kwadrat błedu')
end
legend(string(alpha))
hold on
%% Wnioski
% algorytm szybko dostosowywuje się do sygnału
%% 3.1.3
close all

alpha = [0.01 0.1 0.5 1];

for i = 1:length(alpha)
    [e, y, ff] = lms_ecg(x1, x2, d, alpha(i)); 
    
    figure(1)
    plot(e.^2)
    hold on
    title('kwadrat błedu')
    
    delta(i) = sum((e(4000:end) - s(4000:end)).^2)/sum(s(4000:end).^2);
end
legend(string(alpha))
hold off

%% Wnioski
% Dla mniejszej wartości alpha algorytm dłużej dostosowywuje się do
% sygnału, ale błąd potem jest mniejszy, jest lepsze dopasowanie.
%
% Poniższa tabela przedstawia błąd.
%
% <html>
% <table border=1>
% <tr><td>alpha</td><td>0.01</td><td>0.1</td><td>0.5</td><td>1</td></tr>
% <tr><td>delta</td><td>0.0009</td><td>0.024</td><td>0.347</td><td>1.0</td></tr>
% </table>
% </html>
% 
%% 3.1.4
close all

alpha = [0.01 0.1];
m = [0.1 0.3];

for i = 1:length(alpha)
    for j = 1:length(m)
        v_0 = 0.3*(1 + m(j)*cos(2*pi*(1:N)*1/f_s)).*cos(2*pi*(1:N)*50/f_s); 
        d = s + v_0;

        [e, y, ff] = lms_ecg(x1, x2, d, alpha(i)); 
        
        figure(1)
        plot(e.^2)
        hold on
        title('kwadrat błedu')
        
        delta(i,j) = sum((e(4000:end) - s(4000:end)).^2)/sum(s(4000:end).^2);
    end
end
legend('alpha = 0.01, m = 0.1','alpha = 0.01, m = 0.3','alpha = 0.1, m = 0.1','alpha = 0.1, m = 0.3')

%% Wnioski
% Dla mniejszych wartości alpha i mniejszych wartości współczynnika
% modulacji błąd jest mniejszy.
%
% Poniższa tabela przedstawia błąd.
%
% <html>
% <table border=1>
% <tr><td>alpha / m</td><td>0.1</td><td>0.3</td></tr>
% <tr><td>0.01</td><td>0.0104</td><td>0.0868</td></tr>
% <tr><td>0.1</td><td>0.0249</td><td>0.0268</td></tr>
% </table>
% </html>
% 

%% 3.2.1 Usuwanie zakłóceń w sygnale akustycznym za pomocą systemu adaptacyjnego bez zewnętrznego sygnału odniesienia 
clear all
close all

[s, f_s] = audioread('Chopin_op9_no2.wav'); 
% sound(s, f_s);

[R_s(:, 1), lags] = xcorr(s(:, 1), s(:, 1)); 
figure(1)
plot(lags, 20*log10(R_s(:, 1))); 

[R_s(:, 2), lags] = xcorr(s(:, 1), s(:, 1)); 
figure(2)
plot(lags, 20*log10(R_s(:, 1))); 

spect_win = chebwin(4096); 
figure(3)
spectrogram(s(:, 1), spect_win, length(spect_win)/2, length(spect_win), f_s); 
xlim([0, 10]); 

%% Obserwacje i Wnioski
% Funkcja Autokorelacji wygląda podobnie dla obu kanałów. Środek jest w
% miarę szeroki co wskazuje na to że sygnał w miarę dobrze koreluje się sam
% ze sobą. Prawodopodobnie wynika to z tego, że dźwięki są w miarę podobne
% do siebie w czasie i barwa instrumentu się nie zmienia.
%
% Na spektrogramie widać wyraźnie grane dźwięki i ich wyższe harmoniczne.

%% 3.2.2
close all

N = size(s,1); 
A_0 = 0.1; f_v = 500; 
v_0 = A_0*sin(2*pi*(f_v/f_s)*(1:N))'; 
d = s + v_0; 
% sound(d, f_s);

figure(1)
plot(s(:,1))
hold on
plot(d(:,1))
xlim([620000,625000])

figure(2)
plot(s(:,2))
hold on
plot(d(:,2))
xlim([620000,625000])

figure(3)
plot(v_0)
xlim([620000,625000])

figure(4)
spectrogram(d(:, 1), spect_win, length(spect_win)/2, length(spect_win), f_s); 
xlim([0, 10]); 

figure(5)
spectrogram(d(:, 2), spect_win, length(spect_win)/2, length(spect_win), f_s); 
xlim([0, 10]); 
%% Obserwacje i Wnioski
% Zakłócenie jest wyraźnie widoczne na spektrogramie.
%% 3.2.3
close all
delta = [1, 10, 100, 1000, 10000];
L = 500;
alpha = 2e-4;


for i = 1:length(delta)
    [e, y] = lms1_del(d(1:end-delta(i)), L, alpha, delta(i)); 

    figure(10*i+1)
    plot(s(:,1))
    hold on
    plot(e(:,1))
    hold off
    xlim([620000,625000])
    title(strcat("delta: ", num2str(delta(i))))


    [R_e, lags] = xcorr(e, e); 
    figure(10*i+2)
    plot(lags, 20*log10(R_e)); 
    title(strcat("delta: ", num2str(delta(i))))

    figure(10*i+3)
    spectrogram(e(:, 1), spect_win, length(spect_win)/2, length(spect_win), f_s); 
    xlim([0, 10]); 
    title(strcat("delta: ", num2str(delta(i))))
end
%% Obserwacje i Wnioski
% 1: na poczatku słychać zniekształcenie i momentami  też się lekko
% przebija, nie wiem czy slusznie ale momentami barzmienie przypoomina sygnał jak po przejściu przez filt HP.
%
% 2: na poczatku słychać zakłócenie.Potem przebitki troche mniej, efekt HP
% filtra.
%
% 3: tak samo praktycznie jak 2
%
% 4: na poczatku szybciej tłumione, słychać przebitki przy dźwiękach o
% podobnej częstotliwości, jakby lekkie echo. W momentach gdy dźwięki są blisko f = 500 Hz, efekt echa, oraz jakby dźwięki były lekko nie w fazie.
%
% 5: efekt echa trochę zmiejszony, ale dalej wyczuwalny, łagodniej słychać
% zakłócenie
%
% Na spektrogamie 500 Hz nie jest widoczne, ale widać relatywnie
% zmiejszenie mocy dla niższych częstotliwości. (podobnie do filtru HP)
%
% Na wykresach również widać, że dla niskich częstotliwości amplituda jest
% mniejsza.
%
% Dla jakich wartości opóźnienia ∆ filtr usuwa zakłócenie w sposób najbardziej satysfakcjonujący?
% Z jdenej strony dla opóźnienia 1 już jest całkiem nieźle, ale żadne
% ustawienie nie jest jakoś super satysfakcjonujące. Osobiście wybrałbym
% opóźnienie 100, ponieważ efekt filtru HP jest najmniejszy i nie ma
% dziwnego opóźnienia fazy. (Tą faze to tak ze słychu da się wyczuć nie mam naukowego potwierdzenia.)
%% Zadania dodatkowe
%% 450 Hz -> 550 Hz
f_v_min = 450; f_v_max = 550; 
v_0 = A_0*chirp((1:N)/f_s, f_v_min, N/f_s, f_v_max)'; 
d = s + v_0; 

for i = 1:length(delta)
    [e, y] = lms1_del(d(1:end-delta(i)), L, alpha, delta(i)); 

    figure(10*i+1)
    plot(s(:,1))
    hold on
    plot(e(:,1))
    hold off
    xlim([620000,625000])
    title(strcat("delta: ", num2str(delta(i))))

    [R_e, lags] = xcorr(e, e); 
    figure(10*i+2)
    plot(lags, 20*log10(R_e)); 
    title(strcat("delta: ", num2str(delta(i))))


    figure(10*i+3)
    spectrogram(e(:, 1), spect_win, length(spect_win)/2, length(spect_win), f_s); 
    xlim([0, 10]); 
    title(strcat("delta: ", num2str(delta(i))))
end
%% Obserwacje i Wnioski
% Dla 2 największych opóźnień "chirp" widoczny na spektrogramie. Sygnał
% zakłócający jest również mniej słyszalny dla opóźnień 1-3 oraz dobrze
% słyszalny dla 2 największych opóźnień. Podsumowując: wnioski na podstawie słuchu i
% spektrogramu identyczne.




%% 250 Hz -> 750 Hz
f_v_min = 250; f_v_max = 750; 
v_0 = A_0*chirp((1:N)/f_s, f_v_min, N/f_s, f_v_max)'; 


for i = 1:length(delta)
    [e, y] = lms1_del(d(1:end-delta(i)), L, alpha, delta(i)); 

    figure(10*i+1)
    plot(s(:,1))
    hold on
    plot(e(:,1))
    hold off
    xlim([620000,625000])
    title(strcat("delta: ", num2str(delta(i))))

    [R_e, lags] = xcorr(e, e); 
    figure(10*i+2)
    plot(lags, 20*log10(R_e)); 
    title(strcat("delta: ", num2str(delta(i))))


    figure(10*i+3)
    spectrogram(e(:, 1), spect_win, length(spect_win)/2, length(spect_win), f_s); 
    xlim([0, 10]); 
    title(strcat("delta: ", num2str(delta(i))))
end
%% Obserwacje i Wnioski
% Wnioski podobne do poprzedniego podpunktu. Różnica jest w tym, że dla 2
% największego opóźnienia zakłócenie bardziej widoczne.
%
% Zakłócenie można również zauważyć na wykresie funkci autokorelacji. Z grubsza można powiedzieć, że im
% wyższe piki odpowiadające zakłóceniu na funkcji autokorelacji, tym
% zakłócenie zostało gorzej usunięte.
