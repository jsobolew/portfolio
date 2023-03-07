#include <iostream>
#include <cstdlib>
#include "model_isinga.h"

using namespace std;

int main(int argc, char *argv[]) {
	// założenia parametry wejściowe: wielkość_siatki, Energia, liczba_kroków
	// 								  argv[1]		   argv[2]	   argv[3]
	model_isinga *p1 = new model_isinga(atoi(argv[1]),atoi(argv[2]));
	p1->doprowadzenie_do_stanu_rownowagi(atoi(argv[3]));
	p1->zliczanie_srednich(atoi(argv[3]));
	if(argc > 1) // sanity check
   	{
    	int i;
		for(i = 0; i < argc; i++)
			cout << argv[i] << endl;
   	}

	cout << p1->podaj_temperature() << endl;
	cout << p1->podaj_srednia_magnetyzacje() << endl;
	
	delete p1;
	return 0;
}
