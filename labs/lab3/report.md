# Indeksy, optymalizator <br>Lab1

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

Celem ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans), oraz z budową i możliwością wykorzystaniem indeksów.

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---

> Wyniki:

```sql
--  ...
```

---

Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki

- dołącz kod rozwiązania w formie tekstowej/źródłowej
- najlepiej plik .md
  - ewentualnie sql

Zwróć uwagę na formatowanie kodu

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie

- MS SQL Server
- SSMS - SQL Server Management Studio
  - ewentualnie inne narzędzie umożliwiające komunikację z MS SQL Server i analizę planów zapytań
- przykładowa baza danych AdventureWorks2017.

Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej

## Przygotowanie

Stwórz swoją bazę danych o nazwie lab1.

```sql
create database lab1
go

use lab1
go
```

# Część 1

Celem tej części ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans) oraz narzędziem do automatycznego generowania indeksów.

## Dokumentacja/Literatura

Przydatne materiały/dokumentacja. Proszę zapoznać się z dokumentacją:

- [https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor)
- [https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor)
- [https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer](https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer)
- [https://blog.quest.com/sql-server-execution-plan-what-is-it-and-how-does-it-help-with-performance-problems/](https://blog.quest.com/sql-server-execution-plan-what-is-it-and-how-does-it-help-with-performance-problems/)

Operatory (oraz reprezentujące je piktogramy/Ikonki) używane w graficznej prezentacji planu zapytania opisane są tutaj:

- [https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference](https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference)

<div style="page-break-after: always;"></div>

Wykonaj poniższy skrypt, aby przygotować dane:

```sql
select * into [salesorderheader]
from [adventureworks2017].sales.[salesorderheader]
go

select * into [salesorderdetail]
from [adventureworks2017].sales.[salesorderdetail]
go
```

# Zadanie 1 - Obserwacja

Wpisz do MSSQL Managment Studio (na razie nie wykonuj tych zapytań):

```sql
-- zapytanie 1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2008-06-01 00:00:00.000'
go

-- zapytanie 1.1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2013-01-28 00:00:00.000'
go

-- zapytanie 2
select orderdate, productid, sum(orderqty) as orderqty,
       sum(unitpricediscount) as unitpricediscount, sum(linetotal)
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
group by orderdate, productid
having sum(orderqty) >= 100
go

-- zapytanie 3
select salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate in ('2008-06-01','2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05')
go

-- zapytanie 4
select sh.salesorderid, salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where carriertrackingnumber in ('ef67-4713-bd', '6c08-4c4c-b8')
order by sh.salesorderid
go
```

Włącz dwie opcje: **Include Actual Execution Plan** oraz **Include Live Query Statistics**:

<!-- ![[media/index1-1.png | 500]] -->

<img src="media/index1-1.png" alt="image" width="500" height="auto">

Teraz wykonaj poszczególne zapytania (najlepiej każde analizuj oddzielnie). Co można o nich powiedzieć? Co sprawdzają? Jak można je zoptymalizować?

---

## Wyniki:

```sql
-- zapytanie 1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2008-06-01 00:00:00.000'
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 1](media/ex1-1-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 1](media/ex1-1-execution-plan.png)

- Wnioski:
  - najwięcej kosztu generuje skanowanie tabeli `salesorderheader` (Table Scan) w celu znalezienia wszystkich rekordów z datą `2008-06-01`
  - to zapytanie można zoptymalizować poprzez dodanie indeksu na kolumnie `orderdate` w tabeli `salesorderheader`, co pozwoliłoby na szybsze wyszukiwanie rekordów z określoną datą (co proponuje SSMS poprzez `Missing Index Suggestion` z `Impact` ~ 25%)
  - serwer wykonuje `Hash Match` do połączenia tabel `salesorderheader` i `salesorderdetail`
  - podczas skanowania serwer estymuje, że zapytanie zwróci 121317 rekordów, a w rzeczywistości zwraca 0 rekordów, co mogło wpłynąć na wybór planu zapytania

```sql
-- zapytanie 1.1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2013-01-28 00:00:00.000'
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 1.1](media/ex1-1.1-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 1.1](media/ex1-1.1-execution-plan.png)

