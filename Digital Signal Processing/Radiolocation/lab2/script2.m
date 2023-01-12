clear all;
close all;

N = 100;

fd = 0:10:5e3;

prf = [500 700];
pri = 1./prf;
%A = zeros(99,500);

for k = 1:length(fd)
    t=0;
    x = zeros(N,1);
    for n = 1:N
        pri_curr = pri(mod(n-1,length(pri))+1);
        t = t + pri_curr;
        x(n)=exp(1j*2*pi*fd(k)*t);
    end
    y = filter([1,-1],1,x);
    A(k) = sum(abs(y(2:end)).^2);
end

figure(1)
plot(fd,db(A));