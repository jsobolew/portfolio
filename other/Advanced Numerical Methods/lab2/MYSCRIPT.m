clear all, close all;
b = @(x)10*sin(x) + cos(10*x);
fun = @(t) 5*sin(0.1*t)+cos(100*t)+3;
a = TwoComponentSignal('formula',fun);

%%
a.xlimits = [1,110]
%%
a.rectLimitsUserInput = [60 0 70 8]
%%
a.displayRect = 1
%%
a.displayFormula = 1