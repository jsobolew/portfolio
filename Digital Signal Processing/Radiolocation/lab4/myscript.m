%% pierwsze scenariusz - skladowa stala
clear all;
close all;

x = 1000;       % sk³adowa sta³a
N = 500;        % dyskretny czas pomiaru
std_r = 10;     % szum pomiaru
std_u = 0;      % szum procesu
F = 1;          % macie¿ przejscia
H = 1;          % macie¿ czegoœ
R = std_r^2;
Q = std_u^2;
z = H*x + std_r*randn(1);

%inicjalizacja
x_est = z;
P = R;

for k=2:N
    %symulacja
     x(:,k) = F*x(:,k-1) + std_u*randn(1);
     z(:,k) = H*x(:,k) + std_r * randn(1);
     
     %estymacja
     [x_est(:,k),P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

n = 1:N;
figure(1)
plot(n,x_est(1,:),n,x(1,:),n,z(1,:),'.')
e = x - x_est;

P11 = sqrt(P(1,1,:));
P11 = P11(:); %matlab tak musi

figure(2)
plot(n,e(1,:),n,3*P11,'r--',n,-3*P11)

%% drugi scenariusz - ruch prostoliniowy
clear all;
close all;

T = 5;          % czas w [s]

N = 500;        % dyskretny czas pomiaru

std_r = 30;     % szum pomiaru
std_v = 10;     % odchylenie prêdkoœci
std_u = 0;      % szum procesu

F = [1 T;
     0 1];      % macie¿ przejscia
 
H = [1, 0];      % macie¿ 
R = std_r^2;

Q = [T;1]*[T;1]'*std_u^2;

x = [1000; std_v*randn(1)];
z = H*x + std_r*randn(1);

%inicjalizacja
x_est = [z; 0];
P = diag([std_r^2 std_v^2]);

for k=2:N
    %symulacja
     x(:,k) = F*x(:,k-1) + std_u*randn(1)*[T;1];
     z(:,k) = H*x(:,k) + std_r * randn(1);
     
     %estymacja
     [x_est(:,k), P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

n = 1:N;
figure(1)
plot(n,x_est(1,:),n,x(1,:),n,z(1,:),'.')
e = x - x_est;

P11 = sqrt(P(1,1,:)); % prêdkoœæ
P11 = P11(:); %matlab tak musi

P22 = sqrt(P(2,2,:)); % p³o¿enie
P22 = P22(:); %matlab tak musi

figure(2)
plot(n,e(1,:),n,3*P11,'r--',n,-3*P11)

figure(3)
plot(n,e(2,:),n,3*P22,'r--',n,-3*P22)

%% trzeci scenariusz - 2D
clear all;
close all;

T = 5;          % czas w [s]
N = 500;

std_x = 30;
std_y = 300;
std_u = 0.1;      % szum procesu
std_v = 10;     % odchylenie prêdkoœci

Fp = [1 T;
     0 1]; 
 
F = blkdiag(Fp , Fp);

H = [1 0 0 0;
    0 0 1 0];

R = diag([std_x^2 std_y^2]);

Qp = std_u^2*[T;1]*[T;1]';
Q = blkdiag(Qp, Qp);

x = [1000; std_v*randn(1); 1000; randn(1)*std_v];

z = H*x + [std_x*randn(1); std_y*randn(1)];
x_est = [z(1); 0; z(2); 0];
P = diag([std_x^2 std_v^2 std_y^2 std_v^2]);

for k=2:N
    %symulacja
     x(:,k) = F*x(:,k-1) + std_u*[randn(1)*[T;1]; randn(1)*[T;1]];
     z(:,k) = H*x(:,k) + [std_x * randn(1);std_y * randn(1)];
     
     %estymacja
     [x_est(:,k), P(:,:,k)] = kalman_filter(x_est(:,k-1),P(:,:,k-1),z(:,k),F,H,R,Q);
end

n = 1:N;
figure(1)
plot(n,x_est(1,:),n,x(1,:),n,z(1,:),'.')
e = x - x_est;

P11 = sqrt(P(1,1,:)); % prêdkoœæ
P11 = P11(:); %matlab tak musi

P22 = sqrt(P(2,2,:)); % p³o¿enie
P22 = P22(:); %matlab tak musi

P33 = sqrt(P(1,1,:)); % prêdkoœæ
P33 = P33(:); %matlab tak musi

P44 = sqrt(P(2,2,:)); % p³o¿enie
P44 = P44(:); %matlab tak musi

figure(2)
plot(n,e(1,:),n,3*P11,'r--',n,-3*P11)

figure(3)
plot(n,e(2,:),n,3*P22,'r--',n,-3*P22)

figure(4)
plot(n,e(1,:),n,3*P33,'r--',n,-3*P33)

figure(5)
plot(n,e(2,:),n,3*P44,'r--',n,-3*P44)