Wnioski:

- znów najwięcej kosztu generuje skanowanie tabeli `salesorderheader` (Table Scan) w celu znalezienia wszystkich rekordów z datą `2013-01-28`
- znów SSMS proponuje dodanie indeksu na kolumnie `orderdate` w tabeli `salesorderheader` z `Impact` ~ 25%
- serwer wykonuje `Hash Match` do połączenia tabel `salesorderheader` i `salesorderdetail`
- serwer estymuje, że zapytanie zwróci 575 rekordów, w rzeczywistości zwraca 1224 rekordy

```sql
-- zapytanie 2
select orderdate, productid, sum(orderqty) as orderqty,
       sum(unitpricediscount) as unitpricediscount, sum(linetotal)
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
group by orderdate, productid
having sum(orderqty) >= 100
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 2](media/ex1-2-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 2](media/ex1-2-execution-plan.png)

Wnioski:

- znów najwięcej kosztu generuje skanowanie tabeli `salesorderheader` (Table Scan) w celu znalezienia wszystkich rekordów (kosz~y ~37%), dalej agregacja wyników (koszt ~25%)
- serwer wykonuje `Hash Match` do połączenia tabel `salesorderheader` i `salesorderdetail` oraz do grupowania danych
- SSMS proponuje dodanie indeksu na kolumnie `orderdate` w tabeli `salesorderheader` z `Impact` ~ 50%, ale w tym przypadku proponuje włączenie też innych kolumn do indeksu
- serwer wykorzystał `Parallelism` do wykonania zapytania, co skrócioło czas jego wykonania (z `XML`: `<QueryTimeStats CpuTime="247" ElapsedTime="36" />`)
- serwer estymuje, że zapytanie zwróci 1 rekord, w rzeczywistości zwraca 523 rekordów

```sql
-- zapytanie 3
select salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate in ('2008-06-01','2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05')
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 3](media/ex1-3-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 3](media/ex1-3-execution-plan.png)

- Wnioski:
  - znów najwięcej kosztu generuje skanowanie tabeli `salesorderheader` (Table Scan) w celu znalezienia wszystkich rekordów z datami z zakresu `2008-06-01` - `2008-06-05`
  - serwer wykonuje `Hash Match` do połączenia tabel `salesorderheader` i `salesorderdetail`
  - SSMS proponuje dodanie indeksu na kolumnie `orderdate` w tabeli `salesorderheader` z `Impact` ~ 25% oraz włączenie innych kolumn do indeksu
  - serwer estymuje, że zapytanie zwróci 5 rekordów, w rzeczywistości zwraca 0

```sql
-- zapytanie 4
select sh.salesorderid, salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where carriertrackingnumber in ('ef67-4713-bd', '6c08-4c4c-b8')
order by sh.salesorderid
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 4](media/ex1-4-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 4](media/ex1-4-execution-plan.png)

- Wnioski:
  - znów najwięcej kosztu generuje skanowanie tabeli `salesorderheader` (Table Scan) w celu znalezienia wszystkich rekordów z określonymi `carriertrackingnumber`
    - w tym wypadku większy koszt generuje skanowanie tabeli predykatowej, jako, że ma ona więcej rekordow (`orderdetails > orderheader`)
  - serwer wykonuje `Hash Match` do połączenia tabel `salesorderheader` i `salesorderdetail`
  - SSMS proponuje dodanie indeksu na kolumnie `carriertrackingnumber` w tabeli `salesorderdetail` z `Impact` ~ 57%, włączając `SalesOrderID` do indeksu
  - serwer estymuje, że zapytanie zwróci 76 rekordy, a w rzeczywistości zwraca 68 rekordy

# Zadanie 2 - Dobór indeksów / optymalizacja

Do wykonania tego ćwiczenia potrzebne jest narzędzie SSMS

Zapytania 1, 2, 3, 4 z poprzedniego zadania

```sql
-- zapytanie 1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2008-06-01 00:00:00.000'
go

-- zapytanie 2
select orderdate, productid, sum(orderqty) as orderqty,
       sum(unitpricediscount) as unitpricediscount, sum(linetotal)
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
group by orderdate, productid
having sum(orderqty) >= 100
go

