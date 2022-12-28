function [RT_filter] = RT_gen(x,V)
    T = 1/2000;
    %V = 100;
    closest_approach = x;
    B = 100e6;
    fs = 10e7;
    t = 0:1/fs:T-1/fs;
    c=3e8;
    beam = pi/10;
    
    R = Delta_r(x,V,beam);
    
    azim_freq = linspace(-1000, 1000, length(R));
    lamb = 0.06;
    fc = 5e9;

    delta = lamb^2*closest_approach*azim_freq.^2/8/V^2;
    Velocity = diff(delta);
    Velocity(end+1) = Velocity(end);
    


    for i = 1: length(R)
        td = 2*(R(i))/c;
        my_RT(i,:) = fliplr(fft(exp(1j.*(2*pi*fc*td - (pi*B*(2*t*td + td^2)/T) + 2*fc*Velocity(i)*t/c))));
    end

    RT_filter = my_RT(:,floor(x/1.5):ceil(max(R/1.5)));

    %imagesc(db(abs(RT_filter)));
end