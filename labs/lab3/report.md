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

**Imiona i nazwiska:**

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

```sql
--  ...
```

Dodaj indeks:

```sql
create  index customer_store_cls_idx on customer(storeid)
```

Jak zmienił się plan i czas? Czy jest możliwość optymalizacji?

---

> Wyniki:

```sql
--  ...
```

Dodaj indeks klastrowany:

```sql
create clustered index customer_store_cls_idx on customer(storeid)
```

Czy zmienił się plan/koszt/czas? Skomentuj dwa podejścia w wyszukiwaniu krotek.

---

> Wyniki:

```sql
--  ...
```

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

```sql
--  ...
```

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

```sql
--  ...
```

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

```sql
--  ...
```

Przygotuj indeks obejmujący te zapytania:

```sql
create index person_first_last_name_idx
on person(lastname, firstname)
```

Sprawdź plan zapytania. Co się zmieniło?

---

> Wyniki:

```sql
--  ...
```

Przeprowadź ponownie analizę zapytań tym razem dla parametrów: `FirstName = ‘Angela’` `LastName = ‘Price’`. (Trzy zapytania, różna kombinacja parametrów).

Czym różni się ten plan od zapytania o `'Osarumwense Agbonile'` . Dlaczego tak jest?

---

> Wyniki:

```sql
--  ...
```

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
