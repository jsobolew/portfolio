function [MSE_e, MSE_f, Mean_f] = lms1_step_loop(K, M, h1, h2, step_index, sigma_d, alpha)

    L = length(h1);

    ee = zeros(K,M);
    fff = zeros(L,M,K);

    MSE_e = zeros(1,M);
    MSE_f = zeros(L,M);
    Mean_f = zeros(L,M);

    for k = 1:K
        x = randn(1,M);
        d = step_filter(h1, h2, step_index, x) + sigma_d*randn(1,M);
        [e, ~, ff] = lms1(x, d, L, alpha); % [e, y, ff] = lms1(x, d, L, alpha);
        ee(k,:) = e;
        fff(:,:,k) = ff;
    end

    MSE_e = sum(ee.^2)/K;
    
    hhh = repmat(h1,[1,M,K]);
    Mean_f = mean(fff,3);
    MSE_f = sum((fff-hhh(:,1:500,:)).^2,3)/K;

end