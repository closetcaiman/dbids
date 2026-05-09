# Indeksy, optymalizator <br>Lab 2

<!-- <style scoped>
 p,li {
    font-size: 12pt;
  }
</style>  -->

<!-- <style scoped>
 pre {
    font-size: 8pt;
  }
</style>  -->

---

**Imiona i nazwiska:** Marek Małek, Mateusz Lampert

---

Celem ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans), oraz z budową i możliwością wykorzystaniem indeksów
(kontynuacja poprzedniego ćwiczenia)

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---

> Wyniki:

```sql
--  ...
```

---

Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki, (dołącz kod rozwiązania w formie tekstowej/źródłowej)

Zwróć uwagę na formatowanie kodu

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie

- MS SQL Server
- SSMS - SQL Server Management Studio
  - ewentualnie inne narzędzie umożliwiające komunikację z MS SQL Server i analizę planów zapytań

Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej

## Przygotowanie

Uruchom Microsoft SQL Managment Studio.

Stwórz swoją bazę danych o nazwie lab2.

```sql
create database lab2
go

use lab2
go
```

Warto przełączyć bazę w tryb simple

```sql
alter database lab2
set recovery simple;
```

<div style="page-break-after: always;"></div>

# Zadanie 1 - indeksy

Wykonaj poniższy skrypt, aby przygotować dane:

```sql
select * into product_history
from northwind3.dbo.product_history


select * into categories  
from northwind3.dbo.categories


create clustered index categ_clust_idx  
on categories(categoryid)
```

sprawdź liczbę wierszy w tabeli

```sql
select count(*) from product_history
```

![Liczba wierszy tabeli `product_history`](./media/ex1-1.png)

Sprawdź jakie indeksy istnieją dla tej tabeli

```sql
exec sp_helpindex 'dbo.product_history'
```

![Indeksy tabeli `product_history`](./media/ex1-2.png)

```sql
Select
    i.name as index_name,
    i.type_desc,
    i.is_unique,
    c.name as column_name,
    ic.key_ordinal,
    ic.is_included_column
from sys.indexes i
join sys.index_columns ic
    on i.object_id = ic.object_id
   and i.index_id = ic.index_id
join sys.columns c
    on ic.object_id = c.object_id
   and ic.column_id = c.column_id
where i.object_id = object_id('dbo.product_history')
order by i.name, ic.key_ordinal;
```

![Indeksy tabeli `product_history`](./media/ex1-3.png)

włącz statystyki IO i TIME

```sql
SET STATISTICS IO ON

SET STATISTICS TIME ON;
```

podczas analiz sprawdzaj jak zachowują się zapytania, zwróć uwagę na

- plan
- koszt
- czas (ewentualnie, jeśli coś da się zaobserwować)
- liczbę odczytywanych stron !!!!

porównaj zapytania

Sprzęt:

- wykonane na maszynie z procesorem AMD Ryzen 7 7800X3D 8-Core Processor (16 logical processors)

### a)

```sql
select count(*) from product_history
where id = 1000000

select count(*) from product_history
where id between 999000 and 10000000
```

#### Wyniki

```sql
select count(*) from product_history
where id = 1000000
```

- wynik zapytania:

![alt text](image-2.png)

- plan zapytania i koszt:

![alt text](image.png)

- czas i liczba odczytywanych stron:

![alt text](image-1.png)

Komentarz:

- execution plan wskazuje, że największy koszt jest związany ze skanowaniem tabeli, dodatkowo `mssql` włączył parallelism, co znacząco zredukowało czas (CPU time = 224 ms, elapsed time = 17 ms.)
- odczytanych stron było 25266 (~ 1500 na wątek)
- skanów tabeli było 17 (przez parallelism, 1 na wątek)
- `mssql` zasygnalizowal brak indeksu na kolumnie `id` z dużym `Impact` (~99.9%)
- "gruba strzałka" na planie wskazuje, że skanowanie tabeli jest najbardziej kosztowną operacją w planie zapytania

```sql
select count(*) from product_history
where id between 999000 and 10000000
```

- wynik zapytania:

![alt text](image-3.png)

- plan zapytania i koszt:

![alt text](image-4.png)

- czas i liczba odczytywanych stron:

![alt text](image-5.png)

Komentarz:

