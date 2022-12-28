%% Filtr Kalmana
% Oliwia Makowiecka
% Jakub Sobolewski

%% Symulacja zaszumionej trajektorii
clear all;
close all;

% proces
t = -1:0.1:1;
r0_trg = [100 0 0]';
v_trg = [0 25 0]';
r_trg = r0_trg + v_trg.*t;

std = 0.05;
radial_distane = sqrt(sum(r_trg.^2));
radial_distane_noisy = radial_distane + std*randn(size(r_trg(1,:)));

% radial distance
figure(1)
plot(t,radial_distane,t,radial_distane_noisy);
xlabel('time [s]')
ylabel('distance [m]')
legend('real','noisy')

% radial velocity
radial_velocity = diff(radial_distane);
radial_velocity_noisy = diff(radial_distane_noisy);
figure(2)
plot(t(1:end-1),radial_velocity,t(1:end-1),radial_velocity_noisy,'o')
xlabel('time [s]')
ylabel('velocity a*[m/s]')
legend('real','noisy')

% radial acceleration
radial_acceleration = diff(radial_velocity);
radial_acceleration_noisy = diff(radial_velocity_noisy);
figure(3)
plot(t(1:end-2),radial_acceleration,t(1:end-2),radial_acceleration_noisy,'o')
xlabel('time [s]')
ylabel('acceleration b*[m/s2]')
legend('real','noisy')
%% informacje  o symulacji
% Symulowany jest obiekt poruszający się prostopadle do radaru na
% odległośći 100 [m] poruszający się z prędkością liniową 25 [m/s]
% pomiar przyśpieszenia jest najbardziej zaszumiony
%% Symulcaja kalman r,v,a
clear z;
T = 1;       % czas próbkowanie [s]

F = [1 T T^2/2;
     0 1 T;
     0 0 1];          % macież przejscia

std_u = 0;
Q = std_u^2;

std_r = 0.1;     % szum pomiaru
std_v = 0.1;     % szum pomiaru
std_a = 1;     % szum pomiaru

H = eye(3);          % macież układu pomiarowego
R = diag([std_r^2 std_v^2 std_a^2]);

% dane
data = [radial_distane_noisy(1:end-2); radial_velocity_noisy(1:end-1); radial_acceleration_noisy;];
realData = [radial_distane(1:end-2); radial_velocity(1:end-1); radial_acceleration;];
tAxis = t(1:end-2);


%inicjalizacja
x_est = data(:,1);
P = diag([std_r^2 std_v^2 std_a^2]);%diag([radial_distane_noisy(1) radial_velocity_noisy(1) radial_acceleration_noisy(1)]);

for k=2:length(data)
    %symulacja
