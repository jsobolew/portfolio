function [MSE_e, MSE_f, Mean_f] = rls1_step_loop(K, N, h1, h2, step_index, sigma_d, lambda, gamma)
    L = length(h1);

    ee = zeros(K,N);
    fff = zeros(L,N,K);

    MSE_e = zeros(1,N);
    MSE_f = zeros(L,N);
    Mean_f = zeros(L,N);

    for k = 1:K
        x = randn(1, N);
        d = step_filter(h1, h2, step_index, x) + sigma_d*randn(1,N);
        [e,  y,  ff] = rls1(x,  d,  L, lambda, gamma);
        ee(k,:) = e;
        fff(:,:,k) = ff;
    end

    MSE_e = sum(ee.^2)/K;

    hhh = repmat(h1,[1,N,K]);
    Mean_f = mean(fff,3);
    MSE_f = sum((fff-hhh(:,1:500,:)).^2,3)/K;
    
end