-- zapytanie 3
select salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate in ('2008-06-01','2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05')
go

-- zapytanie 4
select sh.salesorderid, salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where carriertrackingnumber in ('ef67-4713-bd', '6c08-4c4c-b8')
order by sh.salesorderid
go
```

Zaznacz wszystkie zapytania, i uruchom je w **Database Engine Tuning Advisor**:

<!-- ![[media/index1-12.png | 500]] -->

<img src="media/index1-2.png" alt="image" width="500" height="auto">

Sprawdź zakładkę **Tuning Options**, co tam można skonfigurować?

---

## Wyniki:

![Tuning Options](media/ex2-tuning-options.png)

Można tam skonfigurować:

- limit czasu analizy
- jakie fizyczne struktury mają być brane pod uwagę przy rekomendacji
- strategia partycjonowania danych
- jakie fizyczne struktury należy zachować (np. istniejące indeksy)
- maksymalne rozmiary rekomendacji
- czy rekomendacje mają być offline czy online (online - bez przerywania pracy serwera, offline - z przerwą w pracy serwera)

Użyj **Start Analysis**:

<!-- ![[_img/index1-3.png | 500]] -->

<img src="media/index1-3.png" alt="image" width="500" height="auto">

Zaobserwuj wyniki w **Recommendations**.

Przejdź do zakładki **Reports**. Sprawdź poszczególne raporty. Główną uwagę zwróć na koszty i ich poprawę:

<!-- ![[_img/index4-1.png | 500]] -->

<img src="media/index1-4.png" alt="image" width="500" height="auto">

Zapisz poszczególne rekomendacje:

Uruchom zapisany skrypt w Management Studio.

Opisz, dlaczego dane indeksy zostały zaproponowane do zapytań:

---

## Wyniki:

Raporty:

![Statement Cost](media/ex2-statement-cost-report.png)

![Statement Cost Range](media/ex2-statement-cost-range-report.png)

![Statement Detail](media/ex2-statement-detail-report.png)

---

Sprawdź jak zmieniły się Execution Plany. Opisz zmiany:

---

## Wyniki:

```sql
-- zapytanie 1
select *
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate = '2008-06-01 00:00:00.000'
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 1 po optymalizacji](media/ex2-1-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 1 po optymalizacji](media/ex2-1-execution-plan.png)

Wnioski:

- serwer wykorzystuje `Nested Loops` do połączenia tabel `salesorderheader` i `salesorderdetail`
- serwer dokonuje wykorzystania indeksu `orderdate` w tabeli `salesorderheader` do wyszukania rekordów z datą `2008-06-01`, co jest dużo szybsze niż skanowanie całej tabeli
- serwer o wiele lepiej estymuje liczbę zwracanych rekordów:
  - np. w przeszukiwaniu tabel 4, a zwracane jest 0 (dla porównania w poprzednim planie serwer estymował, że zwróci 121317 rekordów, a w rzeczywistości zwracał 0 rekordów)
  - w tym wypadku błąd estymacji jest mały, co sprawia, że plan jest bardziej efektywny, ponieważ serwer nie musi wykonywać dodatkowych operacji (np. `Hash Match`) do połączenia tabel, a może wykorzystać `Nested Loops`, który jest bardziej efektywny przy mniejszej liczbie zwracanych rekordów

```sql
-- zapytanie 2
select orderdate, productid, sum(orderqty) as orderqty,
       sum(unitpricediscount) as unitpricediscount, sum(linetotal)
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
group by orderdate, productid
having sum(orderqty) >= 100
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 2 po optymalizacji](media/ex2-2-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 2 po optymalizacji](media/ex2-2-execution-plan.png)
Wnioski:

- w odróźnieniu od innych zapytań, serwer wykonuje `Index Scan` zamiast `Index Seek` do wyszukania rekordów z określonymi datami, co jest spowodowane tym, że potrzebuje każdego wiersza do wyliczenia sumy
- raport wskazał, że to zapytanie najmniej skorzysta na dodaniu indeksu, co jest spowodowane tym, że nawet po optymalizacji wyszukiwania, bottleneckiem pozostaje agregacja danych (koszt ~38%, najwyższy spośród wszystkich operatorów)
- zapytanie nadal wykorzystuje `Parallelism` do wykonania zapytania, co skróciło czas jego wykonania (z `XML`: `<QueryTimeStats CpuTime="217" ElapsedTime="31" />`)

```sql
-- zapytanie 3
select salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where orderdate in ('2008-06-01','2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05')
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 3 po optymalizacji](media/ex2-3-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 3 po optymalizacji](media/ex2-3-execution-plan.png)

