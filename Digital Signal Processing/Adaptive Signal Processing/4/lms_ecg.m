function [e, y, ff] = lms_ecg(x1, x2, d, alpha)

    N = length(d);

    f_n=zeros(2,1);

    ff = zeros(2,N);                

    y = zeros(1,N);                   
    e = zeros(1,N);                   

    for n = 1:N

        x_n = [x1(n); x2(n)];

        y(n) = f_n'*x_n;
        e(n) = d(n)-y(n);
        f_n = f_n + alpha*e(n)*x_n;

        ff(:,n) = f_n;
    end

end