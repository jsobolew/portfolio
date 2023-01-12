function [noise_est, det_vect] = goca_cfar(x, N_ref, N_guard, T)
%CA_CFAR Summary of this function goes here

    noise_est = zeros(size(x));
    det_vect = zeros(size(x));
    
    for n = N_guard+N_ref+1:length(x)-N_guard-N_ref
        xl = mean(x(n-N_guard-N_ref:n-N_guard-1));
        xr = mean(x(n+N_guard+1:n+N_guard+N_ref));
        noise_est(n) = max(xl,xr);
        if x(n) > noise_est(n)*T
            det_vect(n) = 1;
        end
    end

end

