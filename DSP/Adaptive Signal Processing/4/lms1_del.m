function [e, y] = lms1_del(d, L, alpha, delta)

N = length(d);

x = [zeros(delta, 1); d'];       % delay

f_n = zeros(L,1);
x_n = zeros(L,1);

y = zeros(N,1);                   
e = zeros(N,1);                   

for n = 1:N
    
    x_n = [x(n); x_n(1:end-1,1)];
        
    y(n) = f_n' * x_n;
    e(n) = d(n)-y(n);
    f_n = f_n + alpha*e(n)*x_n;
    
end   