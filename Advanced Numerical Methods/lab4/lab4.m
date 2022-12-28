clc;
clear all, close all;
data = load('dane.mat');

% preallocation
yResults = {data.y0, data.y1, data.y2, data.y3, data.y4, data.y5, data.y6, data.y7};
fitResults = cell(8,1);
gof = cell(8,1);
amplitude = zeros(8,1);
SSE = zeros(8,1);
rSquare = zeros(8,1);
signalNumber = linspace(0,7,8);

% creating fit
% figure(1);
% hold on;
for i = 1:length(yResults)
    %subplot(2,4,i)
    [fitResults{i}, gof{i}] = createFit(data.w, yResults{i});
    amplitude(i)=fitResults{i}.a1;
    SSE(i) = gof{i}.sse;
    rSquare(i) = gof{i}.rsquare;
end
%hold off;
%% visualising errors
values = {amplitude, SSE, rSquare};
fieldnames = {'amplitude', 'SSE', 'rSquare'};
figure(2);
for i = 1:length(values)
   subplot(1,3,i)
   plot(signalNumber , values{i})
   title(fieldnames(i))
   xlabel('Numer badanego sygna³u');
   ylabel(fieldnames(i))
   grid minor; 
end