function [x, P] = kalman_filter(x,P,z,F,H,R,Q)
%KALMAN_FILTER Summary of this function goes here
%   Detailed explanation goes here

    %predykcja
    x = F*x;
    P = F*P*F' + Q;
    
    %aktualizacja
    v = z - H*x;
    S = H*P*H' + R;
    K = P*H'*inv(S);
    x = x + K*v;
    I = eye(length(x));
    
    P = (I-K*H)*P;
    
    
    
end