Wnioski:

- serwer wykorzystuje `Nested Loops` do połączenia tabel `salesorderheader` i `salesorderdetail`
- serwer dokonuje wykorzystania indeksu `orderdate` w tabeli `salesorderheader` do wyszukania rekordów z datami z zakresu `2008-06-01` - `2008-06-05` (`Index Seek`), co jest dużo szybsze niż skanowanie całej tabeli
- serwer o wiele lepiej estymuje liczbę zwracanych rekordów:

```sql
-- zapytanie 4
select sh.salesorderid, salesordernumber, purchaseordernumber, duedate, shipdate
from salesorderheader sh
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid
where carriertrackingnumber in ('ef67-4713-bd', '6c08-4c4c-b8')
order by sh.salesorderid
go
```

- Live Query Statistics:

![Live Query Statistics dla zapytania 4 po optymalizacji](media/ex2-4-live-query-stats.png)

- Execution Plan:

![Execution Plan dla zapytania 4 po optymalizacji](media/ex2-4-execution-plan.png)

Wnioski:

- dodanie indeksu zmieniło plan zapytania, ponieważ serwer wykonuje teraz `Sort` przed `Nested Loops`, co jest spowodowane tym, że serwerowi bardziej opłaca się posortować dane przed połączeniem tabel, niż po połączeniu tabel
- zamiast `Table Scan` serwer wykorzystuje `Index Seek` do wyszukania rekordów z określonymi `carriertrackingnumber`, co jest dużo szybsze niż skanowanie całej tabeli
- są błędy estymacji, ale nie są one duże, aby znacząco wpłynąć na plan zapytania

---

# Część 2

Celem ćwiczenia jest zapoznanie się z różnymi rodzajami indeksów oraz możliwością ich wykorzystania

## Dokumentacja/Literatura

Przydatne materiały/dokumentacja. Proszę zapoznać się z dokumentacją:

