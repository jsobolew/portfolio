function [MSE_e, MSE_f, Mean_f] = rls1_loop_modified(K, N, h, sigma_d, lambda, gamma)

    L = length(h);

    ee = zeros(K,N);
    fff = zeros(L,N,K);

    MSE_e = zeros(1,N);
    MSE_f = zeros(L,N);
    Mean_f = zeros(L,N);

    B = [1, 0.75, 0.5]; A = 1;

    for k = 1:K
        x = filter(B, A, randn(1,N)); 
        d = filter(h, 1, x) + sigma_d*randn(1, N);
        [e,  y,  ff] = rls1(x,  d,  L, lambda, gamma);
        ee(k,:) = e;
        fff(:,:,k) = ff;
    end

    MSE_e = sum(ee.^2)/K;

    hhh = repmat(h,[1,N,K]);
    Mean_f = mean(fff,3);
    MSE_f = sum((fff-hhh(:,1:500,:)).^2,3)/K;
    
end