- w planie zapytania widać wskazanie, że tabela nie ma indeksu klastrowego, więc jest to Heap Table Scan, w tym wypadku zapytanie filtruje po przedziale, więc też jest Hash Match
- podobnie jak w poprzednim zapytaniu, `mssql` włączył parallelism, co też zredukowało czas (CPU time = 247 ms, elapsed time = 22 ms.)
- liczba czytanych stron jak i skanów tabeli jest taka sama (podobnie ~1500 na wątek, 1 na wątek)
- tak samo jak w poprzednim zapytaniu największy koszt jest związany ze skanowaniem tabeli, a `mssql` zasygnalizowal brak indeksu na kolumnie `id` z dużym `Impact` (~95%)

### b)

```sql
select * from product_history
where id = 1000000


select * from product_history
where id between 999000 and 10000000
```

#### Wyniki

```sql
select * from product_history
where id = 1000000
```

- wynik zapytania:

![alt text](image-6.png)

- plan zapytania i koszt:

![alt text](image-7.png)

- czas i liczba odczytywanych stron:

![alt text](image-8.png)

Komentarz:

- wnioski są podobne do pierwszego zapytania z podpunktu a), z tą różnicą, że w planie zapytnia nie ma operatora `Stream Aggregate` i `Compute Scalar`, co jest związane z tym, że zapytanie zwraca wszystkie kolumny, a nie tylko ich liczbę

```sql
select * from product_history
where id between 999000 and 10000000
```

- wynik zapytania:

![alt text](image-9.png)

- plan zapytania i koszt:

![alt text](image-10.png)

- czas i liczba odczytywanych stron:

![alt text](image-11.png)

Komentarz:

- `ssms` zasugerował dodanie indeksu klastrowego, ale już z mniejszym `Impact` (~50%), co jest związane z tym, że zapytanie ~1 mln rekordów z całej tabeli, która ma ~2,3 mln rekordów w sumie
- tutaj liczba czytanych stron i skanów tabeli jest znów taka sama, ale czas jest znacznie dłuższy (CPU time = 6480 ms, elapsed time = 4929 ms.). Analizując czas per wątek (~20ms) widzimy, że one nie są bottleneckiem, a do tego przeglądając XML, tag `<WaitStats>`, widać, że czas dla `CXPACKET` jest bardzo duży (`<Wait WaitType="CXPACKET" WaitTimeMs="70734" WaitCount="265802" />`), co może sugerować, że bottleneckiem jest sam `SSMS` (przetworzenie i prezentacja ~1 mln pełnych rekordów)

### c)

sprawdź jak zachowają się zapytania z pkt a) i b) jeśli dla kolumny `id` stworzysz indeks

- klastrowy
- nieklastrowy

```sql
create clustered index product_history_clust_idx
on product_history(id)

drop index product_history_clust_idx on product_history

create index product_history_idx
on product_history(id)

drop index product_history_idx on product_history
```

po zakończeniu pozostaw indeks klastrowy

#### Wyniki

##### a1)

###### Indeks klastrowy

- plan zapytania i koszt:

  ![alt text](image-12.png)

- czas i liczba odczytywanych stron:

  ![alt text](image-13.png)

Komentarz:

- czas jest praktycznie zerowy (0ms)
- liczba czytanych stron drastycznie spadła z ~25000 do 3, podobnie skanów z 17 do 1. (co też jest związane z brakiem paralelizmu)
- w planie wykonywany jest `Index Seek`, który błyskawicznie znajduje pożądany rekord

###### Indeks nieklastrowy

- plan zapytania i koszt:

![alt text](image-20.png)

- czas i liczba odczytywanych stron:

![alt text](image-21.png)

Komentarz:

- rezultaty są praktycznie takie same jak przy indeksie klastrowym, prawdopodobnie przez to, że agregacja `count()` nie potrzebuje odczytywać dodatkowych kolumn, a tylko istnienie rekordu, więc indeks nieklastrowy jest wystarczający do szybkiego znalezienia rekordu

##### a2)

###### Indeks klastrowy

- plan zapytania i koszt:

  ![alt text](image-14.png)

- czas i liczba odczytywanych stron:

  ![alt text](image-15.png)

Komentarz:

- liczba czytanych stron również spadła ale do 14802, co jest spowodowane, że te 1 mln rekordów musiało zostać przeczytanych, jednak mimo to warto zwrócić uwagę, że teraz liczba czytanych stron jest proporcjonalna do zwracanego zakresu
- czas spadł nieznacznie o 3ms

