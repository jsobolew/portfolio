function [R]=Delta_r(x, V, beam)
    %beam = pi/10;

%     x = 100;
%     V = 100;

    timestep = 1/2000;



    angle_to_radar = 0;
    i = 0;

    while angle_to_radar < beam

        y = V*timestep*i;
        i = i + 1;
        angle_to_radar = atan(y/x);
        R(i) = sqrt(x^2 + y^2);
    end

    R = [fliplr(R) R(2:end)];
    %plot(R)
end