- [https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes)
- [https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide)
- [https://www.simple-talk.com/sql/performance/14-sql-server-indexing-questions-you-were-too-shy-to-ask/](https://www.simple-talk.com/sql/performance/14-sql-server-indexing-questions-you-were-too-shy-to-ask/)
- [https://www.sqlshack.com/sql-server-query-execution-plans-examples-select-statement/](https://www.sqlshack.com/sql-server-query-execution-plans-examples-select-statement/)

# Zadanie 3 - Indeksy klastrowane I nieklastrowane

Skopiuj tabelę `Customer` do swojej bazy danych:

```sql
select * into customer from adventureworks2017.sales.customer
```

Wykonaj analizy zapytań:

```sql
select * from customer where storeid = 594

select * from customer where storeid between 594 and 610
```

Zanotuj czas zapytania oraz jego koszt koszt:

---

> Wyniki:

- zapytanie z warunkiem `where storeid = 594`

![Plan zapytania dla warunku "where storeid=594"](media/image-5.png)

![Plan zapytania dla warunku "where storeid=594"](media/image-6.png)

![Czas wykonania zapytania dla warunku "where storeid=594"](media/image-4.png)

- zapytanie z warunkiem `where storeid between 594 and 610`:

![Plan zapytania dla warunku "where storeid between 594 and 610"](media/image-8.png)

![Plan zapytania dla warunku "where storeid between 594 and 610"](media/image-9.png)

![Czas wykonania zapytania dla warunku "where storeid between 594 and 610"](media/image-7.png)

Komentarz:

Jak widać na załączonych zrzutach ekranu, w przypadku braku indeksu wykonywane jest pełny skan tabeli (wszystkie wiersze muszą zostać przeskanowane pod kątem warunku). Koszt obu zapytań jest identyczny (i tak muszą zostać przeskanowane wszystkie wiersze).

Dodaj indeks:

```sql
create  index customer_store_cls_idx on customer(storeid)
```

Jak zmienił się plan i czas? Czy jest możliwość optymalizacji?

---

> Wyniki:

- zapytanie z warunkiem `where storeid = 594`:

![Plan zapytania dla warunku "where storeid=594" - indeks nieklastrowany](media/image-11.png)

![Plan zapytania dla warunku "where storeid=594" - indeks nieklastrowany](media/image-12.png)

![Czas wykonania zapytania dla warunku "where storeid=594" - indeks nieklastrowany](media/image-13.png)

- zapytanie z warunkiem `where storeid between 594 and 610`:

![Plan zapytania dla warunku "where storeid between 594 and 610" - indeks nieklastrowany](media/image-15.png)

![Plan zapytania dla warunku "where storeid between 594 and 610" - indeks nieklastrowany](media/image-14.png)

![Czas wykonania zapytania dla warunku where storeid between 594 and 610" - indeks nieklastrowany](media/image-16.png)

Komentarz:

Po dodaniu indeksu zmienił się plan zapytania - zamiast przeglądania całej tabeli, używa `Nested Loops`, aby dla każdego adresu znalezionego na podstawie `Index Scan` wykonać `RID Lookup` i pobrać brakujące dane z tabeli (w indeksie jest tylko `storeid`, resztę danych musimy pobrać z odpowiedniego miejsca w tabeli). W przypadku obu zapytań koszt zapytania jest zdecydowanie mniejszy w porównaniu do zapytania na tabeli bez indeksu (odpowiednio ~20 razy niższy w przypadku `where storid=594` oraz ~2.5 razy niższe w przypadku `where storeid between 594 and 610`). Różnica w koszcie wynika z faktu, że w przypadku stworzonego indeksu nie mamy dostępu do pobieranych danych (w indeksie zawarte jest tylko `storeid`) i musimy pobrać je ze znalezionych adresów.

Choć koszt zapytań jest niższy, to faktyczny czas wykonania zapytania jest większy w porównaniu do zapytania bez indeksu (w przypadku tak małej ilości danych przeszukanie całej tabeli może być szybsze niż skorzystanie z indeksu)

Dodaj indeks klastrowany:

```sql
create clustered index customer_store_cls_idx on customer(storeid)
```

Czy zmienił się plan/koszt/czas? Skomentuj dwa podejścia w wyszukiwaniu krotek.

---

> Wyniki:

- zapytanie z warunkiem `where storeid=594`

![Plan zapytania dla warunku "where storeid=594" - indeks klastrowany](media/image-17.png)

![Plan zapytania dla warunku "where storeid=594" - indeks klastrowany](media/image-18.png)

![Czas wykonania zapytania dla warunku "where storeid=594" - indeks klastrowany](media/image-19.png)

- zapytanie z warunkiem `where storeid between 594 and 610`:

![Plan zapytania dla warunku "where storeid between 594 and 610" - indeks klastrowany](media/image-38.png)

![Plan zapytania dla warunku "where storeid between 594 and 610" - indeks klastrowany](media/image-37.png)

![Czas wykonania zapytania dla warunku "where storeid between 594 and 610" - indeks klastrowany](media/image-39.png)

Komentarz:

Plan zapytania ponownie się zmienił, ponieważ stworzyliśmy indeks klastrowany ze względu na `storeid` mamy bezpośredni dostęp do wszystkich pól (dane zostały fizycznie przeorganizowane). Koszt w przypadku obu zapytań jest praktycznie identyczny, a także jest około:

- ~2-krotnie niższy niż zapytanie z indeksem nieklastrowanym oraz ~40-krotnie niższy niż zapytanie bez indeksu dla warunku `where storeid=594`
- ~10-krotnie niższy niż zapytanie z indeksem nieklastrowanym oraz ~40-krotnie niższy niż zapytanie bez indeksu dla warunku `where storeid between 594 and 610`

Różnice w koszcie wynikają z faktu, że w przypadku indeksu klastrowanego, dane są fizycznie reorganizowane na dysku, w rezultacie czego mamy bezpośredni dostęp do wszystkich atrybutów i nie musimy pobierać brakujących danych spod konkretnego adresu.

W przypadku warunku `where storeid between 594 and 610` przewaga indeksu klastrowanego jest jeszcze większa, ponieważ dane te leż fizycznie obok siebie na dysku.

# Zadanie 4 - dodatkowe kolumny w indeksie

Celem zadania jest porównanie indeksów zawierających dodatkowe kolumny.

Skopiuj tabelę `Address` do swojej bazy danych:

```sql
select * into address from  adventureworks2017.person.address
```

W tej części będziemy analizować następujące zapytanie:

```sql
select addressline1, addressline2, city, stateprovinceid, postalcode
from address
where postalcode between '98000' and '99999'
```

```sql
create index address_postalcode_1
on address (postalcode)
include (addressline1, addressline2, city, stateprovinceid);
go

create index address_postalcode_2
on address (postalcode, addressline1, addressline2, city, stateprovinceid);
go
```

Czy jest widoczna różnica w planach/kosztach zapytań?

- w sytuacji gdy nie ma indeksów
- przy wykorzystaniu indeksu:
  - address_postalcode_1
  - address_postalcode_2

Jeśli tak to jaka?

Aby wymusić użycie indeksu użyj `WITH(INDEX(Address_PostalCode_1))` po `FROM`

```sql
select addressline1, addressline2, city, stateprovinceid, postalcode
from address  WITH(INDEX(Address_PostalCode_1))
where postalcode between '98000' and '99999'


select addressline1, addressline2, city, stateprovinceid, postalcode
from address  WITH(INDEX(Address_PostalCode_2))
where postalcode between '98000' and '99999'
```

> Wyniki:

- bez indeksu:

![Plan zapytania dla warunku - brak indeksu](media/image-21.png)

![Plan zapytania dla warunku - brak indeksu](media/image-20.png)

![Czas wykonania zapytania dla warunku - brak indeksu](media/image-22.png)

- z indeksem `address_postalcode_1`:

![Plan zapytania dla warunku - indeks nr 1](media/image-24.png)

![Plan zapytania dla warunku - indeks nr 1](media/image-23.png)

![Czas wykonania zapytania dla warunku - indeks nr 1](media/image-25.png)

- z indeksem `address_postalcode_2`:

![Plan zapytania dla warunku - indeks nr 2](media/image-27.png)

![Plan zapytania dla warunku - indeks nr 2](media/image-26.png)

![Czas wykonania zapytania dla warunku - indeks nr 2](media/image-28.png)

Komentarz:

Pomiędzy zapytaniem bez indeksu a zapytaniami korzystającymi z indeksów występuje znacząca różnica w planach zapytania (zapytanie bez indeksu wykonuje pełne przeszukiwanie tabeli, zapytania z indeksami scanuje tylko indeks, a ponieważ oba indeksy pokrywają zapytanie to nie ma konieczności dodatkowego pobierania brakujących danych). Zapytania korzystające z indeksu `address_postalcode_1` oraz `address_postalcode_2` mają de facto identyczne plany zapytań (koszt również jest identyczny).

Sprawdź rozmiar Indeksów:

```sql
select i.name as indexname, sum(s.used_page_count) * 8 as indexsizekb
from sys.dm_db_partition_stats as s
inner join sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
where i.name = 'address_postalcode_1' or i.name = 'address_postalcode_2'
group by i.name
go
```

Który jest większy? Jak można skomentować te dwa podejścia do indeksowania? Które kolumny na to wpływają?

> Wyniki:

![Rozmiary indeksów "address_postalcode_1" oraz "address_postalcode_2"](media/image-29.png)

Komentarz:

Indeks `address_postalcode_2` jest nieznacznie większy niż indeks `address_postalcode_1` - wynika to z faktu, że w indeksie nr 1 kolumny `addressline1`, `addressline2`, `city` oraz `stateprovinceid` znajdują się wyłącznie na poziomie liści (indeks uwzględnia tylko `postalcode`, ale mamy bezpośredni dostęp do pozostałych kolumn), natomiast w indeksie nr 2 kolumny `addressline1`, `addressline2`, `city` oraz `stateprovinceid` są częścią klucza, a więc muszą one być uwzględnione na wszystkich poziomach drzewa indeksu.

W przypadku naszego zapytania indeks `address_postalcode_2` nie daje nam znaczącej przewagi, natomiast byłby on dużo bardziej wydajny niż indeks nr 1 np. przypadku filtrowania po większej liczbie kolumn (np. `where postalcode="..." and city="..."`).

# Zadanie 5 - kolejność atrybutów

Skopiuj tabelę `Person` do swojej bazy danych:

```sql
select businessentityid
      ,persontype
      ,namestyle
      ,title
      ,firstname
      ,middlename
      ,lastname
      ,suffix
      ,emailpromotion
      ,rowguid
      ,modifieddate
into person
from adventureworks2017.person.person
```

---

Wykonaj analizę planu dla trzech zapytań:

```sql
select * from [person] where lastname = 'Agbonile'

select * from [person] where lastname = 'Agbonile' and firstname = 'Osarumwense'

select * from [person] where firstname = 'Osarumwense'
```

Co można o nich powiedzieć?

---

> Wyniki:

![Plany zapytań dla zapytań o Osarumwese Agbonile - brak indeksu](media/image-34.png)

Komentarz:

W przypadku wszystkich zapytań korzystamy z pełnego przeszukiwania (`full scan`), ponieważ nie mamy indeksu. Niezależnie od kolejności atrybutów, koszt zapytania jest identyczny, ponieważ i tak musimy przejrzeć wszystkie wiersze.

Przygotuj indeks obejmujący te zapytania:

```sql
create index person_first_last_name_idx
on person(lastname, firstname)
```

Sprawdź plan zapytania. Co się zmieniło?

---

> Wyniki:

![Plany zapytań o Osarumwese Agbonile - indeks na (lastname, firstame)](media/image-35.png)

Komentarz:

- w przypadku zapytań korzystających z filtra `where lastname="Agbonile"` zapytania korzystają z bardzo wydajnej operacji `Index Seek`, która pozwala na dostęp
- w przypadku zapytania korzystającego jedynie z filtra `where firstname=...`, zapytanie nie może korzystać z `Index Seek`, a zamiast tego wykorzystywana jest operacja `Index Scan` - wynika to z tego, że "pominęliśmy" jeden poziom w indeksie (klauzula nie pozwala na precyzyjne wyznaczenie "ścieżki" do danych i w rezultacie musimy przeszukać cały indeks)
- zapytanie korzystające z obu atrybutów w klauzuli `where` charakteryzuje się najniższym kosztem (~0.006 w porównaniu do ~0.008 dla zapytanie korzystające wyłącznie z atrybutu `lastname`). Zapytanie korzystające jedynie z atrybutu `firstname` charakteryzuje się najwyższym kosztem i ma jedynie nieznacznie mniejszy koszt niż zapytanie bez indeksu.

Przeprowadź ponownie analizę zapytań tym razem dla parametrów: `FirstName = ‘Angela’` `LastName = ‘Price’`. (Trzy zapytania, różna kombinacja parametrów).

Czym różni się ten plan od zapytania o `'Osarumwense Agbonile'` . Dlaczego tak jest?

---

> Wyniki:

![Plany zapytań o Angela Price - indeks na (lastname, firstame)](media/image-36.png)

Komentarz:

W przypadku zapytań 1. oraz 3. (odpowiednio tylko z warunkiem `where lastname="..."` oraz `where firstname="..."`), ze względu na ilość osób o odpowiedniu zadanym nazwisku lub imieniu, MSSQL zdecydował że skorzystanie z indeksu (a następnie pobieranie brakujących w indeksie danych ze znalezionych adresów) będzie mniej wydajne niż przeszukiwanie całej tabeli (`Table Scan`). W przypadku warunku `FirstName = ‘Angela’` `LastName = ‘Price’` indeks jest wykorzystywany.

---

Punktacja:

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 2   |
| 2       | 2   |
| 3       | 2   |
| 4       | 2   |
| 5       | 2   |
| razem   | 10  |
|         |     |
