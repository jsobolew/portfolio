function [noise_est, det_vect] = os_cfar(x, N_ref, N_guard, T)
%CA_CFAR Summary of this function goes here

    noise_est = zeros(size(x));
    det_vect = zeros(size(x));
    
    for n = N_guard+N_ref+1:length(x)-N_guard-N_ref
        xl = (x(n-N_guard-N_ref:n-N_guard-1));
        xr = (x(n+N_guard+1:n+N_guard+N_ref));
        xlr = [xl xr];
        xlr_sort = sort(xlr);
        noise_est(n)=xlr_sort(round(end/2));
        if x(n) > noise_est(n)*T
            det_vect(n) = 1;
        end
    end

end

