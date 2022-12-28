RT = a.RT;%(1550:2450,:);

%my_RT = RT_gen(105,100);

%y = filter2(my_RT,conj(RT));
clear y;
tic
% two other objects
y64 = filter2(RT_gen(93,100),conj(RT));
y(:,64) = y64(:,64);
y70 = filter2(RT_gen(99,100),conj(RT));
y(:,70) = y70(:,70);
y67 = filter2(RT_gen(105,100),conj(RT));
y(:,67) = y67(:,67);
toc
imagesc(abs(y));