function x = mychirp(r,r0,B,Timp)
%MYCHIRP Summary of this function goes here
%   Detailed explanation goes here
    c = 3e8;

    %r = c*t/2;
    
    t = 2*(r-r0)/c;

    x = exp(1j*pi.*B./Timp.*t.^2).*rectpuls(t/Timp);

end

