noise.ON = 0;
noise.SNR = 1;   % in dB

% Copy_of_FMCW(distance_from_radar, radial_speed, noise)


%a = Copy_of_FMCW([100  135 80 70], [5 -5 29 0], noise); %FMCW(Range [m], Velocity [m/s])
%a = Copy_of_FMCW(x, v, noise);
a = Copy_of_FMCW(distance_from_radar, radial_speed, noise);


a.generateRT(4000); % a.generateRT(pulses)

Copy_of_FMCW.plotRT(a.RT, a.Settings, a.Parameters);

VelocityOrNotDopplerFrequency = true;   %true => velocity   false => doppler freq
RD = Copy_of_FMCW.plotRD(a.RT, a.Settings, a.Parameters, VelocityOrNotDopplerFrequency);


