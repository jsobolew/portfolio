---
output:
  pdf_document: default
  html_document: default
---
# NLP - Projekt - Dokumentacja wstępna

Eryk Mroczko

Jakub Sobolewski

14.12.2022r. 

## Temat projektu:

**Wykrywanie wydźwięku (sentiment analysis) opinii o produktach**

Projekt polega na pobraniu opinii o produktach: proszki do prania kolorów, tabletki do zmywarki i kubki termiczne oraz 
zrealizowania modelu wykrywającego wydźwięk: pozytywny, neutralny, negatywny. 

## Cel projektu

Wykrywanie wydźwięku (ang. sentiment analysis) jest procesem polegającym na określaniu emocji i opinii wyrażonych w tekście. Ten proces jest szeroko stosowany w wielu dziedzinach. Przykładem takich dziedzin są np. marketing i reklama. Wykrywanie wydźwięku stosuje się tam po to aby pomóc firmom w zrozumieniu emocji i opinii wyrażanych przez ludzi na temat ich produktów lub usług, a także aby dowiedzieć się czy ludzie są zadowoleni z ich produktów oraz by zidentyfikować potencjalne problemy lub obszary do poprawy.


## Założenia techniczne 

Cały projekt zostanie wykonany w języku Python, używając najnowszej wersji biblioteki PyTorch. Pozwoli to na naukę tego 
narzędzia, używając wszystkich najnowszych rozwiązań w nim dostępnych. 
Wszystkie skrypty pomocnicze (do webscrapingu, obrobienia danych) również zostaną wykonane w języku Python. 

## Dane do trenowania i testowania modelu 

Dane do trenowania i testowania pochodzić będą z portalu ceneo.pl. Portal ten został wybrany ze względu na największą ilość 
dostępnych recenzji o różnych wydźwiękach. 

## Sposób rozwiązania zadania

### Pobranie danych i przygotowanie korpusu

Pierwszym krokiem będzie pobranie danych. Pobranie danych zostanie wykonane za pomocą 
techniki webscrapingu. Zostanie przygotowany skrypt, który zczytuje z plików HTML strony internetowej opinie wraz z oceną. 
Tak przygotowane dane z HTML zostaną następnie przetworzone w skrypcie tak, aby ułatwić dalsze przetwarzanie w docelowym 
programie - zostaną skonwertowane do tablicy obiektów JSON, którą łatwo wczytać w docelowym programie. 
Taki obiekt JSON zawiera dwa pola: 
- text - wartością jest po prostu dana recenzja,
- score - wydźwięk recenzji,  będą to jedynie: **-1**, **0**, **1** (negatywna, neutralna, pozytywna)

Opinie z portalu są oceniane oryginalnie w skali 1-5 razem z połowami wartości np. 2.5/5. Skrypt przetwarzające dane z HTMLa do JSON mapuje oceny w 
następujący sposób:

- oceny 1-2: **-1** (negatywna)

- oceny 2.5-3.5: **0** (neutralna)

- oceny 4-5: **1** (pozytywna)


Gotowe datasety (czyli korpus) są następnie przetwarzane przez docelowy program, w celu trenowania i testowania modelu. 

### Dalsze przetworzenie przygotowanego datasetu

Następnym krokiem będzie tokenizacja datasetu, czyli podział opinii na pojedyncze wyrazy. Do tokenizacji użyta zostanie biblioteka Spacy. W ramach dalszego przetwarzania mogą być również przeprowadzone np. usunięcie stopwords lub lematyzacja również zapewniona przez bibliotekę Spacy. W dalszym ciągu programu stworzony zostanie zbiór słownictwa (vocabulary) gotowy do użycia w modelu.

### Przyjęty model

Planujemy wykorzystać dwa modele. 

Pierwszy model to prosty model oparty na regresji liniowej. Będzie on złożony z dwóch warstw:

Warstwa Embedding jako EmbeddingBag z biblioteki PyTorch - dzięki skorzystaniu z technologii EmbeddingBag, wystarczy że składamy zdania w paczkę, zapisując tylko w którym miejscu dana sekwencja się zaczyna. Każde takie zdanie będzie reprezentowane przez wektor embedding, a nie pojedyncze słowa. 

Warstwa liniowa w celach klasyfikacji 



Drugim modelem będzie model będący dotrenowaniem przetrenowanego modelu BERT, który wykorzystuje bardziej zaawansowane mechanizmy takie jak enkodery i atencja.  BERT jest szczególnie skuteczny w zadaniach takich jak rozpoznawanie intencji i znaczenia tekstu, a także w zadaniach związanych z zrozumieniem języka naturalnego. Jest to jeden z najlepszych obecnie dostępnych modeli języka i ma szerokie zastosowanie w różnych dziedzinach, w tym w technologii, medycynie i marketingu.

## Założenia

Danymi treningowymi będą dane ściągnięte z Ceneo. 

Problem klasyfikacji semantycznej będzie rozwiązany dla języka polskiego.

## Opis eksperymentów

Eksperymenty:

- Sprawdzimy jak ilość danych treningowych wpływa na jakość modelu.

- Porównamy nasz model z jakimś gotowym modelem z internetu.

- Porównamy 2 zaproponowane modele pod względem potrzebnych zasobów treningowych oraz jakości predykcji.