###### Indeks nieklastrowy

- plan zapytania i koszt:

![alt text](image-22.png)

- czas i liczba odczytywanych stron:

![alt text](image-23.png)

Komentarz

- w przypadku indeksu nieklastrowego liczba odczytywanych stron została zredukowana jeszcze bardziej, co jest związane z tym, że indeks klastrowy jest mniejszą strukturą danych (ma tylko pointery do danych), zmniejszyło to liczbę odczytywanych stron do 2938
- `elapsed time` jest większy, co prawdopodbnie jest związane z brakiem paralelizmu (czasy CPU są praktycznie identyczne), prawdopodobnie optimizer nie włączył paralelizmu przez małą liczbę stron do odczytania, można też sprawdzić parametr `Degree of Parallelism` = 1, a `mssql` włącza paralelism, jeśli jest wynosi on co najmniej 5 by default (properties serwera -> Advanced -> Cost Threshold for Parallelism).

##### b1)

###### Indeks klastrowy

- plan zapytania i koszt:

  ![alt text](image-16.png)

- czas i liczba odczytywanych stron:

  ![alt text](image-17.png)

Komentarz:

- podobnie jak w przypadku zapytania a1) czas jest praktycznie zerowy (0ms)
- liczba czytanych stron spadła z ~25000 do 3, podobnie skanów z 17 do 1. (co też jest związane z brakim paralelizmu)
- w planie wykonywany jest `Index Seek`, który błyskawnie znajduje pożądany rekord

###### Indeks nieklastrowy

- plan zapytania i koszt:

![alt text](image-24.png)

- czas i liczba odczytywanych stron:

![alt text](image-25.png)

Komentarz:

- czas jest praktycznie zerowy (0ms)
- warto zwrócić uwagę na różnice w planach, z uwagi na strukturę indeksu nieklastrtowego, `mssql` dodał krok `RID Lookup` (RID, bo tabela nie ma indeksu klastrowego, więc jest Heapem), który musi odczytać dane z tablei, a następnie wykonuje inner join z indeksem, aby zwrócić pełny rekord
- liczba czytanych stron jest większa o 1 niż w przypadku indeksu klastrowego (3 vs 4)

##### b2)

###### Indeks klastrowy

- plan zapytania i koszt:

  ![alt text](image-19.png)

- czas i liczba odczytywanych stron:

  ![alt text](image-18.png)

Komentarz:

- liczba czytanych stron również spadła ale do 14802, co jest spowodowane, że te 1 mln rekordów musiało zostać przeczytanych, podobnie jak w przypadku a2) liczba czytanych stron jest proporcjonalna do zwracanego zakresu
- czas (elapsed time) nie zmienił się drastycznie (CPU time = 615 ms, elapsed time = 4390 ms.), co może być spowodowanie bottleneckiem `SSMS` (przetworzenie i prezentacja ~1 mln pełnych rekordów), ale czas CPU spadł drastycznie z 6480ms do 615ms, co jest związane z tym, że teraz `mssql` nie musi skanować całej tabeli, a może od razu znaleźć pożądany rekord i zwrócić zakres do końca
- nie ma tu też paralelizmu

###### Indeks nieklastrowy

- plan zapytania i koszt:

![alt text](image-26.png)

- czas i liczba odczytywanych stron:

![alt text](image-27.png)

Komentarz:

- w tym wypadku liczba czytanych stron zwiększyła się do 25841 (z 25266) w porównaniu do zapytania bez indeksu
- `mssql` zalecił dodanie indeksu klastrowego, tak samo jak w przypadku zapytania bez indeksu
- co najważniejsze sam indeks nieklastrowy został zignorowany, co jest związane z tym, że zapytanie zwraca duży zakres danych, więc dodanie kroków `Index Seek` + `RID Lookup` dla każdego rekordu byłoby bardzo kosztowne (tzw. Tipping Point), więc `mssql` zdecydował się na skanowanie całej tabeli, co jest szybsze w tym przypadku

### d)

indeks dla kolumny `date`

```sql
create index product_history_date_idx
on product_history(date)

drop index product_history_date_idx on product_history
```

porównaj polecenia

```sql
select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-01-31'

select id, productid, productname, date
from product_history
where year(date) = 2001 and month(date) = 1

select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-12-31'

select id, productid, productname, date
from product_history
where year(date) = 2001
```