%      x(:,k) = F*x(:,k-1) + std_u*randn(1); % proces
     z(:,k) = data(:,k); % pomiar
     
     %estymacja
     [x_est(:,k), P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

figure(11)
plot(tAxis, data(1,:),'.', tAxis, x_est(1,:), tAxis, realData(1,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('odległość [m]')

figure(12)
plot(tAxis, data(2,:),'.', tAxis, x_est(2,:), tAxis, realData(2,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('prędkość [m/s]')

figure(13)
plot(tAxis, data(3,:),'.', tAxis, x_est(3,:), tAxis, realData(3,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('przyśpieszenie [m/s]')

figure(14)
plot(tAxis,cumsum(x_est(2,:))-min(cumsum(x_est(2,:)))+100)
hold on
plot(tAxis,realData(1,:))
hold off
title('estymaty odległośći na podstawie prędkośći i porówanie z oryginanymi danymi')
legend('estymowane','oryginalne')
%% Wnioski
% Trajektoria dobrze się estymuje. Symulacje potwierdzają założenie
% projektowe. Wykorzystanie wiltru Kalmana pozwala wygładzić/odszumić
% pomiar trajektorii. Mimo, że poomiar jest dosyć rzadki, ponieważ co 0.1
% [s] to filtr jest w stanie szybko się dostosować.
%% dane rzeczywiste - 1 Metoda kalman pomiar: r, v, a
% Zsoatały przeprowadzone testy na danych rzeczywistych. Obiekt tak jak w symulacjach poroszał
% się prostopadle do radaru.
clear z;
load('trajectory_corelation.mat')
r = cumsum(max_row_cell{1});
v = max_row_cell{1};
a = max_col_cell{1};

T = 1;       % czas próbkowanie [s]

F = [1 T T^2/2;
     0 1 T;
     0 0 1];          % macież przejscia

std_u = 0;
Q = std_u^2;

std_r = 0.1;     % szum pomiaru
std_v = 0.1;     % szum pomiaru
std_a = 1;     % szum pomiaru

H = eye(3);          % macież układu pomiarowego
R = diag([std_r^2 std_v^2 std_a^2]);

% dane
data = [r'; v'; a';];
tAxis = time_cell{1};


%inicjalizacja
x_est = data(:,1);
P = diag([std_r^2 std_v^2 std_a^2]);%diag([radial_distane_noisy(1) radial_velocity_noisy(1) radial_acceleration_noisy(1)]);

for k=2:length(data)
    %symulacja
%      x(:,k) = F*x(:,k-1) + std_u*randn(1); % proces
     z(:,k) = data(:,k); % pomiar
     
     %estymacja
     [x_est(:,k), P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

figure(21)
plot(tAxis, data(1,:),'.', tAxis, x_est(1,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('odległość [m]')

figure(22)
plot(tAxis, data(2,:),'.', tAxis, x_est(2,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('prędkość [m/s]')

figure(23)
plot(tAxis, data(3,:),'.', tAxis, x_est(3,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('przyśpieszenie [m/s]')

figure(24)
plot(tAxis,cumsum(x_est(2,:))-min(cumsum(x_est(2,:)))+100)
hold on
plot(tAxis, x_est(1,:)+100-min(x_est(1,:)))
hold off
title('estymaty odległośći na podstawie prędkośći i porówanie z estymacją odległości')
legend('estymowane z prędkośći','estymowane z odległośći')
%% Wnioski
% Filtr działa bardzo dobrze. Szybko dopasowywuje się do danych i doobrze
% estymuje trajektorię. Estymacja Przyśpieszenie nie działa najlepiej, ale
% ona jest bardzo mocno zaszumiona sama w sobie oraz i tak jest do niczego
% nie potrzebna.
%% dane rzeczywiste - 2 Metoda kalman pomiar: r, v
% Zsoatały przeprowadzone testy na danych rzeczywistych. Obiekt tak jak w symulacjach poroszał
% się prostopadle do radaru.
clear z;
load('trajectory_tracks.mat')
r = r{1};
v = v{1};

T = 0.2;       % czas próbkowanie [s]

F = [1 T T^2/2;
     0 1 T;
     0 0 1];          % macież przejscia

std_u = 0;
Q = std_u^2;

std_r = 0.01;     % szum pomiaru
std_v = 0.01;     % szum pomiaru
std_a = 2;     % szum pomiaru

H = [1 0 0;
     0 1 0];          % macież układu pomiarowego
R = diag([std_r^2 std_v^2]);

% dane
data = [r; v;];
tAxis = t{1};


%inicjalizacja
x_est = [data(:,1); 0];
P = diag([std_r^2 std_v^2 std_a^2]);%diag([radial_distane_noisy(1) radial_velocity_noisy(1) radial_acceleration_noisy(1)]);

for k=2:length(data)
    %symulacja
%      x(:,k) = F*x(:,k-1) + std_u*randn(1); % proces
     z(:,k) = data(:,k); % pomiar
     
     %estymacja
     [x_est(:,k), P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

figure(31)
plot(tAxis, data(1,:),'.', tAxis, x_est(1,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('odległość [m]')

figure(32)
plot(tAxis, data(2,:),'.', tAxis, x_est(2,:))
legend('pomiar','estymacja','prawdziwe')
xlabel('czas [s]')
ylabel('prędkość [m/s]')

figure(34)
plot(tAxis,cumsum(x_est(2,:))/7-min(cumsum(x_est(2,:)))/7+100)
hold on
plot(tAxis, x_est(1,:)+100-min(x_est(1,:)))
hold off
title('estymaty odległośći na podstawie prędkośći i porówanie z estymacją odległości')
legend('estymowane z prędkośći','estymowane z odległośći')
%% Wnioski
% Tutaj wyszło trochę gorzej. Może to zależeć od danych. Może też parametry filtru nie są najlepsze. Dane w tej metodzie są bardziej zaszumione ale
% mają mniejszy błąd taki ogólny (tzn. średnia wartość jest bliższa rzeczywistości, ale wariancja jestt wieksza). 