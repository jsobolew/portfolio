#ifndef MODEL_ISINGA_H
#define MODEL_ISINGA_H

#include <gsl/gsl_rng.h>
#include <math.h>
/**
	@author Marek Niewinski <niewinski@linuxHP6715b>
*/

class model_isinga {
	
	public:
	  	model_isinga();
		model_isinga(int rozmiar,int energia);		
    	~model_isinga();
		void  doprowadzenie_do_stanu_rownowagi(int liczba_krokow);
		void  zliczanie_srednich(int liczba_krokow);
		float podaj_srednia_energie_duszka();
		float podaj_srednia_energie_ukladu();
		float podaj_srednia_magnetyzacje();
		float podaj_temperature();

	private:
		gsl_rng  *generatorek;
		int     **siatka;

		int L; // Rozmiar siatki
		int E; // Energia wewnetrzna ukladu
		int E_Start;
		int E_Duszka;
		int magnetyzacja;
		float Srednia_Energia_Ukladu, Srednia_E_Duszka, Srednia_Magnetyzacja, Temperatura;

		void ustaw_same_jedynki();
		int  Delta_E(int i, int j);
};

#endif