podczas analiz sprawdzaj jak zachowują się zapytania, zwróć uwagę na

- plan
- indeksy i sposób ich użycia
- koszt
- czas (ewentualnie, jeśli coś da się zaobserwować)
- liczbę odczytywanych stron !!!!

spróbuj skomentować wyniki tych analiz, dlaczego tak się dzieje

```sql
select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-01-31'
```

- plan zapytania i koszt:

![alt text](image-28.png)

- czas i liczba odczytywanych stron:

![alt text](image-29.png)

Komentarz:

- elapsed time jest niski (6ms), liczba odczytanych stron to 7327, nie ma paralelizmu.
- samo zapytanie wykonuje `Index Seek`, aby znaleźć dane z zakresu, ale musi zrobić `Key Lookup` (bez RID, bo tabela ma już indeks klastrowy po kolumnie `id`), aby odczytać pełne rekordy i później `Inner Join`.
- `mssql` zasygnalizował aby stworzyć index na `date` z włączeniem kolumn `productid` i `productname` (z `Impact` ~53%), aby wyeliminować `Key Lookup`

```sql
select id, productid, productname, date
from product_history
where year(date) = 2001 and month(date) = 1
```

- plan zapytania i koszt:

![alt text](image-30.png)

- czas i liczba odczytywanych stron:

![alt text](image-31.png)

Komentarz:

- o wiele większa liczba odczytywanych stron 26081, 17 skanów (+ paralelizm), czas również większy (CPU time = 364 ms, elapsed time = 31 ms)
- użycie funkcji `year()` i `month()` na kolumnie `date` sprawia, że indeks nie może być użyty, więc `mssql` musi przeskanować całą tabelę, aby znaleźć pasujące rekordy, jest to tzw. Non-SARGable query

```sql
select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-12-31'
```

- plan zapytania i koszt:

![alt text](image-32.png)

- czas i liczba odczytywanych stron:

![alt text](image-33.png)

Komentarz:

- liczba odczytanych stron jest większa niż w przypadku pierwszego zapytania(7327 vs 26081), co jest związane z tym, że zakres jest większy (cały rok vs styczeń)
- czas jest również większy (CPU time = 133 ms, elapsed time = 19 ms)
- w planie zapytania widać, że `mssql` zdecydował się na skanowanie indeksu zamiast `Index Seek`, prawdopodobnie został przekroczony tzw. Tipping Point
- dodatkowo `mssql` zasygnalizował, że dla tego zapytania warto byłoby stworzyć indeks na `date` z włączeniem kolumn `productid` i `productname` (z `Impact` ~82%)

```sql
select id, productid, productname, date
from product_history
where year(date) = 2001
```

- plan zapytania i koszt:

![alt text](image-34.png)

- czas i liczba odczytywanych stron:

![alt text](image-35.png)

Komentarz:

- liczba stron jest taka sama jak w poprzednim zapytaniu 26081, ale czas jest większy (CPU time = 368 ms, elapsed time = 38 ms), bo też procesor musiał wykonać funkcję `year()` dla każdego rekordu
- podobnie jak w poprzednim zapytaniu z funkcjami `year()` i `month()` indeks nie może być użyty, więc `mssql` musi przeskanować całą tabelę (`Clustered Index Scan`)
- w tym wypadku `mssql` nie zasugerował założenie indeksu z włączeniem kolumn

### e)

powtórz eksperymenty z pkt d) , ale tym razem użyj indeksu zawierającego dodatkowe kolumny

```sql
create index product_history_date_incl_idx
on product_history(date) include(productid, productname)

drop index product_history_date_incl_idx on product_history

```

co się zmieniło?

```sql
select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-01-31'
```

- plan zapytania i koszt:

![alt text](image-36.png)

- czas i liczba odczytywanych stron:

![alt text](image-37.png)

Komentarz:

- czas spadł (CPU time = 0 ms, elapsed time = 1 ms), liczba odczytanych stron spadła do 16, a w planie zapytania widać, że `mssql` używa teraz `Index Seek` bezpośrednio na indeksie z włączeniem kolumn, więc nie ma potrzeby wykonywania `Key Lookup`, co znacząco poprawia wydajność

```sql
select id, productid, productname, date
from product_history
where year(date) = 2001 and month(date) = 1
```

- plan zapytania i koszt:

![alt text](image-38.png)

- czas i liczba odczytywanych stron:

![alt text](image-39.png)

Komentarz:

- liczba stron po włączeniu do indeksu kolumn `productid` i `productname` spadła do 11424, bo teraz `mssql` wykonuje `Index Scan` na indeksie z włączeniem kolumn:

```xml

 <IndexScan ...>
   ...
  <Object ... Table="[product_history]" Index="[product_history_date_incl_idx]" IndexKind="NonClustered"  />
  ...
</IndexScan>
```

- czasy są bardzo podobne (CPU time = 339 ms, elapsed time = 34 ms. vs CPU time = 364 ms, elapsed time = 31 ms), co jest związane z tym, że zapytanie nadal jest Non-SARGable, więc `mssql` musi przeskanować cały indeks i wykonać funkcję `year()` i `month()` dla każdego rekordu

```sql
select id, productid, productname, date
from product_history
where date >= '2001-01-01' and date <= '2001-12-31'
```

- plan zapytania i koszt:

![alt text](image-41.png)

- czas i liczba odczytywanych stron:

![alt text](image-42.png)

Komentarz:

- liczba stron bardzo spadła z 26081 do 143, a czas również spadł (CPU time = 133 ms, elapsed time = 19 ms. vs CPU time = 9 ms, elapsed time = 9 ms.), co jest związane z tym, że teraz `mssql` może użyć `Index Seek` na indeksie z włączeniem kolumn, zamiast skanować używać `Clustered Index Scan` na całej tabeli, więc teraz zapytanie jest bardzo szybkie
- nie ma paralelizmu

```sql
select id, productid, productname, date
from product_history
where year(date) = 2001
```

- plan zapytania i koszt:

![alt text](image-43.png)

- czas i liczba odczytywanych stron:

![alt text](image-44.png)

Komentarz:

- liczba stron spadła z 26091 do 11424, ale czasy są bardzo podobne (CPU time = 368 ms, elapsed time = 38 ms. vs CPU time = 365 ms, elapsed time = 36 ms)
- podobnie jak w przypadku zapytania z funkcjami `year()` i `month()`, indeks z włączeniem kolumn nie jest wystarczający, ale zmniejsza liczbę odczytywanych stron, bo teraz `mssql` wykonuje `Index Scan` na indeksie z włączeniem kolumn (non clustered)
- włączony jest paralelizm

### f)

indeks dla kolumny `categoryid`

```sql
create index product_history_cat_idx
on product_history(categoryid)

drop index product_history_cat_idx on product_history
```

przeanalizuj polecenia

```sql
select id, productid, productname, date 
from product_history p
where categoryid = 8
```

- plan zapytania i koszt:

![alt text](image-45.png)

- czas i liczba odczytywanych stron:

![alt text](image-46.png)

Komentarz:

- z analizy planu: zapytanie korzysta z dwóch indeksów jednocześnie (używając też paralelizmu), w jednej gałęzi jest `Index Seek` po `categoryid`, aby stworzyć bitmapę (Bitmap Create) w celu filtracji rekordów zanim dotrą do Joina ("eliminating rows with key values that can't produce any join records before passing rows through another operator"), a w drugiej gałęzi jest `Index Scan` (po non-clustered, aby zaoszczędzić liczbę czytanych stron), na koniec jest Join, który łączy dane z obu gałęzi i `Gather Streams`, który zbiera dane z wątków i zwraca wynik
- obie gałęzie używają paralelizmu, więc Scan Count jest duży (34)
- liczba odczytywanych stron wyniosła 12084, a czas: CPU time = 1418 ms, elapsed time = 470 ms.
- `mssql` zasygnalizował, że dla tego zapytania można dodać indeks nieklastrowy na `categoryid` z włączeniem kolumn `productid`, `productname`, `date` (z `Impact` ~90%), co prawodopodobnie wyeliminowałoby dolną gałąź z `Index Scan` i pozwoliłoby na użycie `Index Seek` na indeksie z włączeniem kolumn, co znacząco poprawiłoby wydajność

```sql
select id, productid, productname, date, categoryname
from product_history p join categories c on p.categoryid = c.categoryid
where p.categoryid = 8
```

- plan zapytania i koszt:

![alt text](image-47.png)

- czas i liczba odczytywanych stron:

![alt text](image-48.png)

Komentarz:

- dodanie nowej tabeli do zapytania (`categories`) zwiększyło jego skomplikowanie i teraz wykorzystany jest tylko index klastrowy na `id`, więc `mssql` zdecydował się na przeskanowanie całej tabeli `product_history`, aby następnie wykonać join z tabelą `categories`
- widać też pogrubioną strzałkę z `Clustered Index Scan` do `Nested Loops`, co oznacza, że jest najbardziej kosztowna ścieżka w planie zapytania
- liczba odczytywanych wzrosła do 25891, a czas wyniósł CPU time = 370 ms, elapsed time = 622 ms. (brak paralelizmu - mniejsze cpu time, ale nieoptymalne zapytanie zwiękzyło czas)
- `mssql` zasygnalizował, że dla tego zapytania można dodać indeks nieklastrowy na `categoryid` z włączeniem kolumn `productid`, `productname`, `date` (z `Impact` ~92%)

### dodatkowo

możesz sprawdzić strukturę indeksu

np.

```sql
exec sp_helpindex 'dbo.product_history';

select
    i.name as index_name,
    ips.index_depth,
    ips.index_level,
    ips.page_count
from sys.indexes i
cross apply sys.dm_db_index_physical_stats(
    db_id(),
    i.object_id,
    i.index_id,
    null,    'detailed'
) ips
where i.object_id = object_id('dbo.product_history')
  and i.name = 'product_history_date_idx';
```

Na przykładzie indeksu nieklastrowego:

- `product_history_date_idx` (bez włączenia kolumn):

![alt text](image-49.png)

- `product_history_date_incl_idx` (z włączeniem kolumn):

![alt text](image-50.png)

Komentarz:

- po metadanych indeksu z włączeniem kolumn można zauważyć, że liczba na poziomie 0 (leaf) jest znacznie większa niż w przypadku indeksu bez włączenia kolumn (11264 vs 3724), co jest związane z tym, że teraz indeks z włączeniem kolumn ma więcej danych do przechowywania (nie tylko klucz, ale też dodatkowe kolumny)

Możemy jeszcze porównać indeksy z zadania a) dla kolumny `id`:

- `product_history_clust_idx` (indeks klastrowy):

![alt text](image-52.png)

- `product_history_idx` (indeks nieklastrowy):

![alt text](image-51.png)

Komentarz:

- widać, że indeks klastrowy jako, że przechowuje pełne dane, ma znacznie więcej stron na poziomie 0 (leaf) niż indeks nieklastrowy (25841 vs 5152), co jest związane z tym, że indeks klastrowy jest całą tabelą, a indeks nieklastrowy jest tylko strukturą danych z kluczami i pointerami do danych

jeśli chcesz zaobserwować odczyty logiczne/fizyczne możesz zwolnić pulę buforów przed wykonaniem polecenia

```sql
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
```

i teraz porównaj liczby czytanych stron np. wykonując dwukrotnie polecenie

```sql
select * from product_history
```

- IO statistics dla pierwszego zapytania:

```md
Table 'product_history'. Scan count 1, logical reads 25891, physical reads 1, page server reads 0, read-ahead reads 25968, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
```

- IO statistics dla drugiego zapytania:

```md
Table 'product_history'. Scan count 1, logical reads 25891, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
```

Komentarz:

- w pierwszym zapytaniu, po wyczyszczeniu buforów, `mssql` musiał odczytać dane z dysku, ale widząc, że zapytanie może potrzebować więcej danych z tej tabeli, `mssql` wykonał read-ahead, aby załadować kolejne strony do bufora, co jest widoczne w statystykach jako `read-ahead reads 25968`
- w drugim zapytaniu, dane są już w buforze, więc nie ma potrzeby odczytywać z dysku, więc `physical reads` wynosi 0, a `logical reads` jest taka sama jak w pierwszym zapytaniu, bo teraz dane są odczytywane z bufora, a nie z dysku

# Zadanie 2

Celem zadania jest poznanie indeksów typu column store

Utwórz tabelę testową:

```sql
create table saleshistory(
 id int identity(1,1) not null primary key,
 salesorderid int not null,
 salesorderdetailid int not null,
 carriertrackingnumber nvarchar(25) null,
 orderqty smallint not null,
 productid int not null,
 specialofferid int not null,
 unitprice money not null,
 unitpricediscount money not null,
 linetotal numeric(38, 6) not null,
 rowguid uniqueidentifier not null,
 modifieddate datetime not null
 )
```

