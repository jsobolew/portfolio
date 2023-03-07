#include "model_isinga.h"

model_isinga::model_isinga() {
	L =  10;
	E = -192;
	siatka = new int* [L];
	for (int i = 0; i < L; i++)
		siatka[i] = new int[L];
}

model_isinga::model_isinga(int rozmiar,int energia) {
	L = rozmiar;
	E = energia;
	siatka = new int* [L];
	for (int i = 0; i < L; i++)
		siatka[i] = new int[L];

	generatorek = gsl_rng_alloc(gsl_rng_default);
	gsl_rng_set(generatorek, 3987);
}	

model_isinga::~model_isinga() {
	if (siatka != NULL) {
        for (int i = 0; i < L; i++)
            delete[] siatka[i];
        delete[] siatka;
	}
	gsl_rng_free(generatorek);
}

void model_isinga::ustaw_same_jedynki() {
	for(int i = 0; i < L; i++)
		for(int j = 0;j < L; j++)
			siatka[i][j] = 1;
}

void model_isinga::doprowadzenie_do_stanu_rownowagi(int liczba_krokow) {
	int i, j, dE;
	magnetyzacja = L * L;
	E_Start  = -2 * L * L;
	E_Duszka = E - E_Start;
	ustaw_same_jedynki();

	for (int k = 0; k < liczba_krokow; k++) {
		i = (int)floor(gsl_rng_uniform(generatorek)*L);
		j = (int)floor(gsl_rng_uniform(generatorek)*L);
		dE = Delta_E(i, j);
		if (dE <= E_Duszka) {				
			E_Duszka -= dE;
			E_Start  += dE;
			siatka[i][j] = -siatka[i][j];
			magnetyzacja += 2*siatka[i][j];
		}
	}
}
// Oblicza roznice energii przy zmianie kierunku spinu 
// przy zalozeniu periodycznych warunkow brzegowych
int model_isinga::Delta_E(int i, int j) {
	int lewy, prawy, gorny, dolny;
	int E_pocz, E_konc;

	gorny = i-1;
	dolny = i+1;
	if (i == 0)   gorny = L-1;
	if (i == L-1) dolny = 0;
	
	prawy = j+1;
	lewy  = j-1;
	if (j == 0)   lewy  = L-1;
	if (j == L-1) prawy = 0;

	E_pocz = siatka[i][j] * ( siatka[i][lewy] + siatka[i][prawy] + siatka[gorny][j] + siatka[dolny][j] );
	E_konc = -E_pocz;

	return E_pocz - E_konc;
}

// Wyznacza srednia Energie Duszka, Energie ukladu, Magnetyzacje oraz Temperature
void model_isinga::zliczanie_srednich(int liczba_krokow) {
	int E_Duszka_Do_Sredniej = 0, i, j ,dE;
	int magnetyzacja_tot = 0;
	int E_tot = 0;
	int przed, po;
	
	// Petla liczby_krokow
	for (int l = 0; l < liczba_krokow; l++) {
		// Petla statystycznie po kazdym spinie
		for (int k = 0; k < L*L; k++) {
			i  = (int)floor(gsl_rng_uniform(generatorek)*L);
			j  = (int)floor(gsl_rng_uniform(generatorek)*L);
			dE = Delta_E(i,j);
			if (dE <= E_Duszka) {
				siatka[i][j ]= -siatka[i][j];
				E_Duszka -= dE;
				E_Start  += dE;
				magnetyzacja += 2*siatka[i][j];
			}
		}
		E_Duszka_Do_Sredniej += E_Duszka;
		E_tot += E_Start;
		magnetyzacja_tot += abs(magnetyzacja);
	}

	// Obliczanie srednich
	Srednia_Energia_Ukladu = E_tot / (float)liczba_krokow;
	Srednia_E_Duszka = (float)(E_Duszka_Do_Sredniej) / (float)liczba_krokow;
	Srednia_Magnetyzacja = magnetyzacja_tot / (float)liczba_krokow / ((float)L*(float)L);
	Temperatura = 4.0 / (log(1 + 4.0/Srednia_E_Duszka));
}

float model_isinga::podaj_srednia_energie_duszka() {
	return Srednia_E_Duszka;
}

float model_isinga::podaj_srednia_energie_ukladu() {
	return Srednia_Energia_Ukladu;
}

float model_isinga::podaj_srednia_magnetyzacje() {
	return Srednia_Magnetyzacja;
}

float model_isinga::podaj_temperature() {
	return Temperatura;
}

