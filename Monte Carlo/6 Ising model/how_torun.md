./a.out 10 -184 1000


macro
g++ ising_macro.cpp model_isinga_macro.h model_isinga_macro.cpp -o a_macro.out `gsl-config --cflags --libs`