RT = a.RT;

figure(1)
imagesc(db(abs(RD)))
title('original RD')

%RCMC
azim_freq = linspace(-1000, 1000, length(RD));
lamb = 0.06;
fc = 5e9;
closest_approach =[93 99 105];
V = 100;

value = zeros(length(closest_approach),length(RD));

% MY VERSION
for j = 1:length(closest_approach)
    delta = lamb^2*closest_approach(j)*azim_freq.^2/8/V^2;
    for i = 1:length(RD)
        weight = mod(delta(i),1);
        value(i,j) =  (1-weight)*real(RD(i,(closest_approach(j)/1.5+floor(delta(i)))))+(weight)*real(RD(i,(closest_approach(j)/1.5+ceil(delta(i))))) +...
                    (1-weight)*imag(RD(i,(closest_approach(j)/1.5+floor(delta(i)))))+(weight)*imag(RD(i,(closest_approach(j)/1.5+ceil(delta(i)))));
    end
end

% new RT
RD_synthetit = zeros(size(RD));

for i = 1:length(closest_approach)
    RD_synthetit(:,(closest_approach(i)/1.5)) = value(:,i)';
end

figure(3)
imagesc(abs(RD_synthetit))
title('RD synthetit')
% new RT
RT_synth = zeros(size(RD_synthetit));
for i = 1 : size(RD_synthetit,2)
    RT_synth(:,i) = ifft(fftshift(RD_synthetit(:,i)));
end
figure(4)
imagesc(db(abs(RT_synth)))
title('RT synth')

% matched filter
RT_filtered = zeros(size(RT_synth));
prev_length = 1;
for i = 1 : size(RT_synth,2)
    phase = 4*pi/lamb*(Delta_r(1.5*i,100,pi/10));
    h = conj(fliplr(exp(1j.*phase)));
    RT_filtered(:,i) = circshift(filter(h,1,RT_synth(:,i)),round(-length(h)/2));
    prev_length = length(h);
end
figure(5)
imagesc((abs(RT_filtered)))
title('RT filtered')
colormap;

figure(6)
plot(db(abs(RT_filtered(:,66))));
title('RT cut after compression')