Sprawdź jakie indeksy istnieją dla tej tabeli

```sql
exec sp_helpindex 'dbo.saleshistory'
```

```sql
Select
    i.name as index_name,
    i.type_desc,
    i.is_unique,
    c.name as column_name,
    ic.key_ordinal,
    ic.is_included_column
from sys.indexes i
join sys.index_columns ic
    on i.object_id = ic.object_id
   and i.index_id = ic.index_id
join sys.columns c
    on ic.object_id = c.object_id
   and ic.column_id = c.column_id
where i.object_id = object_id('dbo.saleshistory')
order by i.name, ic.key_ordinal;
```

Wypełnij tablicę danymi:

```sql
-- w ssms

insert into saleshistory
 select sh.*
 from adventureworks2017.sales.salesorderdetail sh
go 100
```

(UWAGA `GO 100` oznacza 100 krotne wykonanie polecenia. Jeżeli podejrzewasz, że twój serwer może to zbyt przeciążyć, zacznij od GO 10, GO 20, GO 50

albo

```sql
declare @i int = 1;

while @i <= 100
begin
    insert into saleshistory
    select *
    from adventureworks2017.sales.salesorderdetail;

    set @i += 1;
end;
```

sprawdź liczbę wierszy w tabeli

```sql
select count(*) from saleshistory
```

włącz statystyki IO i TIME

```sql
SET STATISTICS IO ON

SET STATISTICS TIME ON;
```

Sprawdź jak zachowa się zapytanie

- sprawdź plan
- koszt
- czas
- liczbę odczytywanych stron

```sql
select productid, sum(unitprice), avg(unitprice), sum(orderqty), avg(orderqty)
from saleshistory
group by productid
order by productid
```

Załóż indeks typu column store:

```sql
create nonclustered columnstore index saleshistory_columnstore
 on saleshistory(unitprice, orderqty, productid)
```

Sprawdź różnicę pomiędzy przetwarzaniem w zależności od indeksów. Porównaj plany i opisz różnicę.
Co to są indeksy colums store? Jak działają? (poszukaj materiałów w internecie/literaturze)

UWAGA: ciekawsze efekty możesz zaobserwować dla jeszcze większych tabel (jeśli twój komp na to pozwala możesz zwiększyć wolumen generowanych danych)

# Zadanie 3 – własne eksperymenty

Należy zaprojektować/zaimplementować tabelę w bazie danych, lub wybrać dowolny schemat/bazę/tabelę (poza używanymi na zajęciach), a następnie wypełnić ją danymi w taki sposób, przetestować/przeanalizować działanie indeksów różnego typu. Warto wygenerować sobie tabele o większym rozmiarze.

Możesz też powtórzyć np. eksperymenty wykonywane w zadaniu 1, ale tym razem dla innego serwera,

Wedle uznania i zainteresowań, ważne żeby poeksplorować tematykę i spróbować

Do analizy, proszę uwzględnić następujące rodzaje indeksów:

- Klastrowane (np.  dla atrybutu nie będącego kluczem głównym)
- Nieklastrowane
- Indeksy wykorzystujące kilka atrybutów, indeksy include
- Filtered Index (Indeks warunkowy)
- Kolumnowe

## Analiza

Proszę przygotować zestaw zapytań do danych, które:

- wykorzystują poszczególne indeksy
- które przy wymuszeniu indeksu działają gorzej, niż bez niego (lub pomimo założonego indeksu, tabela jest w pełni skanowana)
  Odpowiedź powinna zawierać:
- Schemat tabeli
- Opis danych (ich rozmiar, zawartość, statystyki)
- Opis indeksu
- Przygotowane zapytania, wraz z wynikami z planów (zrzuty ekranow)
- Inf o kosztach, czytanych stornach
- Komentarze do zapytań, ich wyników
- ew. sprawdzenie, co proponuje Database Engine Tuning Advisor (porównanie czy udało się Państwu znaleźć odpowiednie indeksy do zapytania)

> Wyniki:

```sql
--  ...
```

|         |                                                                          |     |
| ------- | ------------------------------------------------------------------------ | --- |
| zadanie | pkt                                                                      |     |
| 1       | 6                                                                        |     |
| 2       | 2                                                                        |     |
| 3       | 5 (3 pkt. za eksperymenty + 2 dodatkowe za ciekawe/oryginalne przyklady) |     |
| razem   | 13                                                                       |     |
