function d = step_filter(h1, h2, step_index, x) 
    d1 = filter(h1,1,x);
    d2 = filter(h2,1,x);
    d = [d1(1:step_index-1), d2(step_index:end)];
end